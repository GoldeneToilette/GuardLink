local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network/message.lua")
local rsa = requireC("/GuardLink/server/lib/rsa-keygen.lua")
local aes = requireC("/GuardLink/server/lib/aes.lua")

local handlers = {}

local registrationCount = 0
local windowStart = os.epoch("utc")
local WINDOW_MS = 60 * 60 * 1000

local function decryptCredentials(msg, session)
    local ok, keyStr = pcall(rsa.rsaDecrypt, msg.payload.key.cipher, session.privateKey)
    if not ok or not keyStr then return nil, nil, nil end
    local function decrypt(field)
        return aes.Cipher:new(nil, keyStr, msg.payload[field].iv):decrypt(msg.payload[field].cipher)
    end
    return keyStr, decrypt("username"), decrypt("password")
end

function handlers.login(msg, client, id, ctx, fn, logger)
    local clientManager = ctx.services["client_manager"]
    local session = ctx.services["network_session"]
    local accounts = ctx.services["accounts"]

    local keyStr, username, password = decryptCredentials(msg, session)
    if not keyStr or not username or not password then
        logger:debug("RSA/AES decryption failed")
        return errors.MALFORMED_MESSAGE
    end

    local auth = accounts:authenticateUser(username, password)
    if auth == 0 then
        local client = clientManager:registerClient(username, keyStr)
        if not client.throttle then return client end
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

function handlers.register(msg, client, id, ctx, fn, logger)
    local session = ctx.services["network_session"]
    local accounts = ctx.services["accounts"]
    local settings = ctx.configs["settings"]

    local now = os.epoch("utc")
    if now - windowStart > WINDOW_MS then
        registrationCount = 0
        windowStart = now
    end
    if registrationCount >= settings.registrationsPerHour then
        local msg = message.create("account", {
            action = "register",
            status = "failure",
            error = errors.REGISTRATION_LIMIT_REACHED.client
        }, nil, false, id)
        session:send(session.discovery, msg)
        return 0
    end

    local keyStr, username, password = decryptCredentials(msg, session)
    if not keyStr or not username or not password then
        logger:debug("RSA/AES decryption failed")
        return errors.MALFORMED_MESSAGE
    end

    local invite_code
    if settings.inviteOnly then
        invite_code = aes.Cipher:new(nil, keyStr, msg.payload.invite_code.iv):decrypt(msg.payload.invite_code.cipher)
        if not invite_code then
            local msg = message.create("account", {
                action = "register",
                status = "failure",
                error = errors.MISSING_INVITE_CODE.client
            }, nil, false, id)
            session:send(session.discovery, msg)
            return 0
        end
        if accounts:isValidInvite(invite_code) ~= 0 then
            local msg = message.create("account", {
                action = "register",
                status = "failure",
                error = errors.UNKNOWN_INVITE_CODE.client
            }, nil, false, id)
            session:send(session.discovery, msg)
            return 0
        end
    end

    local success = accounts:createAccount(username, password, nil)
    registrationCount = registrationCount + 1

    if success ~= 0 then
        local msg = message.create("account", {
            action = "register",
            status = "failure",
            error = success.client
        }, nil, false, id)
        session:send(session.discovery, msg)
        return 0
    end

    local msg = message.create("account", {
        action = "register",
        status = "success"
    }, nil, false, id)
    session:send(session.discovery, msg)
    if settings.inviteOnly then accounts:useInvite(invite_code) end
    return 0
end

function handlers.info(msg, client, id, ctx, fn, logger)
    if not client then return 0 end    
    local session = ctx.services["network_session"]

    local name = msg.payload.name

    if name ~= client.account then
        local ethic = ctx.configs["identity"].selectedEthic
        local consent = ctx.configs["rules"].rules.ethics[ethic].consent
        local hasPermission = ctx.services["accounts"]:hasPermission(client.account, "accounts.view_others")
        if consent < 1.0 and not hasPermission then
            local msg = message.create("account", {
                action = "info",
                status = "failure",
                error = errors.INSUFFICIENT_PERMISSIONS.client
            }, client.aesKey, false, id)
            session:send(client.channel, msg)
            return 0
        end
    end

    local accountData = ctx.services["accounts"]:getSanitizedAccountValues(name)
    local msg
    if accountData then
        msg = message.create("account", {
            action = "info",
            status = "success",
            data = accountData
        }, client.aesKey, false, id)
    else
        msg = message.create("account", {
            action = "info",
            status = "failure",
            error = errors.ACCOUNT_NOT_FOUND.client
        }, client.aesKey, false, id)
    end
    session:send(client.channel, msg)
    return 0
end

function handlers.list(msg, client, id, ctx, fn, logger)
    if not client then return 0 end    
    local session = ctx.services["network_session"]
    local ethic = ctx.configs["identity"].selectedEthic
    local consent = ctx.configs["rules"].rules.ethics[ethic].consent
    local hasPermission = ctx.services["accounts"]:hasPermission(client.account, "accounts.view_others")

    if consent < 1.0 and not hasPermission then
        local msg = message.create("account", {
            action = "list",
            status = "failure",
            error = errors.INSUFFICIENT_PERMISSIONS.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local msg = message.create("account", {
        action = "list",
        status = "success",
        data = ctx.services["accounts"]:listAccounts()
    }, client.aesKey, false, id)
    session:send(client.channel, msg)
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