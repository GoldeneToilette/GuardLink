local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network/message.lua")
local rsa = requireC("/GuardLink/server/lib/rsa-keygen.lua")
local aes = requireC("/GuardLink/server/lib/aes.lua")

local handlers = {}

function handlers.login(msg, client, id, ctx, fn, logger)
    local clientManager = ctx.services["client_manager"]
    local session = ctx.services["network_session"]
    local accounts = ctx.services["accounts"]

    local ok, keyStr = pcall(function() 
        return rsa.rsaDecrypt(msg.payload.key.cipher, session.privateKey) 
    end)
    if not ok or not keyStr then 
        logger:debug("RSA decryption failed: " .. tostring(keyStr))
        return errors.MALFORMED_MESSAGE 
    end

    local username = aes.Cipher:new(nil, keyStr, msg.payload.username.iv):decrypt(msg.payload.username.cipher)
    local password = aes.Cipher:new(nil, keyStr, msg.payload.password.iv):decrypt(msg.payload.password.cipher)
    if not username or not password then return errors.MALFORMED_MESSAGE end

    local auth = accounts:authenticateUser(username, password)
    if auth == 0 then
        local client = clientManager:registerClient(username, keyStr)
        if not client.throttle then return client end -- meaning it returned an error instead of a client table
        local msg = message.create("account", {
        action = "login", 
        status = "success", 
        token = client.token,
        channel = client.channel,
        clientID = client.id
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

local function func(msg, client, id, ctx, fn, logger)
    if not handlers[msg.payload.action] then return errors.MALFORMED_MESSAGE end
    if client and msg.payload.token ~= client.token then
        return errors.TOKEN_MISMATCH
    end
    return handlers[msg.payload.action](msg, client, id, ctx, fn, logger)
end

return func