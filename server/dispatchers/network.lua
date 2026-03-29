local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network/message.lua")

local handlers = {}

function handlers.discovery(msg, client, id, ctx, fn, logger)
    local session = ctx.services["network_session"]
    local identity = ctx.configs["identity"]
    local msg = message.create("network", {
        action = "discovery",
        key = session.publicKey,
        name = identity.nation_name,
        certificate = session.certificate or nil
    }, nil, false, id)
    session:send(session.discovery, msg)
    return 0
end

function handlers.heartbeat(msg, client, id, ctx, fn, logger)
    if not client then return errors.UNKNOWN_CLIENT end
    client.sleepy = false
    return 0
end

function handlers.disconnect(msg, client, id, ctx, fn, logger)
    if not client then return errors.UNKNOWN_CLIENT end
    ctx.services["client_manager"]:disconnectClient(client.id, "log_out")
    return 0
end

function handlers.ping(msg, client, id, ctx, fn, logger)
    local session = ctx.services["network_session"]
    local channel = client and client.channel or session.discovery
    local key = client and client.aesKey or nil
    local msg = message.create("network", {
        action = "ping",
        timestamp = os.epoch("utc")
    }, key, false, id)
    session:send(channel, msg)
    return 0
end

local function func(msg, client, id, ctx, fn, logger)
    if not handlers[msg.payload.action] then return errors.MALFORMED_MESSAGE end
    if client and msg.payload.token ~= client.token then
        return errors.TOKEN_MISMATCH
    end
    return handlers[msg.payload.action](msg, client, id, ctx, fn, logger)
end

return func