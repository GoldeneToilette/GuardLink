local errors = requireC("/GuardLink/server/lib/errors.lua")
local rsa = requireC("/GuardLink/server/lib.rsa-keygen.lua")

local requestQueue = {}
requestQueue.__index = requestQueue

local log

-- one request has the following fields: id, timestamp, message, clientID
function requestQueue.new(ctx, settings)
    local self = setmetatable({}, requestQueue)
    self.queue = {}
    self.clientManager = ctx.clientManager
    self.session = ctx.session
    self.dispatcher = ctx.dispatcher

    local loglevel = settings.debug and "DEBUG" or "INFO"
    log = ctx.logger:createInstance("queue", {timestamp = true, level = loglevel, clear = true})

    self.queueSize = settings.queue.queueSize or 40
    self.paused = false
    self.processedCount = 0
    self.lastProcessed = 0
    self.throttle = 0
    self.avgPacketSize = 0
    self.packetsSent = 0
    self.totalPacketSize = 0

    return self
end

function requestQueue:setThrottle(seconds)
    self.throttle = (seconds or 0) * 1000
    log:debug("Throttle set to " .. seconds .. " seconds")
end

function requestQueue:addRequest(message)
    if #self.queue + 1 > self.queueSize then return errors.QUEUE_FULL end
    self.packetsSent = self.packetsSent + 1
    if not message or message == "" then return errors.MALFORMED_MESSAGE end
    self.totalPacketSize = self.totalPacketSize + #message
    self.avgPacketSize = self.totalPacketSize / self.packetsSent
    local msg = textutils.unserialize(message)
    if not msg then return errors.MALFORMED_MESSAGE end
    if msg.clientID and not self.clientManager:exists(msg.clientID) then return errors.UNKNOWN_CLIENT end
    local tbl = {
        id = msg.id,
        message = msg.message,
        client = msg.clientID,
        timestamp = msg.timestamp,
        isPlaintext = msg.isPlaintext ~= false
    }
    table.insert(self.queue, tbl)
    return 0
end

function requestQueue:handleUnknownClient(request)
    if request.isPlaintext then
        log:debug("Received plaintext message: " .. request.message)
        local result = self.dispatcher:dispatch(textutils.unserialize(request.message), nil, request.id)
        if result ~= 0 then log:debug(result.log) return false end -- If request is malformed, it just logs it, no response
    else
        local ok, data = pcall(function() return rsa.rsaDecrypt(request.message, self.session.privateKey) end)
        if ok then
            log:debug("Received RSA-encrypted message: " .. data)
            local result = self.dispatcher:dispatch(textutils.unserialize(data), nil, request.id)
            if result ~= 0 then log:debug(result.log) return false end
        else
            log:debug("RSA decryption failed for unknown client! ")
        end   
    end
    return true    
end

function requestQueue:handleKnownClient(request, client, time)
    if time - client.lastActivityTime > ((client.throttle or 0)) then
        client.packetsSent = client.packetsSent + 1
        client.totalPacketSize = client.totalPacketSize + #request
        client.avgPacketSize = client.totalPacketSize / client.packetsSent
        local cipher = client.aesKey
        local ok, plaintext = pcall(function()
            return cipher:decrypt(request.message)
        end)
        if not ok or not plaintext then
            log:debug("AES decryption failed for " .. client.id)
            return true
        end
        log:debug("Received AES-encrypted message: " .. plaintext)
        local data = textutils.unserialize(plaintext)
        local result = self.dispatcher:dispatch(data, client, request.id)
        client.lastActivityTime = time
        if result ~= 0 then log:debug(result.log) end
        return true
    end
    return false
end

function requestQueue:processQueue()
    while true do
        if not self.paused then 
            local time = os.epoch("utc")
            local processed = {}
            if time - self.lastProcessed > ((self.throttle or 0)) then 
                self.lastProcessed = time
                for i, request in ipairs(self.queue) do
                    local clientID = request.client
                    local client = self.clientManager:getClient(clientID)
                    local success
                    if not client then
                        success = self:handleUnknownClient(request)
                    else 
                        success = self:handleKnownClient(request, client, time)
                    end
                    if success then table.insert(processed, i) end
                end
                for p = #processed, 1, -1 do
                    table.remove(self.queue, processed[p])
                end  
            end   
        end
        os.sleep(0.01)
    end
end

local service = {
    name = "request_queue",
    deps = {"client_manager", "network_session", "dispatcher"},
    init = function(ctx)
        return requestQueue.new(ctx.services, ctx.configs["settings"])
    end,
    runtime = function(self) self:processQueue() end,
    tasks = nil,
    shutdown = nil,
    api = {
        ["queue"] = {
            throttle = function(self, args) return self:setThrottle(args) end
        }
    }
}

return service