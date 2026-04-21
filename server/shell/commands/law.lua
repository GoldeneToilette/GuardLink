local cmds = {}
cmds.name = "law"

cmds["list"] = {
    desc = "List all laws or filter by type: law list [passive|periodic|active]",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local laws = kernel:execute("law.list_laws", {type = args[2]})
        if not laws or #laws == 0 then return {str="No laws found", type="info"} end
        local output = {"Laws -------------------------"}
        for _, l in ipairs(laws) do
            local status = l.active and "\16705[ON]" or "\16708[OFF]"
            table.insert(output, status .. " \16706" .. l.id .. "\16705 [" .. l.type .. "] \16706" .. l.name)
        end
        table.insert(output, "------------------------------")
        return {str=output, type="info"}
    end
}

cmds["view"] = {
    desc = "View a law: law view <id>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local id = args[2]
        if not id then return {str="Usage: law view <id>", type="fail"} end
        local l = kernel:execute("law.get_law", {id=id})
        if not l or l.client then return {str="Error: '" .. (l and l.log or "unknown") .. "'", type="fail"} end
        local output = {
            "\16705ID: \16706" .. l.id,
            "\16705Name: \16706" .. l.name,
            "\16705Type: \16706" .. l.type,
            "\16705Active: \16706" .. tostring(l.active),
            "\16705Category: \16706" .. l.category,
            "\16705Target: \16706" .. l.target.type .. (l.target.filter and " (" .. (l.target.filter.role or "") .. ")" or ""),
            "\16705Description: \16706" .. l.description,
            "\16705Consequence: \16706" .. l.consequence,
        }
        if l.type == "periodic" then
            table.insert(output, "\16705Interval: \16706" .. tostring(l.interval) .. "s")
            table.insert(output, "\16705Grace: \16706"    .. tostring(l.grace) .. " sweeps")
            if l.rate then
                table.insert(output, "\16705Rate: \16706" .. tostring(l.rate * 100) .. "%")
            else
                table.insert(output, "\16705Amount: \16706" .. tostring(l.amount))
            end
        end
        return {str=output, type="info"}
    end
}

cmds["delete"] = {
    desc = "Delete a law: law delete <id>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local id = args[2]
        if not id then return {str="Usage: law delete <id>", type="fail"} end
        local result = kernel:execute("law.delete_law", {id=id})
        if result ~= 0 then return {str="Error: '" .. result.log .. "'", type="fail"} end
        return {str="Law " .. id .. " deleted", type="success"}
    end
}

cmds["toggle"] = {
    desc = "Toggle a law on or off: law toggle <id>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local id = args[2]
        if not id then return {str="Usage: law toggle <id>", type="fail"} end
        local l = kernel:execute("law.get_law", {id=id})
        if not l or l.client then return {str="Error: '" .. (l and l.log or "unknown") .. "'", type="fail"} end
        local result = kernel:execute("law.set_active", {id=id, state=not l.active})
        if result ~= 0 then return {str="Error: '" .. result.log .. "'", type="fail"} end
        return {str="Law " .. id .. " is now " .. (not l.active and "active" or "inactive"), type="success"}
    end
}

cmds["category"] = {
    desc = "Manage categories: law category <list|new|delete|view> [args]",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local sub = args[2]
        if not sub then return {str="Usage: law category <list|new|delete|view>", type="fail"} end

        if sub == "list" then
            local cats = kernel:execute("law.list_categories")
            if not cats or not next(cats) then return {str="No categories found", type="info"} end
            local output = {"Categories -------------------------"}
            for id, cat in pairs(cats) do
                table.insert(output, "\16705" .. id .. ": \16706" .. cat.displayName .. " \16705(" .. #cat.laws .. " laws)")
            end
            table.insert(output, "------------------------------------")
            return {str=output, type="info"}

        elseif sub == "new" then
            local name = args[3]
            if not name then return {str="Usage: law category new <name>", type="fail"} end
            local result = kernel:execute("law.new_category", {name=name})
            if result ~= 0 then return {str="Error: '" .. result.log .. "'", type="fail"} end
            return {str="Category '" .. name .. "' created", type="success"}

        elseif sub == "delete" then
            local id = args[3]
            if not id then return {str="Usage: law category delete <id>", type="fail"} end
            local result = kernel:execute("law.delete_category", {id=id})
            if result ~= 0 then return {str="Error: '" .. result.log .. "'", type="fail"} end
            return {str="Category " .. id .. " deleted", type="success"}

        elseif sub == "view" then
            local id = args[3]
            if not id then return {str="Usage: law category view <id>", type="fail"} end
            local laws = kernel:execute("law.get_by_category", {id=id})
            if not laws or laws.client then return {str="Error: '" .. (laws and laws.log or "unknown") .. "'", type="fail"} end
            if #laws == 0 then return {str="No laws in this category", type="info"} end
            local output = {"Laws in category " .. id .. " --------"}
            for _, l in ipairs(laws) do
                local status = l.active and "\16705[ON]" or "\16708[OFF]"
                table.insert(output, status .. " \16706" .. l.id .. "\16705 [" .. l.type .. "] \16706" .. l.name)
            end
            table.insert(output, "------------------------------------")
            return {str=output, type="info"}

        else
            return {str="Unknown subcommand: " .. sub, type="fail"}
        end
    end
}

cmds["help"] = {
    func = function(args, ctx)
        local output = {"Law commands -------------------------"}
        for k, v in pairs(cmds) do
            if type(v) == "table" and v.desc then
                table.insert(output, "\16705" .. k .. ": \16706" .. v.desc)
            end
        end
        table.insert(output, "--------------------------------------")
        return {str=output, type="info"}
    end
}

function cmds.run(args, ctx)
    if not args[1] or args[1] == "" then return {str="Unknown command: law", type="fail"} end
    if not cmds[args[1]] then return {str="Unknown command: law " .. args[1], type="fail"} end
    return cmds[args[1]].func(args, ctx)
end

return cmds
