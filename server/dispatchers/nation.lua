local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network/message.lua")

local handlers = {}

function handlers.info(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    local nation = ctx.services["nation"]
    local identity = nation:getIdentity()
    local key = client and client.aesKey or nil
    local channel = client and client.channel or session.discovery
    local msg = message.create("nation", {
        action = "info",
        status = "success",
        data = {
            name     = identity.nation_name,
            tag      = identity.nation_tag,
            currency = identity.currency_name,
            ethic    = identity.selectedEthic,
        }
    }, key, false, id, senderID)
    session:send(channel, msg)
    return 0
end

function handlers.stats(msg, client, id, ctx, fn, logger, sender, senderID)
    if not client then return errors.UNKNOWN_CLIENT end
    local session = ctx.services["network_session"]
    local msg = message.create("nation", {
        action = "stats",
        status = "success",
        data   = ctx.services["nation"]:getStats()
    }, client.aesKey, false, id, senderID)
    session:send(client.channel, msg)
    return 0
end

local function func(msg, client, id, ctx, fn, logger, sender, senderID)
    if not msg.payload or not msg.payload.action then return errors.MALFORMED_MESSAGE end
    if not handlers[msg.payload.action] then return errors.MALFORMED_MESSAGE end
    if client and msg.payload.token ~= client.token then return errors.TOKEN_MISMATCH end
    return handlers[msg.payload.action](msg, client, id, ctx, fn, logger, sender, senderID)
end

return func
