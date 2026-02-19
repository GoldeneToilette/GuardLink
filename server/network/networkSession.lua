local errors = requireC("/GuardLink/server/lib/errors.lua")
local fileUtils = requireC("/GuardLink/server/lib/fileUtils.lua")
local rsa = requireC("/GuardLink/server/lib/rsa-keygen.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")

local NetworkSession = {}
NetworkSession.__index = NetworkSession

local defaultKeyPath = "/GuardLink/server/"

local log

function NetworkSession.new(queue, settings, logger)
    local self = setmetatable({}, NetworkSession)
    self.requestQueue = queue

    log = logger:create("session", {timestamp = true, level = "INFO", clear = true})

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
    self.modem = peripheral.find("modem") or log:fatal("[networkSession] Failed to launch server: No modems found!")
    if not self.modem.isWireless() then log:fatal("[networkSession] Failed to launch server: Modem is not wireless!") end
end

function NetworkSession:initKeys(keyPath)
    local privatePath = (keyPath or defaultKeyPath) .. "private.key"
    local publicPath  = (keyPath or defaultKeyPath) .. "public.key"
    if not fileUtils.read(privatePath) then
        local start = os.clock()
        log:info("[networkSession] Couldnt find keypair, generating... ")
        local privateKey, publicKey = rsa.generateKeyPair()
        self.privateKey, self.publicKey = privateKey, publicKey
        fileUtils.newFile(privatePath)
        fileUtils.newFile(publicPath)
        fileUtils.write(privatePath, textutils.serialize(privateKey))
        fileUtils.write(publicPath, textutils.serialize(publicKey))

        log:info("[networkSession] Finished generating keypair: Took " .. math.ceil(os.clock() - start) .. " seconds.")
        log:info("[networkSession] Keys saved to " .. privatePath .. " and " .. publicPath)
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
            if status ~= 0 then log:error(status[2]) end 
        end
    end
    return self.exitCode or 0
end

function NetworkSession:start()
    utils.tryCatch(
        function()
            log:info("[networkSession] Launching Server with discovery channel: " .. self.discovery)

            self:open(self.discovery) 
            local code = self:listen() -- listener loop runs here until it exits with a code
            log:info("[networkSession] Server shut down! Reason: " .. (self.shutdownReason or "unknown"))
            if code ~= 0 then log:error("[networkSession] Exit code: " .. code) end
            self:closeAll()
        end,
        function(err, stackTrace)
            log:fatal("[networkSession] Server crashed :(")
            log:error("[networkSession] Error:" .. err)
            os.shutdown()            
        end        
    )
end

local service = {
    name = "network_session",
    deps = {"request_queue"},
    init = function(ctx)
        return NetworkSession.new(ctx.services["request_queue"], ctx.configs["settings"], ctx.services["logger"])
    end,
    runtime = function(self) self:start() end,
    tasks = nil,
    shutdown = nil,
    api = nil
}

return service