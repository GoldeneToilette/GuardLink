local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network/message.lua")
local rsa = requireC("/GuardLink/server/lib/rsa-keygen.lua")
local aes = requireC("/GuardLink/server/lib/aes.lua")
local audit = requireC("/GuardLink/server/lib/audit.lua")

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

function handlers.login(msg, client, id, ctx, fn, logger, sender, senderID)
    if sender == "client" then
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
            if msg.payload.publicKey then
                local keyData = aes.Cipher:new(nil, keyStr, msg.payload.publicKey.iv):decrypt(msg.payload.publicKey.cipher)
                local pubKey = textutils.unserialize(keyData)
                if pubKey then
                    local keys = accounts:getAccountValue(username, "publicKeys") or {}
                    local known = false
                    for _, k in ipairs(keys) do
                        if k.shared == pubKey.shared and k.public == pubKey.public then
                            k.timestamp = os.epoch("utc")
                            known = true
                            break
                        end
                    end
                    if not known then
                        keys[#keys + 1] = { shared = pubKey.shared, public = pubKey.public, timestamp = os.epoch("utc") }
                    end
                    accounts:setAccountValue(username, "publicKeys", keys)
                end
            end
            local client = clientManager:registerClient(username, keyStr, senderID)
            if not client.throttle then return client end
            local msg = message.create("account", {
                action = "login",
                status = "success",
                token = client.token,
                channel = client.channel,
                clientID = client.id
            }, client.aesKey, false, id, senderID)
            session:send(session.discovery, msg)
        else
            local msg = message.create("account", {
                action = "login",
                status = "failure",
                error = auth.client
            }, nil, false, id, senderID)
            session:send(session.discovery, msg)
        end        
    end
    return 0
end

function handlers.register(msg, client, id, ctx, fn, logger, sender, senderID)
    if sender == "client" then
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
            }, nil, false, id, senderID)
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
                }, nil, false, id, senderID)
                session:send(session.discovery, msg)
                return 0
            end
            if accounts:isValidInvite(invite_code) ~= 0 then
                local msg = message.create("account", {
                    action = "register",
                    status = "failure",
                    error = errors.UNKNOWN_INVITE_CODE.client
                }, nil, false, id, senderID)
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
            }, nil, false, id, senderID)
            session:send(session.discovery, msg)
            return 0
        end

        local msg = message.create("account", {
            action = "register",
            status = "success"
        }, nil, false, id, senderID)
        session:send(session.discovery, msg)
        if settings.inviteOnly then accounts:useInvite(invite_code) end        
    end
    return 0
end

function handlers.info(msg, client, id, ctx, fn, logger, sender, senderID)
    if not client then return 0 end    
    local session = ctx.services["network_session"]

    local name = msg.payload.name

    if name ~= client.account then
        local consent = ctx.services["nation"]:getValue("consent")
        local hasPermission = ctx.services["accounts"]:hasPermission(client.account, "accounts.view_others")
        if consent < 1.0 and not hasPermission then
            local msg = message.create("account", {
                action = "info",
                status = "failure",
                error = errors.INSUFFICIENT_PERMISSIONS.client
            }, client.aesKey, false, id, senderID)
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
        }, client.aesKey, false, id, senderID)
    else
        msg = message.create("account", {
            action = "info",
            status = "failure",
            error = errors.ACCOUNT_NOT_FOUND.client
        }, client.aesKey, false, id, senderID)
    end
    session:send(client.channel, msg)
    return 0
end

function handlers.list(msg, client, id, ctx, fn, logger, sender, senderID)
    if not client then return 0 end    
    local session = ctx.services["network_session"]
    local consent = ctx.services["nation"]:getValue("consent")
    local hasPermission = ctx.services["accounts"]:hasPermission(client.account, "accounts.view_others")

    if consent < 1.0 and not hasPermission then
        local msg = message.create("account", {
            action = "list",
            status = "failure",
            error = errors.INSUFFICIENT_PERMISSIONS.client
        }, client.aesKey, false, id, senderID)
        session:send(client.channel, msg)
        return 0
    end

    local msg = message.create("account", {
        action = "list",
        status = "success",
        data = ctx.services["accounts"]:listAccounts()
    }, client.aesKey, false, id, senderID)
    session:send(client.channel, msg)
    return 0
end

function handlers.change_password(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    if not client then return 0 end

    local oldPassword = msg.payload.old_password
    local newPassword = msg.payload.new_password
    if not oldPassword or not newPassword then return errors.MALFORMED_MESSAGE end

    local result = ctx.services["accounts"]:changePassword(client.account, oldPassword, newPassword)
    if result ~= 0 then
        local msg = message.create("account", {
            action = "change_password",
            status = "failure",
            error = result.client
        }, client.aesKey, false, id, senderID)
        session:send(client.channel, msg)
        return 0
    end

    local msg = message.create("account", {
        action = "change_password",
        status = "success"
    }, client.aesKey, false, id, senderID)
    session:send(client.channel, msg)
    return 0
end

function handlers.audit(msg, client, id, ctx, fn, logger, sender, senderID)
    if not client then return 0 end
    local session = ctx.services["network_session"]

    local name = msg.payload.name
    local hasPermission = ctx.services["accounts"]:hasPermission(client.account, "accounts.view_others")

    if name ~= client.account and not hasPermission and not ctx.services["nation"]:logsAccessible() then
        local msg = message.create("account", {
            action = "audit",
            status = "failure",
            error = errors.INSUFFICIENT_PERMISSIONS.client
        }, client.aesKey, false, id, senderID)
        session:send(client.channel, msg)
        return 0
    end

    local entries = audit.get("accounts", name, ctx.services["vfs"])
    local msg = message.create("account", {
        action = "audit",
        status = "success",
        data = entries
    }, client.aesKey, false, id, senderID)
    session:send(client.channel, msg)
    return 0
end

local function func(msg, client, id, ctx, fn, logger, sender, senderID)
    if not handlers[msg.payload.action] then return errors.MALFORMED_MESSAGE end
    if client and msg.payload.token ~= client.token then
        return errors.TOKEN_MISMATCH
    end
    return handlers[msg.payload.action](msg, client, id, ctx, fn, logger, sender, senderID)
end

return func