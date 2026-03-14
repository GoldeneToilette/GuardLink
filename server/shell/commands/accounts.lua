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
            "\16705Wallets: \16706" .. table.concat(values.wallets or {}, ", ")
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

cmds["code"] = {
    desc = "Manage invite codes: account code <create|delete|list> [code] [uses]",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local sub = args[2]
        if not sub then return {str="Usage: account code <create|delete|list> [code] [uses]", type="fail"} end

        if sub == "create" then
            local code, uses = args[3], tonumber(args[4])
            local success = kernel:execute("accounts.create_invite", {code=code, uses=uses})
            if success ~= 0 then
                return {str="Error: '" .. success.log .. "'", type="fail"}
            end
            return {str="Invite code created: " .. (code or "random") .. " with " .. (uses or 1) .. " use(s)", type="success"}

        elseif sub == "delete" then
            local code = args[3]
            if not code then return {str="Error: no code provided", type="fail"} end
            local success = kernel:execute("accounts.delete_invite", {code=code})
            if success ~= 0 then
                return {str="Error: '" .. success.log .. "'", type="fail"}
            end
            return {str="Invite code deleted: " .. code, type="success"}

        elseif sub == "list" then
            local codes = kernel:execute("accounts.get_invite_codes")
            if not codes then
                return {str="No invite codes found", type="info"}
            end
            local output = {"Invite codes -------------------------"}
            for code, data in pairs(codes) do
                table.insert(output, "\16705" .. code .. ": \16706" .. data.uses .. " use(s) remaining")
            end
            table.insert(output, "--------------------------------------")
            return {str=output, type="info"}

        else
            return {str="Unknown subcommand: " .. sub .. " (create|delete|list)", type="fail"}
        end
    end
}

cmds["role"] = {
    desc = "Manage account roles: account role <assign|unassign|view> <name> [role]",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local sub = args[2]
        if not sub then return {str="Usage: account role <assign|unassign|view> <name> [role]", type="fail"} end

        if sub == "assign" then
            local name, role = args[3], args[4]
            if not name or not role then return {str="Usage: account role assign <name> <role>", type="fail"} end
            local success = kernel:execute("accounts.assign_role", {name=name, role=role})
            if success ~= 0 then
                return {str="Error: '" .. success.log .. "'", type="fail"}
            end
            return {str=name .. " has been assigned role: " .. role, type="success"}

        elseif sub == "unassign" then
            local name = args[3]
            if not name then return {str="Usage: account role unassign <name>", type="fail"} end
            local success = kernel:execute("accounts.unassign_role", {name=name})
            if success ~= 0 then
                return {str="Error: '" .. success.log .. "'", type="fail"}
            end
            return {str=name .. " has been unassigned from their role", type="success"}

        elseif sub == "view" then
            local name = args[3]
            if not name then return {str="Usage: account role view <name>", type="fail"} end
            local account = kernel:execute("accounts.get_sanitized", {name=name})
            if not account then return {str="Error: Account not found: " .. name, type="fail"} end
            local role = account.role
            if not role or role == "" then
                return {str=name .. " has no role assigned", type="info"}
            end
            return {str=name .. " has role: " .. role, type="info"}

        else
            return {str="Unknown subcommand: " .. sub .. " (assign|unassign|view)", type="fail"}
        end
    end
}

cmds["help"] = {
    func = function(args, ctx)
        local output = {"Account commands -------------------------"}
        for k,v in pairs(cmds) do
            if type(v) == "table" and v.desc then
                table.insert(output, "\16705"..k .. ": \16706" .. v.desc)             
            end
        end
        table.insert(output, "Account commands -------------------------")
        return {str=output, type="info"}
    end
}

function cmds.run(args, ctx)
    if not args[1] or args[1] == "" then return {str="Unknown command: accounts ", type="fail"} end
    if not cmds[args[1]] then return {str=("Unknown command: account " .. args[1]), type="fail"} end
    return cmds[args[1]].func(args, ctx)
end

return cmds