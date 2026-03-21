local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network/message.lua")
local audit = requireC("/GuardLink/server/lib/audit.lua")

local handlers = {}

local walletCount = 0
local windowStart = os.epoch("utc")
local WINDOW_MS = 60 * 60 * 1000

local function isMember(wallet, account)
    return wallet.members and wallet.members[account] ~= nil
end

local function isOwner(wallet, account)
    return wallet.members and wallet.members[account] == "owner"
end

function handlers.info(msg, client, id, ctx, fn, logger)
    local session = ctx.services["network_session"]
    if not client then return 0 end

    local name = msg.payload.wallet
    local wallets = ctx.services["wallets"]
    local wallet = wallets:getWalletData(name)

    if not wallet then
        local msg = message.create("wallet", {
            action = "info", status = "failure",
            error = errors.WALLET_NOT_FOUND.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local hasPermission = ctx.services["accounts"]:hasPermission(client.account, "wallets.view_others")
    if not isMember(wallet, client.account) and not hasPermission then
        local msg = message.create("wallet", {
            action = "info", status = "failure",
            error = errors.INSUFFICIENT_PERMISSIONS.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local msg = message.create("wallet", {
        action = "info", status = "success",
        data = wallet
    }, client.aesKey, false, id)
    session:send(client.channel, msg)
    return 0
end

function handlers.transfer(msg, client, id, ctx, fn, logger)
    local session = ctx.services["network_session"]
    if not client then return 0 end

    local sender = msg.payload.sender
    local wallets = ctx.services["wallets"]
    local senderWallet = wallets:getWalletData(sender)

    if not senderWallet or not isMember(senderWallet, client.account) then
        local msg = message.create("wallet", {
            action = "transfer", status = "failure",
            error = errors.INSUFFICIENT_PERMISSIONS.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local result = wallets:transferBalance(sender, msg.payload.receiver, msg.payload.value)
    if result ~= 0 then
        local msg = message.create("wallet", {
            action = "transfer", status = "failure",
            error = result.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local msg = message.create("wallet", {
        action = "transfer", status = "success"
    }, client.aesKey, false, id)
    session:send(client.channel, msg)
    return 0
end

function handlers.create(msg, client, id, ctx, fn, logger)
    local session = ctx.services["network_session"]
    if not client then return 0 end

    local hasPermission = ctx.services["accounts"]:hasPermission(client.account, "wallets.create")
    if not hasPermission then
        local msg = message.create("wallet", {
            action = "create", status = "failure",
            error = errors.INSUFFICIENT_PERMISSIONS.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local now = os.epoch("utc")
    if now - windowStart > WINDOW_MS then
        walletCount = 0
        windowStart = now
    end
    local limit = ctx.configs["settings"].walletsPerHour
    if walletCount >= limit then
        local msg = message.create("wallet", {
            action = "create", status = "failure",
            error = errors.WALLET_LIMIT_REACHED.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local name = msg.payload.wallet
    local wallets = ctx.services["wallets"]
    local result = wallets:createWallet(name)
    walletCount = walletCount + 1

    if result ~= 0 then
        local msg = message.create("wallet", {
            action = "create", status = "failure",
            error = result.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    -- add creator as owner and apply starting balance
    wallets:addMember(name, client.account, "owner")
    local startingBalance = tonumber(ctx.configs["identity"].starting_balance) or 0
    if startingBalance > 0 then
        wallets:changeBalance("add", name, startingBalance)
    end

    local msg = message.create("wallet", {
        action = "create", status = "success"
    }, client.aesKey, false, id)
    session:send(client.channel, msg)
    return 0
end

function handlers.delete(msg, client, id, ctx, fn, logger)
    local session = ctx.services["network_session"]
    if not client then return 0 end

    local name = msg.payload.wallet
    local wallets = ctx.services["wallets"]
    local wallet = wallets:getWalletData(name)

    if not wallet then
        local msg = message.create("wallet", {
            action = "delete", status = "failure",
            error = errors.WALLET_NOT_FOUND.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    if not isOwner(wallet, client.account) then
        local msg = message.create("wallet", {
            action = "delete", status = "failure",
            error = errors.INSUFFICIENT_PERMISSIONS.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local result = wallets:deleteWallet(name)
    if result ~= 0 then
        local msg = message.create("wallet", {
            action = "delete", status = "failure",
            error = result.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local msg = message.create("wallet", {
        action = "delete", status = "success"
    }, client.aesKey, false, id)
    session:send(client.channel, msg)
    return 0
end

function handlers.add_member(msg, client, id, ctx, fn, logger)
    local session = ctx.services["network_session"]
    if not client then return 0 end

    local name = msg.payload.wallet
    local wallets = ctx.services["wallets"]
    local wallet = wallets:getWalletData(name)

    if not wallet then
        local msg = message.create("wallet", {
            action = "add_member", status = "failure",
            error = errors.WALLET_NOT_FOUND.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    if not isOwner(wallet, client.account) then
        local msg = message.create("wallet", {
            action = "add_member", status = "failure",
            error = errors.INSUFFICIENT_PERMISSIONS.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local result = wallets:addMember(name, msg.payload.member, msg.payload.role)
    if result ~= 0 then
        local msg = message.create("wallet", {
            action = "add_member", status = "failure",
            error = result.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local msg = message.create("wallet", {
        action = "add_member", status = "success"
    }, client.aesKey, false, id)
    session:send(client.channel, msg)
    return 0
end

function handlers.remove_member(msg, client, id, ctx, fn, logger)
    local session = ctx.services["network_session"]
    if not client then return 0 end

    local name = msg.payload.wallet
    local wallets = ctx.services["wallets"]
    local wallet = wallets:getWalletData(name)

    if not wallet then
        local msg = message.create("wallet", {
            action = "remove_member", status = "failure",
            error = errors.WALLET_NOT_FOUND.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    if not isOwner(wallet, client.account) then
        local msg = message.create("wallet", {
            action = "remove_member", status = "failure",
            error = errors.INSUFFICIENT_PERMISSIONS.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local result = wallets:removeMember(name, msg.payload.member)
    if result ~= 0 then
        local msg = message.create("wallet", {
            action = "remove_member", status = "failure",
            error = result.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local msg = message.create("wallet", {
        action = "remove_member", status = "success"
    }, client.aesKey, false, id)
    session:send(client.channel, msg)
    return 0
end

function handlers.audit(msg, client, id, ctx, fn, logger)
    if not client then return 0 end
    local session = ctx.services["network_session"]

    local name = msg.payload.wallet
    local wallets = ctx.services["wallets"]
    local wallet = wallets:getWalletData(name)

    if not wallet then
        local msg = message.create("wallet", {
            action = "audit",
            status = "failure",
            error = errors.WALLET_NOT_FOUND.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local ethic = ctx.configs["identity"].selectedEthic
    local ethics = ctx.configs["rules"].rules.ethics[ethic].values
    local logsAccessible = ctx.configs["rules"].server.formulas.logsAccessible
    local hasPermission = ctx.services["accounts"]:hasPermission(client.account, "wallets.view_others")

    if not isMember(wallet, client.account) and not hasPermission and not logsAccessible(ethics.autonomy, ethics.consent) then
        local msg = message.create("wallet", {
            action = "audit",
            status = "failure",
            error = errors.INSUFFICIENT_PERMISSIONS.client
        }, client.aesKey, false, id)
        session:send(client.channel, msg)
        return 0
    end

    local entries = audit.get("wallets", name, ctx.services["vfs"])
    local msg = message.create("wallet", {
        action = "audit",
        status = "success",
        data = entries
    }, client.aesKey, false, id)
    session:send(client.channel, msg)
    return 0
end

local function func(msg, client, id, ctx, fn, logger)
    if not handlers[msg.payload.action] then return errors.MALFORMED_MESSAGE end
    return handlers[msg.payload.action](msg, client, id, ctx, fn, logger)
end

return func