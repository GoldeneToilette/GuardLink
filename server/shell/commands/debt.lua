local cmds = {}
cmds.name = "debt"

local function parseEntity(str)
    if not str then return nil end
    if str == "government" then return {type = "government"} end
    local etype, name = str:match("^(%a+):(.+)$")
    if etype and name then return {type = etype, name = name} end
    return nil
end

local function formatEntity(entity)
    if entity.type == "government" then return "government" end
    return entity.type .. ":" .. entity.name
end

cmds["view"] = {
    desc = "View a debt entry: debt view <debtID>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local id = args[2]
        if not id then return {str="Usage: debt view <debtID>", type="fail"} end
        local entry = kernel:execute("debt.get", {id=id})
        if not entry or entry.client then
            return {str="Error: '" .. (entry and entry.log or "unknown error") .. "'", type="fail"}
        end
        local output = {
            "\16705ID: \16706" .. entry.id,
            "\16705Debtor: \16706" .. formatEntity(entry.debtor),
            "\16705Creditor: \16706" .. formatEntity(entry.creditor),
            "\16705Amount: \16706" .. tostring(entry.amount),
            "\16705Reason: \16706" .. entry.reason,
            "\16705Since: \16706" .. os.date("%Y-%m-%d %H:%M:%S", math.floor(entry.since / 1000)),
            "\16705Sweep: \16706" .. tostring(entry.sweep),
            "\16705Persistence: \16706" .. tostring(entry.persistence)
        }
        return {str=output, type="info"}
    end
}

cmds["list"] = {
    desc = "List all debts",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local entries = kernel:execute("debt.list")
        if not entries or #entries == 0 then
            return {str="No debts found", type="info"}
        end
        local output = {"Debts -------------------------"}
        for _, entry in ipairs(entries) do
            table.insert(output, "\16705" .. entry.id .. "\16706 | " .. formatEntity(entry.debtor) .. " -> " .. formatEntity(entry.creditor) .. " | " .. tostring(entry.amount))
        end
        table.insert(output, "-------------------------------")
        return {str=output, type="info"}
    end
}

cmds["add"] = {
    desc = "Manually create a debt: debt add <debtor> <creditor> <amount> <reason> [sweep]",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local debtorStr, creditorStr, amount, reason, sweep = args[2], args[3], tonumber(args[4]), args[5], args[6]
        if not debtorStr or not creditorStr or not amount or not reason then
            return {str="Usage: debt add <debtor> <creditor> <amount> <reason> [sweep]", type="fail"}
        end
        local debtor = parseEntity(debtorStr)
        local creditor = parseEntity(creditorStr)
        if not debtor then return {str="Invalid debtor format", type="fail"} end
        if not creditor then return {str="Invalid creditor format", type="fail"} end
        local result = kernel:execute("debt.add", {debtor=debtor, creditor=creditor, amount=amount, reason=reason, sweep=sweep == "true"})
        if type(result) ~= "string" then
            return {str="Error: '" .. result.log .. "'", type="fail"}
        end
        return {str="Debt created: " .. result, type="success"}
    end
}

cmds["collect"] = {
    desc = "Manually collect a debt: debt collect <debtID>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local id = args[2]
        if not id then return {str="Usage: debt collect <debtID>", type="fail"} end
        local result = kernel:execute("debt.collect", {id=id})
        if result ~= 0 then
            return {str="Error: '" .. result.log .. "'", type="fail"}
        end
        return {str="Collection attempted for debt " .. id, type="success"}
    end
}

cmds["sweep"] = {
    desc = "Manually trigger a debt sweep",
    func = function(args, ctx)
        local kernel = ctx.kernel
        kernel:execute("debt.sweep")
        return {str="Debt sweep triggered", type="success"}
    end
}

cmds["remove"] = {
    desc = "Forgive/remove a debt: debt remove <debtID>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local id = args[2]
        if not id then return {str="Usage: debt remove <debtID>", type="fail"} end
        local result = kernel:execute("debt.remove", {id=id})
        if result ~= 0 then
            return {str="Error: '" .. result.log .. "'", type="fail"}
        end
        return {str="Debt " .. id .. " removed", type="success"}
    end
}

cmds["transfer"] = {
    desc = "Transfer debt or claim: debt transfer <debt|claim> <debtID> <entity>\n  Entity format: 'government' or 'account:name' or 'company:name'",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local sub, id, entityStr = args[2], args[3], args[4]
        if not sub or not id or not entityStr then
            return {str="Usage: debt transfer <debt|claim> <debtID> <entity>", type="fail"}
        end
        local entity = parseEntity(entityStr)
        if not entity then
            return {str="Invalid entity format. Use 'government', 'account:name', or 'company:name'", type="fail"}
        end
        if sub == "debt" then
            local result = kernel:execute("debt.transfer_debt", {id=id, debtor=entity})
            if result ~= 0 then return {str="Error: '" .. result.log .. "'", type="fail"} end
            return {str="Debt " .. id .. " transferred to " .. entityStr, type="success"}
        elseif sub == "claim" then
            local result = kernel:execute("debt.transfer_receivable", {id=id, creditor=entity})
            if result ~= 0 then return {str="Error: '" .. result.log .. "'", type="fail"} end
            return {str="Claim on " .. id .. " transferred to " .. entityStr, type="success"}
        else
            return {str="Unknown subcommand: " .. sub .. " (debt|claim)", type="fail"}
        end
    end
}

cmds["settle"] = {
    desc = "Settle a debt out of system: debt settle <debtID> <amount>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local id, amount = args[2], tonumber(args[3])
        if not id or not amount then return {str="Usage: debt settle <debtID> <amount>", type="fail"} end
        local result = kernel:execute("debt.settle", {id=id, amount=amount})
        if result ~= 0 then return {str="Error: '" .. result.log .. "'", type="fail"} end
        return {str="Debt " .. id .. " settled for " .. tostring(amount), type="success"}
    end
}

cmds["reset"] = {
    desc = "Reset persistence on a debt: debt reset <debtID>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local id = args[2]
        if not id then return {str="Usage: debt reset <debtID>", type="fail"} end
        local result = kernel:execute("debt.reset_persistence", {id=id})
        if result ~= 0 then
            return {str="Error: '" .. result.log .. "'", type="fail"}
        end
        return {str="Persistence reset for debt " .. id, type="success"}
    end
}

cmds["help"] = {
    func = function(args, ctx)
        local output = {"Debt commands -------------------------"}
        for k, v in pairs(cmds) do
            if type(v) == "table" and v.desc then
                table.insert(output, "\16705" .. k .. ": \16706" .. v.desc)
            end
        end
        table.insert(output, "---------------------------------------")
        return {str=output, type="info"}
    end
}

function cmds.run(args, ctx)
    if not args[1] or args[1] == "" then return {str="Unknown command: debt", type="fail"} end
    if not cmds[args[1]] then return {str="Unknown command: debt " .. args[1], type="fail"} end
    return cmds[args[1]].func(args, ctx)
end

return cmds
