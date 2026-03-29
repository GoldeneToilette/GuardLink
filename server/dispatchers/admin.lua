local errors = requireC("/GuardLink/server/lib/errors.lua")
local message = requireC("/GuardLink/server/network/message.lua")

local function func(msg, client, id, ctx, fn, logger)
    if not client then return errors.UNKNOWN_CLIENT end
    if msg.payload.token ~= client.token then return errors.TOKEN_MISMATCH end

    local service = msg.payload.action
    local command = msg.payload.command
    local args = msg.payload.args

    if not service or not command then return errors.MALFORMED_MESSAGE end

    local permission = service .. "." .. command
    if not ctx.services["accounts"]:hasPermission(client.account, permission) then
        local msg = message.create("admin", {
            action = service,
            command = command,
            status = "failure",
            error = errors.INSUFFICIENT_PERMISSIONS.client
        }, client.aesKey, false, id)
        ctx.services["network_session"]:send(client.channel, msg)
        return 0
    end

    local result = ctx:execute(permission, args)
    local msg = message.create("admin", {
        action = service,
        command = command,
        status = "success",
        data = result
    }, client.aesKey, false, id)
    ctx.services["network_session"]:send(client.channel, msg)
    return 0
end

return func