local cmds = {}
cmds.name = "wallets"

cmds["view"] = {
    desc = "View wallet information: wallets view <name>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local name = args[2]
        if not name then return {str="Usage: wallets view <name>", type="fail"} end
        local wallet = kernel:execute("wallets.get", {wallet=name})
        if not wallet then
            return {str="Error: Wallet not found: " .. name, type="fail"}
        end
        local members = {}
        for member, role in pairs(wallet.members or {}) do
            table.insert(members, member .. " (" .. role .. ")")
        end
        local output = {
            "\16705Name: \16706" .. wallet.name,
            "\16705ID: \16706" .. wallet.id,
            "\16705Balance: \16706" .. tostring(wallet.balance),
            "\16705Locked: \16706" .. tostring(wallet.locked),
            "\16705Created: \16706" .. wallet.creationDate .. " " .. wallet.creationTime,
            "\16705Members: \16706" .. (next(members) and table.concat(members, ", ") or "none"),
        }
        return {str=output, type="info"}
    end
}

cmds["list"] = {
    desc = "List all wallets",
    func = function(args, ctx)
        local wallets = ctx.kernel:execute("wallets.list")
        if not wallets or #wallets == 0 then
            return {str="No wallets found", type="info"}
        end
        local output = {"Wallets -------------------------"}
        for _, name in ipairs(wallets) do
            table.insert(output, "\16706" .. name)
        end
        table.insert(output, "---------------------------------")
        return {str=output, type="info"}
    end
}

cmds["create"] = {
    desc = "Create a wallet: wallets create <name>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local name = args[2]
        if not name then return {str="Usage: wallets create <name>", type="fail"} end
        local success = kernel:execute("wallets.create", {name=name})
        if success ~= 0 then
            return {str="Error: '" .. success.log .. "'", type="fail"}
        end
        return {str="Wallet created: " .. name, type="success"}
    end
}

cmds["delete"] = {
    desc = "Delete a wallet: wallets delete <name>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local name = args[2]
        if not name then return {str="Usage: wallets delete <name>", type="fail"} end
        local success = kernel:execute("wallets.delete", {wallet=name})
        if success ~= 0 then
            return {str="Error: '" .. success.log .. "'", type="fail"}
        end
        return {str="Wallet deleted: " .. name, type="success"}
    end
}

cmds["balance"] = {
    desc = "Change wallet balance: wallets balance <set|add|subtract> <name> <amount>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local op, name, value = args[2], args[3], tonumber(args[4])
        if not op or not name or not value then
            return {str="Usage: wallets balance <set|add|subtract> <name> <amount>", type="fail"}
        end
        if op ~= "set" and op ~= "add" and op ~= "subtract" then
            return {str="Invalid operation: " .. op .. " (set|add|subtract)", type="fail"}
        end
        local success = kernel:execute("wallets.change_balance", {op=op, wallet=name, value=value})
        if success ~= 0 then
            return {str="Error: '" .. success.log .. "'", type="fail"}
        end
        return {str="Balance updated for " .. name, type="success"}
    end
}

cmds["transfer"] = {
    desc = "Transfer funds: wallets transfer <sender> <receiver> <amount>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local sender, receiver, value = args[2], args[3], tonumber(args[4])
        if not sender or not receiver or not value then
            return {str="Usage: wallets transfer <sender> <receiver> <amount>", type="fail"}
        end
        local success = kernel:execute("wallets.transfer", {sender=sender, receiver=receiver, value=value})
        if success ~= 0 then
            return {str="Error: '" .. success.log .. "'", type="fail"}
        end
        return {str="Transferred " .. value .. " from " .. sender .. " to " .. receiver, type="success"}
    end
}

cmds["member"] = {
    desc = "Manage wallet members: wallets member <add|remove> <wallet> <account> [role]",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local sub, wallet, account = args[2], args[3], args[4]
        if not sub or not wallet or not account then
            return {str="Usage: wallets member <add|remove> <wallet> <account> [role]", type="fail"}
        end
        if sub == "add" then
            local role = args[5] or "associate"
            local success = kernel:execute("wallets.add_member", {wallet=wallet, member=account, role=role})
            if success ~= 0 then
                return {str="Error: '" .. success.log .. "'", type="fail"}
            end
            return {str=account .. " added to " .. wallet .. " as " .. role, type="success"}
        elseif sub == "remove" then
            local success = kernel:execute("wallets.remove_member", {wallet=wallet, member=account})
            if success ~= 0 then
                return {str="Error: '" .. success.log .. "'", type="fail"}
            end
            return {str=account .. " removed from " .. wallet, type="success"}
        else
            return {str="Unknown subcommand: " .. sub .. " (add|remove)", type="fail"}
        end
    end
}

cmds["lock"] = {
    desc = "Lock or unlock a wallet: wallets lock <name> <true|false>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local name, flag = args[2], args[3]
        if not name then return {str="Usage: wallets lock <name> <true|false>", type="fail"} end
        local value = flag ~= "false"
        local success = kernel:execute("wallets.lock", {wallet=name, flag=value})
        if success ~= 0 then
            return {str="Error: '" .. success.log .. "'", type="fail"}
        end
        return {str=name .. " is now " .. (value and "locked" or "unlocked"), type="success"}
    end
}

cmds["help"] = {
    func = function(args, ctx)
        local output = {"Wallet commands -------------------------"}
        for k, v in pairs(cmds) do
            if type(v) == "table" and v.desc then
                table.insert(output, "\16705" .. k .. ": \16706" .. v.desc)
            end
        end
        table.insert(output, "-----------------------------------------")
        return {str=output, type="info"}
    end
}

function cmds.run(args, ctx)
    if not args[1] or args[1] == "" then return {str="Unknown command: wallets", type="fail"} end
    if not cmds[args[1]] then return {str="Unknown command: wallets " .. args[1], type="fail"} end
    return cmds[args[1]].func(args, ctx)
end

return cmds