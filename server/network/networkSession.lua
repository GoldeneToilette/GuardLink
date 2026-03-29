local errors = requireC("/GuardLink/server/lib/errors.lua")
local fileUtils = requireC("/GuardLink/server/lib/fileUtils.lua")
local rsa = requireC("/GuardLink/server/lib/rsa-keygen.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")
local sha256 = requireC("/GuardLink/server/lib/sha256.lua")

local NetworkSession = {}
NetworkSession.__index = NetworkSession

local defaultKeyPath = "/GuardLink/server/"

local log

function NetworkSession.new(ctx, settings, logger, identity)
    local self = setmetatable({}, NetworkSession)
    self.ctx = ctx
    self.settings = settings
    self.identity = identity

    log = logger:createInstance("session", {timestamp = true, level = settings.debug and "DEBUG" or "INFO", clear = true})

    self.discovery = settings.session.discoveryChannel or 65535
    self.keyPath = settings.session.keyPath
    self.channels = {}

    self.privateKey = nil
    self.publicKey = nil

    self.stopped = false
    return self
end

function NetworkSession:shutdown(reason, code)
    self.stopped = true
    self.shutdownReason = reason or "unknown"
    self.exitCode = code or 0
end

function NetworkSession:initModem()
    self.modem = peripheral.find("modem") or log:fatal("Failed to launch server: No modems found!")
    if not self.modem.isWireless() then log:fatal("Failed to launch server: Modem is not wireless!") end
    log:debug("Modem found: " .. peripheral.getName(self.modem))
end

local function serializeKey(key)
    local s = "{\n"
    for k, v in pairs(key) do
        s = s .. "    " .. k .. " = \"" .. tostring(v) .. "\",\n"
    end
    return s .. "}"
end

local function deserializeKey(str)
    local key = {}
    for k, v in str:gmatch('(%w+)%s*=%s*"([^"]+)"') do
        key[k] = v
    end
    return key
end

function NetworkSession:fetchCertificate(certPath)
    local keyString = self.identity.nation_name .. ":" .. self.publicKey.shared .. ":" .. self.publicKey.public
    local keyHash = sha256.digest(keyString):toHex():sub(1, 30)

    local r1 = http.post(
        "https://guardlink.goldenetoilette.workers.dev/",
        textutils.serializeJSON({
            step = "challenge",
            shared = self.publicKey.shared,
            public = self.publicKey.public,
            name = self.identity.nation_name
        }),
        {["Content-Type"] = "application/json"}
    )
    if not r1 then
        log:error("Could not reach CA for challenge")
        return
    end
    local challengeData = textutils.unserializeJSON(r1.readAll())
    r1.close()
    if not challengeData or not challengeData.challenge then
        log:error("CA did not return a challenge")
        return
    end
    local challenge = challengeData.challenge

    local challengeHash = sha256.digest(challenge):toHex():sub(1, 30)
    local signature = rsa.rsaSign(challengeHash, self.privateKey)
    local r2 = http.post(
        "https://guardlink.goldenetoilette.workers.dev/",
        textutils.serializeJSON({
            step = "register",
            shared = self.publicKey.shared,
            public = self.publicKey.public,
            name = self.identity.nation_name,
            signature = signature
        }),
        {["Content-Type"] = "application/json"}
    )
    if not r2 then
        log:error("Could not reach CA for registration")
        return
    end
    local data = textutils.unserializeJSON(r2.readAll())
    r2.close()

    if data and data.certificate then
        self.certificate = {
            signature = data.certificate,
            issuedAt = os.date("%Y-%m-%d %H:%M:%S"),
            issuedAtEpoch = os.epoch("utc"),
            publicKey = self.publicKey.public,
            shared = self.publicKey.shared
        }
        fileUtils.newFile(certPath)
        fileUtils.write(certPath, textutils.serializeJSON(self.certificate))
        log:info("Certificate obtained and saved to " .. certPath)
        log:debug("Signing keyString: " .. keyString)
        log:debug("Signing hash: " .. keyHash)
    elseif data and data.error then
        log:error("CA registration failed: " .. data.error)
    else
        log:error("CA returned invalid response, running without certificate")
    end
