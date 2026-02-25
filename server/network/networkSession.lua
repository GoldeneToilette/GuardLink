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

    log = logger:createInstance("session", {timestamp = true, level = settings.debug and "DEBUG" or "INFO", clear = true})

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
    self.modem = peripheral.find("modem") or log:fatal("Failed to launch server: No modems found!")
    if not self.modem.isWireless() then log:fatal("Failed to launch server: Modem is not wireless!") end
    log:debug("Modem found: " .. peripheral.getName(self.modem))
end

function NetworkSession:initKeys(keyPath)
    local privatePath = (keyPath or defaultKeyPath) .. "private.key"
    local publicPath  = (keyPath or defaultKeyPath) .. "public.key"
    if not fileUtils.read(privatePath) then
        local start = os.clock()
        log:info("Couldnt find keypair, generating... ")
        local privateKey, publicKey = rsa.generateKeyPair()
        self.privateKey, self.publicKey = privateKey, publicKey
        fileUtils.newFile(privatePath)
        fileUtils.newFile(publicPath)
        fileUtils.write(privatePath, textutils.serialize(privateKey))
        fileUtils.write(publicPath, textutils.serialize(publicKey))

        log:info("Finished generating keypair: Took " .. math.ceil(os.clock() - start) .. " seconds.")
        log:info("Keys saved to " .. privatePath .. " and " .. publicPath)
    else
        self.privateKey = textutils.unserialize(fileUtils.read(privatePath))
        self.publicKey  = textutils.unserialize(fileUtils.read(publicPath))
        log:debug("RSA Public key loaded: " .. publicPath)
        log:debug("RSA Private key loaded: " .. privatePath)
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
    log:debug("Opening channel " .. channel .. ", total: " .. self:channelCount())
    return 0
end

function NetworkSession:close(channel)
    if not self.modem.isOpen(channel) then return errors.CHANNEL_ALREADY_CLOSED end
    self.modem.close(channel)
    self.channels[channel] = nil
    log:debug("Closing channel " .. channel .. ", remaining: " .. self:channelCount())    
    return 0
end

function NetworkSession:closeAll()
    for k, _ in pairs(self.channels) do
        self.modem.close(k)
    end
    self.channels = {}
    log:debug("Closed all channels")
end

function NetworkSession:send(channel, message)
    self.modem.transmit(channel, 0, message)
    log:debug("Sending message on channel " .. channel)
end

function NetworkSession:listen()
    log:debug("Starting event listener loop")
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
            local startTime = os.clock()
            log:info("Launching Server with discovery channel: " .. self.discovery)

            self:open(self.discovery) 
            local code = self:listen() -- listener loop runs here until it exits with a code
            log:info("Server shut down! Reason: " .. (self.shutdownReason or "unknown"))
            log:info("Server was online for " .. string.format("%.2f", os.clock() - startTime) .. " seconds")
            if code ~= 0 then log:error("Exit code: " .. code) end
            self:closeAll()
        end,
        function(err, stackTrace)
            log:fatal("Server crashed :(")
            log:error("Error:" .. err)
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