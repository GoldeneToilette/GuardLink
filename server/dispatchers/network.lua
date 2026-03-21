local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network/message.lua")
local audit = requireC("/GuardLink/server/lib/audit.lua")

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