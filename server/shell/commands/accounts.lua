local cmds = {}
cmds.name = "accounts"

cmds["view"] = {
    desc = "View someone's account information",
    func = function(args, ctx)
        local kernel, cwd = ctx.kernel, ctx.cwd
        local name = tostring(args[2])
        local values = kernel:execute("accounts.get_sanitized", {name=name})
        if not values then
            return {str="Error: 'Account not found: " .. name .. "'", type="fail"}
        end
        local output = {
            "\16705Name: \16706" .. values.name,
            "\16705UUID: \16706" .. values.uuid,
            "\16705Created: \16706" .. values.creationDate .. " " .. values.creationTime,
            "\16705Banned: \16706" .. tostring(values.ban.active),
            "\16705Role: \16706" .. values.role,
            "\16705Wallets: \16706" .. table.concat(values.wallets, ", ")
        }
        if values.ban.active then
            table.insert(output, "Duration: " .. values.ban.duration)
            table.insert(output, "Reason: " .. values.ban.reason)
        end
        return {str=output, type="info"}
    end
}
cmds["info"] = cmds.view
cmds["info"].desc = nil

cmds["ban"] = {
    desc = "Ban an account: account ban <name> <duration> <time unit> <reason>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local name, value, unit, reason = args[2], tonumber(args[3]) or 1, args[4] or "permanent", args[5] or "unknown"
        local duration = {}
        duration[unit] = value
        local success = kernel:execute("accounts.ban", {name=name, duration=duration, reason=reason})
        if success ~= 0 then
            return {str="Error: '" .. success.log .. "'", type="fail"}
        end
        return {str=name .. " has been banned for: " .. reason, type="success"}
    end
}

cmds["unban"] = {
    desc = "Unban an account",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local name = args[2]
        local success = kernel:execute("accounts.pardon", {name=name})
        if success ~= 0 then
            return {str="Error: " .. success.log, type="fail"}
        end
        return {str=name .. " has been unbanned", type="success"}
    end
}
cmds["pardon"] = cmds["unban"]
cmds["pardon"].desc = nil

cmds["delete"] = {
    desc = "Permanently delete an account",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local name = args[2] or ""
        local success = kernel:execute("accounts.delete", {name=name})
        if success ~= 0 then
            return {str="Error: '" .. success.log .. "'", type="fail"}
        end
        return {str=name .. " has been deleted", type="success"}
    end
}

cmds["create"] = {
    desc = "Create a new account: account create <name> <password>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local name, pass = args[2], args[3]
        local success = kernel:execute("accounts.create", {name=name, password=pass})
        if success ~= 0 then
            return {str= ("Error: '" .. success.log .. "'"), type="fail"}
        end
        return {str="Successfully created account " .. name, type="success"}
    end
}

cmds["help"] = {
    func = function(args, ctx)
        local output = {}
        for k,v in pairs(cmds) do
            if type(v) == "table" and v.desc then
                table.insert(output, "\16705"..k .. ": \16706" .. v.desc)             
            end
        end
        return {str=output, type="info"}
    end
}

function cmds.run(args, ctx)
    if not args[1] or args[1] == "" then return {str="Unknown command: accounts ", type="fail"} end
    if not cmds[args[1]] then return {str=("Unknown command: account " .. args[1]), type="fail"} end
    return cmds[args[1]].func(args, ctx)
end

return cmds