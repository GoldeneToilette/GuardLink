local cmds = {}
cmds.name = "nation"

cmds["info"] = {
    desc = "View nation identity and configuration",
    func = function(args, ctx)
        local identity = ctx.kernel:execute("nation.get")
        return {str = {
            "\16705Nation: \16706"   .. (identity.nation_name or "?"),
            "\16705Tag: \16706"      .. (identity.nation_tag or "?"),
            "\16705Ethic: \16706"    .. (identity.selectedEthic or "?"),
            "\16705Currency: \16706" .. (identity.currency_name or "?"),
            "\16705Starting Balance: \16706" .. tostring(identity.starting_balance or 0),
            "\16705Treasury: \16706" .. (identity.treasury or "none"),
            "\16705Default Role: \16706" .. tostring(identity.defaultRole or "none"),
        }, type = "info"}
    end
}

cmds["stats"] = {
    desc = "View nation statistics",
    func = function(args, ctx)
        local stats = ctx.kernel:execute("nation.stats")
        return {str = {
            "\16705Citizens: \16706"    .. tostring(stats.citizens),
            "\16705Circulation: \16706" .. tostring(stats.circulation),
            "\16705Treasury: \16706"    .. tostring(stats.treasury),
        }, type = "info"}
    end
}

cmds["ethic"] = {
    desc = "View current ethic values",
    func = function(args, ctx)
        local values = ctx.kernel:execute("nation.ethic")
        local output = {}
        for k, v in pairs(values) do
            table.insert(output, "\16705" .. k .. ": \16706" .. tostring(v))
        end
        return {str = output, type = "info"}
    end
}

cmds["set"] = {
    desc = "Set a nation config value: nation set <tag|currency|starting_balance> <value>",
    func = function(args, ctx)
        local key, value = args[2], args[3]
        if not key or not value then
            return {str = "Usage: nation set <tag|currency|starting_balance> <value>", type = "fail"}
        end
        local cmd = ({
            tag               = "nation.set_tag",
            currency          = "nation.set_currency",
            starting_balance  = "nation.set_starting_balance",
        })[key]
        if not cmd then
            return {str = "Unknown key: " .. key, type = "fail"}
        end
        local result = ctx.kernel:execute(cmd, value)
        if not result then
            return {str = "Invalid value for: " .. key, type = "fail"}
        end
        return {str = key .. " updated to: " .. value, type = "success"}
    end
}

cmds["help"] = {
    func = function(args, ctx)
        local output = {"Nation commands -------------------------"}
        for k, v in pairs(cmds) do
            if type(v) == "table" and v.desc then
                table.insert(output, k .. ": \16706" .. v.desc)
            end
        end
        table.insert(output, "Nation commands -------------------------")
        return {str = output, type = "info"}
    end
}

cmds.run = function(args, ctx)
    local sub = args[1]
    if cmds[sub] then
        return cmds[sub].func(args, ctx)
    end
    return {str = "Unknown command: nation " .. (args[1] or " "), type = "fail"}
end

return cmds
