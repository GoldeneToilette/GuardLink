local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network.message.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")

local handlers = {}

function handlers.login(msg, client, id, ctx, fn)
    local clientManager = ctx.services["client_manager"]
    local session = ctx.services["network_session"]
    local accounts = ctx.services["accounts"]
    local username = msg.payload.username
    local password = msg.payload.password
    local auth = accounts.authenticateUser(username, password)
    if auth == 0 then
        local client = clientManager.registerClient(username, utils.randomString(16, "generic"))
        if not client.throttle then return client end -- meaning it returned an error instead of a client table
        local msg = message.create("account", {
        action = "login", 
        status = "success", 
        token = client.token,
        channel = client.channel
        }, client.aesKey, false, id)
        session:send(session.discovery, msg)
    else
        local msg = message.create("account", {
            action = "login",
            status = "failure",
            error = auth.client
        }, nil, false, id)
        session:send(session.discovery, msg)
    end
    return 0
end

local function func(msg, client, id, ctx, fn)
    if not handlers[msg.payload.action] then return errors.MALFORMED_MESSAGE end
    if client and msg.payload.token ~= client.token then
        return errors.TOKEN_MISMATCH
    end
    return handlers[msg.payload.action](msg, client, id, ctx, fn)
end

return func