local errors = require "lib.errors"
local dispatcher = require "modules.dispatcher"
local rsa = require "lib.rsa-keygen"

local requestQueue = {}
requestQueue.__index = requestQueue

-- one request has the following fields: id, timestamp, message, clientID
function requestQueue.new(session, settings)
    local self = setmetatable({}, requestQueue)
    self.queue = {}
    self.session = session or nil
    dispatcher.new(self.session)

    self.queueSize = settings.queue.queueSize or 40
    self.paused = false
    self.processedCount = 0

    self.throttle = 0
    self.lastProcessed = 0

    return self
end

function requestQueue:setThrottle(seconds)
    self.throttle = (seconds or 0) * 1000
end

function requestQueue:addRequest(message)
    if #self.queue + 1 > self.queueSize then return errors.QUEUE_FULL end
    local msg = textutils.unserialize(message)
    if msg.clientID and not self.session.clientManager:exists(msg.clientID) then return errors.UNKNOWN_CLIENT end
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

function requestQueue:processQueue()
    while true do
        if not self.paused then 
            local time = os.epoch("utc")
            local processed = {}
            if time - self.lastProcessed < ((self.throttle or 0) * 1000) then goto nothing_to_do end
            self.lastProcessed = time

            for i, request in ipairs(self.queue) do -- REQUEST LOOP ------------------------------------
                local clientID = request.client
                local client = self.session.clientManager:getClient(clientID)
                if not client then
                    if request.isPlaintext then
                        _G.logger:debug("[requestQueue] Received plaintext message: " .. request.message)
                        local result = dispatcher.dispatch(textutils.unserialize(request.message), nil, request.id)
                        if result ~= 0 then _G.logger:debug(result[2]) end
                    else
                    local ok, data = pcall(function() return rsa.rsaDecrypt(request.message, self.session.privateKey) end)
                    if ok then
                            _G.logger:debug("[requestQueue] Received RSA-encrypted message: " .. data)
                            local result = dispatcher.dispatch(textutils.unserialize(data), nil, request.id)
                            if result ~= 0 then _G.logger:debug(result[2]) end
                    else
                            _G.logger:debug("[requestQueue] RSA decryption failed for unknown client! ")
                    end
                    end
                    table.insert(processed, i)
                else 
                    if time - client.lastActivityTime > ((client.throttle or 0) * 1000) then
                        local cipher = client.aesKey
                        local ok, plaintext = pcall(function()
                            return cipher:decrypt(request.message)
                        end)
                        _G.logger:debug("[requestQueue] Received AES-encrypted message: " .. plaintext)
                        if not ok or not plaintext then
                            _G.logger:debug("[requestQueue] AES decryption failed for " .. clientID)
                            table.insert(processed, i)
                            goto skip
                        end
                        local data = textutils.unserialize(plaintext)
                        local result = dispatcher.dispatch(data, client, request.id)
                        if result ~= 0 then _G.logger:debug(result[2]) end
                        client.lastActivityTime = time
                        table.insert(processed, i)
                    end
                end
                ::skip::
            end -- REQUEST LOOP ------------------------------------------------------------------------

            for p = #processed, 1, -1 do
                table.remove(self.queue, processed[p])
            end     
        end
        ::nothing_to_do::
        os.sleep(0.01)
    end
end

return requestQueue