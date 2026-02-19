local errors = requireC("/GuardLink/server/lib/errors.lua")

local dispatcher = {}
dispatcher.__index = dispatcher

-- one request has the following fields: id, timestamp, message, clientID
function dispatcher.new(services)
    local self = setmetatable({}, dispatcher)
    self.handlers = {}
    self.callbacks = {}
    self.path = "/GuardLink/server/dispatchers/"
    self.ctx = services
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

function dispatcher:dispatch(msg, client, id)
    if not self.handlers[msg.action] or not msg.action then return errors.UNKNOWN_DISPATCHER end
    if not msg.payload then return errors.MISSING_PAYLOAD end
    if self.callbacks[id] then
        local ok, result = pcall(self.callbacks[id], msg, client, id, self.ctx)
        self.callbacks[id] = nil
        if not ok then return errors.MALFORMED_MESSAGE end
        if result ~= 0 then return result end
    else
        local result = self.handlers[msg.action](msg, client, id, self.ctx)
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
        return dispatcher.new(ctx.services)
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