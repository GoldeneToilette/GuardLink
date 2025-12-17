local errors = require "lib.errors"
local fileUtils = require "lib.fileUtils"
local rsa = require "lib.rsa-keygen"

local NetworkSession = {}
NetworkSession.__index = NetworkSession

local defaultKeyPath = "/GuardLink/server/"

--[[
Settings table example:
local settings = {
    session = {
        discoveryChannel = 65535,
        keyPath = "/GuardLink/server/"
    },
    clients = {
        maxClients = 120,
        throttleLimit = 7200,
        max_idle = 60,
        heartbeat_interval = 30,
        channelRotation = 20,
        clientIDLength = 5
    },
    queue = {
        queueSize = 40,
        throttle = 1 -- meaning its gonna process the entire queue once every second
    }
}
]]--

function NetworkSession.new(settings)
    local self = setmetatable({}, NetworkSession)
    self.clientManager = require("network.clientManager").new(self, settings)
    self.requestQueue = require("network.requestQueue").new(self, settings)

    self.discovery = settings.discoveryChannel or 65535
    self.channels = {}

    self.privateKey = nil
    self.publicKey = nil

    self:initModem()
    self:initKeys(settings.keyPath)

    self.shutdown = false
    return self
end

function NetworkSession:shutdown(reason, code)
    self.shutdown = true
    self.shutdownReason = reason or "unknown"
    self.exitCode = code or 0
end

function NetworkSession:initModem()
    self.modem = peripheral.find("modem") or _G.logger:fatal("[networkSession] Failed to launch server: No modems found!")
    if not self.modem.isWireless() then _G.logger:fatal("[networkSession] Failed to launch server: Modem is not wireless!") end
end

function NetworkSession:initKeys(keyPath)
    local privatePath = (keyPath or defaultKeyPath) .. "private.key"
    local publicPath  = (keyPath or defaultKeyPath) .. "public.key"
    if not fileUtils.read(privatePath) then
        local start = os.clock()
        _G.logger:info("[networkSession] Couldnt find keypair, generating... ")
        local privateKey, publicKey = rsa.generateKeyPair()
        self.privateKey, self.publicKey = privateKey, publicKey
        fileUtils.newFile(privatePath)
        fileUtils.newFile(publicPath)
        fileUtils.write(privatePath, textutils.serialize(privateKey))
        fileUtils.write(publicPath, textutils.serialize(publicKey))

        _G.logger:info("[networkSession] Finished generating keypair: Took " .. math.ceil(os.clock() - start) .. " seconds.")
        _G.logger:info("[networkSession] Keys saved to " .. privatePath .. " and " .. publicPath)
    else
        self.privateKey = textutils.unserialize(fileUtils.read(privatePath))
        self.publicKey  = textutils.unserialize(fileUtils.read(publicPath))
    end
end

function NetworkSession:channelCount()
    local n = 0
    for _ in pairs(self.channels) do
        n = n+1
    end
    return n
end

function NetworkSession:open(channel)
    if self.modem.isOpen(channel) then return errors.CHANNEL_ALREADY_OPEN end
    if self:channelCount() + 1 >= 128 then return errors.CHANNEL_CAPACITY_REACHED end
    self.modem.open(channel)
    self.channels[channel] = true
    return 0
end

function NetworkSession:close(channel)
    if not self.modem.isOpen(channel) then return errors.CHANNEL_ALREADY_CLOSED end
    self.modem.close(channel)
    self.channels[channel] = nil
    return 0
end

function NetworkSession:closeAll()
    for k, _ in pairs(self.channels) do
        self.modem.close(k)
    end
    self.channels = {}
end

function NetworkSession:send(channel, message)
    self.modem.transmit(channel, 0, message)
end

function NetworkSession:listen()
    while not self.shutdown do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if self.channels[channel]  then
            local status = self.requestQueue:addRequest(message)
            if status ~= 0 then _G.logger:error(status[2]) end 
        end
    end
    return self.exitCode or 0
end

function NetworkSession:start()
    _G.utils.tryCatch(
        function()
            _G.logger:info("[networkSession] Launching Server with discovery channel: " .. self.discovery)

            self:open(self.discovery) 
            local code = self:listen() -- listener loop runs here until it exits with a code
            _G.logger:info("[networkSession] Server shut down! Reason: " .. (self.shutdownReason or "unknown"))
            if code ~= 0 then _G.logger:error("[networkSession] Exit code: " .. code) end
            self:closeAll()
        end,
        function(err, stackTrace)
            _G.logger:fatal("[networkSession] Server crashed :(")
            _G.logger:error("[networkSession] Error:" .. err)
            os.shutdown()            
        end        
    )
end

return NetworkSession