end

function NetworkSession:initKeys()
    local servername = self.identity.nation_name or "server"

    local privatePath = (self.keyPath or defaultKeyPath) .. "private.key"
    local publicPath  = (self.keyPath or defaultKeyPath) .. "public.key"
    local certPath = (self.keyPath or defaultKeyPath) .. servername .. ".cert"
    
    if not fs.exists(privatePath) then
        local start = os.clock()
        log:info("Couldnt find keypair, generating... ")
        local privateKey, publicKey = rsa.generateKeyPair()
        self.privateKey, self.publicKey = privateKey, publicKey
        fileUtils.newFile(privatePath)
        fileUtils.newFile(publicPath)
        fileUtils.write(privatePath, serializeKey(privateKey))
        fileUtils.write(publicPath, serializeKey(publicKey))
        log:info("Finished generating keypair: Took " .. math.ceil(os.clock() - start) .. " seconds.")
        log:info("Keys saved to " .. privatePath .. " and " .. publicPath)
    else
        self.privateKey = deserializeKey(fileUtils.read(privatePath))
        self.publicKey  = deserializeKey(fileUtils.read(publicPath))
        log:debug("RSA Public key loaded " .. publicPath .. ":\n" .. tostring(fileUtils.read(publicPath)))
        log:debug("RSA Private key loaded " .. privatePath .. ":\n" .. tostring(fileUtils.read(privatePath)))
    end
    addEntropy(self.privateKey.private .. self.publicKey.public)

    if not fs.exists(certPath) then
        log:info("Certificate not found, requesting from CA...")
        self:fetchCertificate(certPath)        
    else
        local certData = textutils.unserializeJSON(fileUtils.read(certPath))
        if certData then
            self.certificate = certData
            log:debug("Certificate loaded from " .. certPath)            
        else
            log:error("Certificate file is malformed, re-requesting...")
            self:fetchCertificate(certPath)
        end
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
    if self:channelCount() + 1 >= 128 then return errors.CHANNEL_CAPACITY_REACHED end
    self.modem.open(channel)
    self.channels[channel] = true
    return 0
end

function NetworkSession:close(channel)
    if not self.modem.isOpen(channel) then return errors.CHANNEL_ALREADY_CLOSED end
    self.modem.close(channel)
    self.channels[channel] = nil
end

function NetworkSession:closeAll()
    for k, _ in pairs(self.channels) do
        self.modem.close(k)
    end
    self.channels = {}
    log:debug("Closed all channels")
end

function NetworkSession:send(channel, message)
    self.modem.transmit(channel, math.random(0, 65535), message)
    --log:debug("Sending message on channel " .. channel .. ":\n" .. message)
end

function NetworkSession:listen()
    log:debug("Starting event listener loop")
    while not self.stopped do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if self.channels[channel] then
            log:debug("Message received on channel " .. channel)
            local status = self.ctx["request_queue"]:addRequest(message)
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
            self:initModem()
            self:initKeys()
            self:open(self.discovery)
            local code = self:listen()
            log:info("Server shut down! Reason: " .. (self.shutdownReason or "unknown"))
            log:info("Server was online for " .. string.format("%.2f", os.clock() - startTime) .. " seconds")
            if code ~= 0 then log:error("Exit code: " .. code) end
            self:closeAll()
        end,
        function(err, stackTrace)
            log:fatal("Network session crashed :(")
            log:error("Error:" .. err)
            os.shutdown()
        end
    )
end

local service = {
    name = "network_session",
    deps = {"request_queue"},
    init = function(ctx)
        return NetworkSession.new(ctx.services, ctx.configs["settings"], ctx.services["logger"], ctx.configs["identity"])
    end,
    runtime = function(self) self:start() end,
    tasks = nil,
    shutdown = nil,
    api = nil
}

return service