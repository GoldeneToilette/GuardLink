local errors = requireC("/GuardLink/server/lib/errors.lua")

local dispatcher = {}
dispatcher.__index = dispatcher

--[[
REMINDER FOR MYSELF:
A message is a serialized table consisting of id, timestamp, message = {header, payload}, isPlaintext
requestQueue deserializes and if needed decrypts it and passes it to the dispatcher.
If a callbacks existsDir for that message ID, the dispatcher executes it.
Dispatcher matches the msg.header to the sub-dispatchers and calls the handler. Returns status code. 
Example:
{
    id = "A1B2C3D4E5F6G7H8",
    timestamp = 1708712345678,
    message = {
        header = "login",
        payload = {
            username = "bob",
            password = "secret"
        }
    },
    isPlaintext = true
}
NOTE: QUEUE ONLY RETURNS THE MESSAGE PART AND THE ID
requestQueue infers encryption method based on the following criteria:
client exists -> AES or plaintext
client does not exist -> RSA or plaintext
Since it wouldnt make sense for an unregistered client to be sending AES encrypted messages
]]--

-- one request has the following fields: id, timestamp, message, clientID

local log

function dispatcher.new(ctx)
    local self = setmetatable({}, dispatcher)
    self.handlers = {}
    self.callbacks = {}
    self.path = "/GuardLink/server/dispatchers/"
    self.ctx = ctx

    log = ctx.services.logger:createInstance("dispatcher", {timestamp = true, level = "DEBUG", clear = true})
    
    local list = fs.list(self.path)
    for _, v in ipairs(list) do
        local name = v:gsub("%.lua$", "")
        self.handlers[name] = requireC(self.path .. name .. ".lua")
    end    

    return self
end

function dispatcher:register(action, func)
    self.handlers[action] = func
end

function dispatcher:dispatch(msg, client, id, sender, senderID)
    if not msg or not msg.header or not self.handlers[msg.header] then
            log:debug("Failed to dispatch: " .. errors.UNKNOWN_DISPATCHER.log)
            return errors.UNKNOWN_DISPATCHER 
        end
    if not msg.payload then 
        log:debug("Failed to dispatch: " .. errors.MISSING_PAYLOAD.log)
        return errors.MISSING_PAYLOAD 
    end
    if self.callbacks[id] then
        local ok, result = pcall(self.callbacks[id], msg, client, id, self.ctx, self.addCallback, log, sender, senderID)
        self.callbacks[id] = nil
        if not ok then 
            log:debug("Failed to dispatch: " .. errors.MALFORMED_MESSAGE.log .. ":\n" .. textutils.serialize(msg))
            return errors.MALFORMED_MESSAGE 
        end
        if result ~= 0 then return result end
    else
        local ok, result = pcall(self.handlers[msg.header], msg, client, id, self.ctx, self.addCallback, log, sender, senderID)
        if not ok then
            log:debug("Handler crashed: " .. tostring(result))
            return errors.MALFORMED_MESSAGE
        end
        if result ~= 0 then return result end
    end
    
    return 0
end

function dispatcher:addCallback(id, func)
    self.callbacks[id] = func
end

function dispatcher:getCallbacks()
    local tbl = {}
    for k,v in pairs(self.callbacks) do
        table.insert(tbl, k)
    end
    return (#tbl > 0 and tbl) or nil
end

local service = {
    name = "dispatcher",
    deps = {},
    init = function(ctx)
        return dispatcher.new(ctx)
    end,
    runtime = nil,
    tasks = nil,
    shutdown = nil,
    api = {
        ["dispatcher"] = {
            list_callbacks = function(self) return self:getCallbacks() end
        }
    }
}

return service