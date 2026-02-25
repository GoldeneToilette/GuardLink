local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network.message.lua")
local aes = requireC("/GuardLink/server/lib/aes.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")

local clientManager = {}
clientManager.__index = clientManager

local log

function clientManager.new(session, settings, logger)
    local self = setmetatable({}, clientManager)
    self.clients = {}
    self.session = session or nil

    log = logger:createInstance("clients", {timestamp = true, level = settings.debug and "DEBUG" or "INFO", clear = true})

    self.max_idle = (settings.clients.max_idle or 60) * 1000
    self.heartbeat_interval = (settings.clients.heartbeat_interval or 60)
    self.maxClients = settings.clients.maxClients or 30
    self.throttleLimit = (settings.clients.throttleLimit or 7200) * 1000
    self.channelRotation = settings.clients.channelRotation or 30
    self.clientIDLength = settings.clients.idLength or 5

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
        self.session:send(client.channel, msg)
        self.session:close(client.channel)
        self.clients[id] = nil
        log:debug("Disconnecting client: " .. id .. ", for reason: " .. reason)
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
        self.session:send(client.channel, msg)
        self.session:close(client.channel)
        i = i + 1
    end
    self.clients = {}
    log:info("Disconnected all (" .. i .. ") clients!")
    return i
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
    local seed = utils.stringToNumber(sessionToken) + t
    return (seed % 65534) + 1
end

function clientManager:registerClient(account, aesKey)
    if self:count() + 1 > self.maxClients then return errors.SERVER_FULL end
    local clientID
    local sessionToken
    repeat
        clientID = utils.randomString(self.clientIDLength, "numbers")
        sessionToken = utils.randomString(32, "generic")
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
    log:debug("Registering client with ID " .. clientID)
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
    log:debug("Throttle set to " .. throttle .. " seconds for client " .. id)
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
    log:debug("Sending out heartbeats:")
    for _, v in pairs(clients) do
        if v.sleepy then
            if time - v.lastActivityTime > self.max_idle then
                self:disconnectClient(v.id, "time_out")
            else
                v.sleepy = false
            end
            log:debug("Client " .. v.id .. " has not responded to heartbeat, timing out...")
        else
            v.sleepy = true
            local msg = message.create("network", { action = "heartbeat" }, v.aesKey, false)
            self.session:send(v.channel, msg)
            log:debug("Awaiting heartbeat response from client " .. v.id)
        end
    end
end

function clientManager:updateChannels()
    local f = false
    log:debug("Rotating channels:")
    for _, v in pairs(self.clients) do
        local newchannel = self:computeChannel(v.token)

        local msg = message.create("network", {action = "update_channel", channel = newchannel}, v.aesKey, false)
        self.session:send(v.channel, msg)
        self.session:close(v.channel)
        log:debug("Client: " .. v.id .. ", Old channel: " .. v.channel .. ", New Channel: " .. newchannel)         
        v.channel = newchannel
        f = true       
    end

    for _, v in pairs(self.clients) do
        self.session:open(v.channel)
    end
    return not f and errors.NO_CLIENTS or 0
end

local service = {
    name = "client_manager",
    deps = {"network_session"},
    init = function(ctx)
        return clientManager.new(ctx.services["network_session"], ctx.configs["settings"], ctx.services["logger"])
    end,
    runtime = nil,
    tasks = function(self)
        return {
            client_heartbeats = {function(self) self:heartbeats() end, self.channelRotation},
            client_update_channel = {function(self) self:updateChannels() end, self.heartbeat_interval}      
        }
    end,
    shutdown = function(self) self:disconnectAll("SERVER_SHUTDOWN") end,
    api = {
        ["clients"] = {
            update_channels = function(self) return self:updateChannels() end,
            throttle = function(self, args) return self:setThrottle(args.id, args.throttle) end,
            list = function(self) return self:listClients() end,
            disconnect = function(self, args) return self:disconnectClient(args.id, args.reason) end,
            disconnect_all = function(self, args) return self:disconnectAll(args) end,
            count = function(self) return self:count() end,
            stale = function(self) return self:getStaleClients() end,
            get = function(self, args) return self:getClient(args) end,
            exists = function(self, args) return self.clients[args] ~= nil end,
            heartbeats = function(self) self:heartbeats() return 0 end,
        }
    }
}

return service