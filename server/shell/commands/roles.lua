local roles = requireC("/GuardLink/server/lib/roles.lua")

local cmds = {}
cmds.name = "roles"

cmds["view"] = {
    desc = "View a role: roles view <name>",
    func = function(args, ctx)
        local name = args[2]
        if not name then return {str="Usage: roles view <name>", type="fail"} end
        local role = roles.getRole(name)
        if not role then return {str="Error: Role not found: " .. name, type="fail"} end
        local output = {
            "\16705Name: \16706" .. name,
            "\16705Occupied: \16706" .. #role.members .. "/" .. role.seats,
            "\16705Permissions: \16706" .. (#role.permissions > 0 and table.concat(role.permissions, ", ") or "none")
        }
        return {str=output, type="info"}
    end
}

cmds["list"] = {
    desc = "List all roles",
    func = function(args, ctx)
        local all = roles.getRoles()
        if not all or not next(all) then return {str="No roles found", type="info"} end
        local output = {"Roles -------------------------"}
        for name, role in pairs(all) do
            table.insert(output, "\16705" .. name .. ": \16706" .. #role.members .. "/" .. role.seats .. " seats")
        end
        table.insert(output, "-------------------------------")
        return {str=output, type="info"}
    end
}

cmds["create"] = {
    desc = "Create a role: roles create <name> <seats>",
    func = function(args, ctx)
        local name, seats = args[2], tonumber(args[3])
        if not name then return {str="Usage: roles create <name> <seats>", type="fail"} end
        local success = roles.add(name, seats)
        if success ~= 0 then
            return {str="Error: '" .. success.log .. "'", type="fail"}
        end
        return {str="Role created: " .. name .. " with " .. (seats or 1) .. " seat(s)", type="success"}
    end
}

cmds["delete"] = {
    desc = "Delete a role: roles delete <name>",
    func = function(args, ctx)
        local name = args[2]
        if not name then return {str="Usage: roles delete <name>", type="fail"} end
        local success = roles._remove(name)
        if success ~= 0 then
            return {str="Error: '" .. success.log .. "'", type="fail"}
        end
        return {str="Role deleted: " .. name, type="success"}
    end
}

cmds["seats"] = {
    desc = "Set seat count for a role: roles seats <name> <seats>",
    func = function(args, ctx)
        local name, seats = args[2], tonumber(args[3])
        if not name or not seats then return {str="Usage: roles seats <name> <seats>", type="fail"} end
        local success = roles._setSeats(name, seats)
        if success ~= 0 then
            return {str="Error: '" .. success.log .. "'", type="fail"}
        end
        return {str="Role " .. name .. " now has " .. seats .. " seat(s)", type="success"}
    end
}

cmds["permission"] = {
    desc = "Manage role permissions: roles permission <add|remove|list> <role> [permission]",
    func = function(args, ctx)
        local sub = args[2]
        if not sub then return {str="Usage: roles permission <add|remove|list> <role> [permission]", type="fail"} end

        if sub == "add" then
            local role, permission = args[3], args[4]
            if not role or not permission then return {str="Usage: roles permission add <role> <permission>", type="fail"} end
            local success = roles.addPermission(role, permission)
            if success ~= 0 then
                return {str="Error: '" .. success.log .. "'", type="fail"}
            end
            return {str="Permission " .. permission .. " added to role " .. role, type="success"}

        elseif sub == "remove" then
            local role, permission = args[3], args[4]
            if not role or not permission then return {str="Usage: roles permission remove <role> <permission>", type="fail"} end
            local success = roles.removePermission(role, permission)
            if success ~= 0 then
                return {str="Error: '" .. success.log .. "'", type="fail"}
            end
            return {str="Permission " .. permission .. " removed from role " .. role, type="success"}

        elseif sub == "list" then
            local role = args[3]
            if not role then return {str="Usage: roles permission list <role>", type="fail"} end
            local permissions = roles.getPermissions(role)
            if not permissions then return {str="Error: Role not found: " .. role, type="fail"} end
            if #permissions == 0 then return {str="Role " .. role .. " has no permissions", type="info"} end
            local output = {"Permissions for " .. role .. ":"}
            for _, v in ipairs(permissions) do
                table.insert(output, "\16706" .. v)
            end
            return {str=output, type="info"}

        else
            return {str="Unknown subcommand: " .. sub .. " (add|remove|list)", type="fail"}
        end
    end
}

cmds["rename"] = {
    desc = "Rename a role: roles rename <name> <newname>",
    func = function(args, ctx)
        local name, newname = args[2], args[3]
        if not name or not newname then return {str="Usage: roles rename <name> <newname>", type="fail"} end
        local success = roles._rename(name, newname)
        if success ~= 0 then
            return {str="Error: '" .. success.log .. "'", type="fail"}
        end
        return {str="Role " .. name .. " renamed to " .. newname, type="success"}
    end
}

cmds["members"] = {
    desc = "List members of a role: roles members <name>",
    func = function(args, ctx)
        local name = args[2]
        if not name then return {str="Usage: roles members <name>", type="fail"} end
        local members = roles.getMembers(name)
        if not members then return {str="Error: Role not found: " .. name, type="fail"} end
        if #members == 0 then return {str="Role " .. name .. " has no members", type="info"} end
        local output = {"Members of " .. name .. ":"}
        for _, v in ipairs(members) do
            table.insert(output, "\16706" .. v)
        end
        return {str=output, type="info"}
    end
}

cmds["help"] = {
    func = function(args, ctx)
        local output = {"Role commands -------------------------"}
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
    if not args[1] or args[1] == "" then return {str="Unknown command: roles", type="fail"} end
    if not cmds[args[1]] then return {str="Unknown command: roles " .. args[1], type="fail"} end
    return cmds[args[1]].func(args, ctx)
end

return cmds