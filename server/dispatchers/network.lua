local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network.message.lua")

local handlers = {}

function handlers.discovery(msg, client, id, ctx, fn)
    local session = ctx.services["network_session"]
    local identity = ctx.configs["identity"]
    local msg = message.create("network", {
        action="discovery", 
        key = session.publicKey, 
        name = identity.nation_name},
        nil, false, id)
    session:send(session.discovery, msg)
    return 0
end

function handlers.heartbeat(msg, client, id, ctx, fn)
    return 0
end

local function func(msg, client, id, ctx, fn)
    if not handlers[msg.payload.action] then return errors.MALFORMED_MESSAGE end
    return handlers[msg.payload.action](msg, client, id, ctx, fn)
end

return func