local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network.message.lua")

local handlers = {}

function handlers.login(msg, _, id, ctx, session)
    local username = msg.payload.username
    local password = msg.payload.password
    local aesKey = msg.payload.aesKey
    local auth = ctx.accounts.authenticateUser(username, password)
    if not aesKey or aesKey == "" or #aesKey ~= 16 then return errors.MALFORMED_MESSAGE end
    if auth == 0 then
        local client = session.clientManager.registerClient(username, aesKey)
        if not client.throttle then return client end -- meaning it returned an error instead of a client table
        local msg = message.create("account", {
        action = "login", 
        status = "success", 
        token = client.token,
        channel = client.channel
        }, client.aesKey)
        msg.id = id
        session:send(session.discovery, textutils.serialize({plaintext = false, message = msg}))
    else
        local msg = message.create("account", {
            action = "login",
            status = "failure",
            error = auth[1]
        })
        msg.id = id
        session:send(session.discovery, textutils.serialize({plaintext = true, message = msg}))
    end
    return 0
end

function handlers.info(msg, client, id, ctx, session)

end

local function func(msg, client, id, ctx, session)
    if not handlers[msg.payload.action] then return errors.MALFORMED_MESSAGE end
    if client and msg.payload.token ~= client.token then
        return errors.TOKEN_MISMATCH
    end
    return handlers[msg.payload.action](msg, client, id, ctx, session)
end

return func