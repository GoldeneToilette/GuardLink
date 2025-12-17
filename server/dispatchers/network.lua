local errors = require "lib.errors"
local message = require "network.message"

local handlers = {}

function handlers.handshake(payload, client, id, ctx, session)
    local msg = message.create("network", {action = "handshake", key = session.publicKey})
    msg.id = id
    session:send(session.discovery, textutils.serialize({plaintext = true, message = msg}))
    return 0
end

function handlers.heartbeat()
    return 0
end

local function func(msg, client, id, ctx, session)
    if not handlers[msg.payload.action] then return errors.MALFORMED_MESSAGE end
    return handlers[msg.payload.action](msg.payload, client, id, ctx, session)
end

return func