local errors = require "lib.errors"
local message = require "network.message"
local aes = require "lib.aes"
os.loadAPI('/GuardLink/server/lib/aes.lua')


local clientManager = {}
clientManager.__index = clientManager

function clientManager.new(session, settings)
    local self = setmetatable({}, clientManager)
    self.clients = {}
    self.session = session or nil

    self.max_idle = (settings.clients.max_idle or 60) * 1000
    self.heartbeat_interval = (settings.clients.heartbeat_interval or 60)
    self.maxClients = settings.clients.maxClients or 30
    self.throttleLimit = (settings.clients.throttleLimit or 7200) * 1000
    self.channelRotation = settings.clients.channelRotation or 30
    self.clientIDLength = settings.clients.idLength or 5

    _G.shutdown.register(function() self:disconnectAll("SERVER_SHUTDOWN") end)
    return self
end

function clientManager:getClientByToken(token)
    for k, v in pairs(self.clients) do
        if v.token == token then
            return self.clients[k]
        end
    end
    return nil
end

function clientManager:exists(id)
    return self.clients[id] ~= nil
end

function clientManager:getClient(id)
    return self.clients[id]
end

function clientManager:updateActivity(id, activityType)
    local client = self:getClient(id)
    if client then
        client.lastActivityTime = os.epoch("utc")
        client.lastActivityType = activityType        
        return 0
    end
    return errors.UNKNOWN_CLIENT
end

function clientManager:disconnectClient(id, reason)
    local client = self.clients[id]
    if client then
        local msg = message.create("network", {action = "disconnect", reason = reason or "unknown_reason"}, client.aesKey, false)
        self.session:send(client.channel, textutils.serialize({plaintext = false, message = msg}))
        self.session:close(client.channel)
        self.clients[id] = nil
        return 0
    else
        return errors.UNKNOWN_CLIENT
    end
end

function clientManager:disconnectAll(reason)
    local payload = {action = "disconnect", reason = reason or "unknown_reason"}
    local i = 0
    for _, client in pairs(self.clients) do
        local msg = message.create("network", payload, client.aesKey, false)
        self.session:send(client.channel, textutils.serialize({plaintext = false, message = msg}))
        self.session:close(client.channel)
        i = i + 1
    end
    self.clients = {}
    _G.logger:info("[clientManager] Disconnected " .. i .. " clients!")
    return 0
end

function clientManager:count()
    local count = 0
    for _ in pairs(self.clients) do
        count = count + 1
    end
    return count
end

function clientManager:computeChannel(sessionToken)
    local t = math.floor(os.epoch("utc") / 1000)
    local seed = _G.utils.stringToNumber(sessionToken) + t
    return (seed % 65534) + 1
end

function clientManager:registerClient(account, aesKey)
    if self:count() + 1 > self.maxClients then return errors.SERVER_FULL end
    local clientID
    local sessionToken
    repeat
        clientID = _G.utils.randomString(self.clientIDLength, "numbers")
        sessionToken = _G.utils.randomString(32, "generic")
        local f = false
        for k, v in pairs(self.clients) do
            if v.token == sessionToken then f = true break end
        end
    until not self.clients[clientID] and not f

    local channel = self:computeChannel(sessionToken)
    self.session:open(channel)
    self.clients[clientID] = {
        token = sessionToken,
        id = clientID,
        connectedAt = os.date("%Y-%m-%d %H:%M:%S"),
        connectedAtEpoch = os.epoch("utc"),
        lastActivityTime = os.epoch("utc"),
        lastActivityType = "connected",
        throttle = 0,
        account = account,
        channel = channel,
        aesKey = aes.Cipher:new(nil, aesKey),
        sleepy = false
    }
    return self.clients[clientID]
end

function clientManager:listClients()
    local tbl = {}
    for k, v in pairs(self.clients) do
        table.insert(tbl, k)
    end
    return tbl
end

function clientManager:setThrottle(id, throttle)
    local client = self:getClient(id)
    if not client then return errors.UNKNOWN_CLIENT end
    client.throttle = math.min((throttle or 0) * 1000, self.throttleLimit)
    return 0
end

function clientManager:getStaleClients()
    local staleClients = {}
    local time = os.epoch("utc")
    for _, v in pairs(self.clients) do
        if time - v.lastActivityTime - (v.throttle or 0) > self.max_idle then
            table.insert(staleClients, v)
        end
    end
    return staleClients
end

function clientManager:heartbeats()
    local time = os.epoch("utc")
    local clients = self:getStaleClients()
    for _, v in pairs(clients) do
        if v.sleepy then
            if time - v.lastActivityTime > self.max_idle then
                self:disconnectClient(v.id, "time_out")
            else
                v.sleepy = false
            end
        else
            v.sleepy = true
            local msg = message.create("network", { action = "heartbeat" }, v.aesKey, false)
            self.session:send(v.channel, msg)
        end
    end
end

function clientManager:updateChannels()
    for _, v in pairs(self.clients) do
        local newchannel = self:computeChannel(v.token)

        local msg = message.create("network", {action = "update_channel", channel = newchannel}, v.aesKey, false)
        self.session:send(v.channel, textutils.serialize({plaintext = false, message = msg}))

        self.session:close(v.channel)
        v.channel = newchannel
    end

    for _, v in pairs(self.clients) do
        self.session:open(v.channel)
    end
    return 0
end

return clientManager