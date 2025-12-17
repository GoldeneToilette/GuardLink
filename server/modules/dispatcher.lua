local errors = require "lib.errors"

local dispatcher = {}
dispatcher.handlers = {}
dispatcher.callbacks = {}
dispatcher.path = "/GuardLink/server/dispatchers/"
local ctx =  {
    accounts = require "modules.account",
    wallet = require "modules.wallet"
}

function dispatcher.new(session)
    dispatcher.session = session
    local list = fs.list(dispatcher.path)

    for _, v in ipairs(list) do
        local name = v:gsub("%.lua$", "")
        dispatcher.handlers[v] = require(dispatcher.path .. name)
    end
end

function dispatcher.register(action, func)
    dispatcher.handlers[action] = func
end

function dispatcher.dispatch(msg, client, id)
    if not dispatcher.handlers[msg.action] or not msg.action then return errors.UNKNOWN_DISPATCHER end
    if not msg.payload then return errors.MISSING_PAYLOAD end
    if dispatcher.callbacks[id] then
        local ok, result = pcall(dispatcher.callbacks[id], msg, client, id, ctx, dispatcher.session)
        dispatcher.callbacks[id] = nil
        if not ok then return errors.MALFORMED_MESSAGE end
        if result ~= 0 then return result end
    else
        local result = dispatcher.handlers[msg.action](msg, client, id, ctx, dispatcher.session)
        if result ~= 0 then return result end
    end
    
    return 0
end

function dispatcher.addCallback(id, func)
    dispatcher.callbacks[id] = func
end

return dispatcher