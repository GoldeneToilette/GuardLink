local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network/message.lua")

local handlers = {}

local function hasPermission(ctx, account, perm)
    return ctx.services["accounts"]:hasPermission(account, perm)
end

local function fail(session, client, id, action, err, senderID)
    local msg = message.create("law", {
        action = action, status = "failure", error = err.client or err
    }, client.aesKey, false, id, senderID)
    session:send(client.channel, msg)
    return 0
end

local function success(session, client, id, action, data, senderID)
    local msg = message.create("law", {
        action = action, status = "success", data = data
    }, client.aesKey, false, id, senderID)
    session:send(client.channel, msg)
    return 0
end

-- public
function handlers.list(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    local laws = ctx.services["law"]:listLaws(msg.payload.type)
    return success(session, client, id, "list", laws, senderID)
end

function handlers.get(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    local result = ctx.services["law"]:getLaw(msg.payload.id)
    if result.client then return fail(session, client, id, "get", result) end
    return success(session, client, id, "get", result, senderID)
end

function handlers.list_categories(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    return success(session, client, id, "list_categories", ctx.services["law"]:getCfg().categories, senderID)
end

function handlers.get_by_category(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    local result = ctx.services["law"]:getLawsByCategory(msg.payload.id)
    if type(result) ~= "table" or result.client then return fail(session, client, id, "get_by_category", result) end
    return success(session, client, id, "get_by_category", result, senderID)
end

-- restricted
function handlers.new_law(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    if not hasPermission(ctx, client.account, "law.create") then
        return fail(session, client, id, "new_law", errors.INSUFFICIENT_PERMISSIONS, senderID)
    end
    local result = ctx.services["law"]:newLaw(msg.payload.law)
    if type(result) ~= "string" then return fail(session, client, id, "new_law", result, senderID) end
    return success(session, client, id, "new_law", {id = result}, senderID)
end

function handlers.delete_law(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    if not hasPermission(ctx, client.account, "law.delete") then
        return fail(session, client, id, "delete_law", errors.INSUFFICIENT_PERMISSIONS, senderID)
    end
    local result = ctx.services["law"]:deleteLaw(msg.payload.id)
    if result ~= 0 then return fail(session, client, id, "delete_law", result, senderID) end
    return success(session, client, id, "delete_law", nil, senderID)
end

function handlers.set_active(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    if not hasPermission(ctx, client.account, "law.toggle") then
        return fail(session, client, id, "set_active", errors.INSUFFICIENT_PERMISSIONS, senderID)
    end
    local result = ctx.services["law"]:setActive(msg.payload.id, msg.payload.state)
    if result ~= 0 then return fail(session, client, id, "set_active", result, senderID) end
    return success(session, client, id, "set_active", nil, senderID)
end

function handlers.new_category(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    if not hasPermission(ctx, client.account, "law.manage_categories") then
        return fail(session, client, id, "new_category", errors.INSUFFICIENT_PERMISSIONS, senderID)
    end
    local result = ctx.services["law"]:newCategory(msg.payload.name)
    if result ~= 0 then return fail(session, client, id, "new_category", result, senderID) end
    return success(session, client, id, "new_category", nil, senderID)
end

function handlers.delete_category(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    if not hasPermission(ctx, client.account, "law.manage_categories") then
        return fail(session, client, id, "delete_category", errors.INSUFFICIENT_PERMISSIONS, senderID)
    end
    local result = ctx.services["law"]:deleteCategory(msg.payload.id)
    if result ~= 0 then return fail(session, client, id, "delete_category", result, senderID) end
    return success(session, client, id, "delete_category", nil, senderID)
end

function handlers.add_violation(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    if not hasPermission(ctx, client.account, "law.manage_violations") then
        return fail(session, client, id, "add_violation", errors.INSUFFICIENT_PERMISSIONS, senderID)
    end
    local p = msg.payload
    local result = ctx.services["law"]:addViolation(p.entity, p.law_id, client.account, p.notes)
    if result ~= 0 then return fail(session, client, id, "add_violation", result, senderID) end
    return success(session, client, id, "add_violation", nil, senderID)
end

function handlers.remove_violation(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    if not hasPermission(ctx, client.account, "law.manage_violations") then
        return fail(session, client, id, "remove_violation", errors.INSUFFICIENT_PERMISSIONS, senderID)
    end
    local result = ctx.services["law"]:removeViolation(msg.payload.entity, msg.payload.violation_id)
    if result ~= 0 then return fail(session, client, id, "remove_violation", result, senderID) end
    return success(session, client, id, "remove_violation", nil, senderID)
end

function handlers.list_violations(msg, client, id, ctx, fn, logger, sender, senderID)
    local session = ctx.services["network_session"]
    local entity = msg.payload.entity
    local isSelf = entity.type == "account" and entity.name == client.account
    if not isSelf and not ctx.services["nation"]:logsAccessible() then
        return fail(session, client, id, "list_violations", errors.INSUFFICIENT_PERMISSIONS, senderID)
    end
    local result = ctx.services["law"]:listViolations(entity)
    if type(result) ~= "table" or result.client then return fail(session, client, id, "list_violations", result, senderID) end
    return success(session, client, id, "list_violations", result, senderID)
end

local function func(msg, client, id, ctx, fn, logger, sender, senderID)
    if not handlers[msg.payload.action] then return errors.MALFORMED_MESSAGE end
    if client and msg.payload.token ~= client.token then return errors.TOKEN_MISMATCH end
    return handlers[msg.payload.action](msg, client, id, ctx, fn, logger, sender, senderID)
end

return func
