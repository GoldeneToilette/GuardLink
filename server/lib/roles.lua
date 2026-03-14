local kernel = require("kernel.kernel")
local errors = requireC("/GuardLink/server/lib/errors.lua")
local roles = {}

local function getIdentity()
    return kernel:execute("kernel.get_config", "identity")
end

local function getRules()
    return kernel:execute("kernel.get_config", "rules")
end

local function saveRoles(rolesTable)
    kernel:execute("kernel.set_config", {config = "identity", key = "roles", value = rolesTable})
end

function roles.getRoles()
    return getIdentity().roles
end

function roles.getRole(name)
    return getIdentity().roles[name]
end

function roles.listRoles()
    local tbl = {}
    for k, _ in pairs(getIdentity().roles) do
        table.insert(tbl, k)
    end
    return tbl
end

function roles.exists(name)
    return getIdentity().roles[name] ~= nil
end

function roles.count()
    local i = 0
    for _ in pairs(getIdentity().roles) do
        i = i + 1
    end
    return i
end

function roles.add(name, seats)
    local config = getIdentity()
    local rules = getRules()
    local ethic = config.selectedEthic
    if roles.count() >= rules.server.formulas.roleLimit(rules.rules.ethics[ethic].values.stability) then
        return errors.ROLES_EXCEED_CAPACITY
    end
    if roles.exists(name) then return errors.ROLE_EXISTS end
    config.roles[name] = {seats = seats or 1, members = {}, permissions = {}}
    saveRoles(config.roles)
    return 0
end

function roles._remove(name)
    if not roles.exists(name) then return errors.ROLE_NOT_FOUND end
    local config = getIdentity()
    local members = config.roles[name].members or {}
    for _, accountName in ipairs(members) do
        kernel:execute("accounts.unassign_role", {name=accountName})
    end
    config.roles[name] = nil
    saveRoles(config.roles)
    return 0
end

function roles._rename(name, newname)
    if not roles.exists(name) then return errors.ROLE_NOT_FOUND end
    if roles.exists(newname) then return errors.ROLE_EXISTS end
    local config = getIdentity()
    config.roles[newname] = config.roles[name]
    config.roles[name] = nil
    local members = config.roles[newname].members or {}
    for _, accountName in ipairs(members) do
        kernel:execute("accounts.set_value", {name=accountName, key="role", value=newname})
    end
    saveRoles(config.roles)
    return 0
end

function roles._setSeats(name, seats)
    if not roles.exists(name) then return errors.ROLE_NOT_FOUND end
    local config = getIdentity()
    if seats < #config.roles[name].members then
        return errors.ROLE_SEATS_BELOW_OCCUPIED
    end
    config.roles[name].seats = seats
    saveRoles(config.roles)
    return 0
end

function roles.hasPermission(name, permission)
    local role = roles.getRole(name)
    if not role then return false end
    for _, v in ipairs(role.permissions) do
        if v == "*" or v == permission then return true end
    end
    return false
end

function roles.addPermission(name, permission)
    if not roles.exists(name) then return errors.ROLE_NOT_FOUND end
    if roles.hasPermission(name, permission) then return errors.PERMISSION_EXISTS end
    local config = getIdentity()
    table.insert(config.roles[name].permissions, permission)
    saveRoles(config.roles)
    return 0
end

function roles.removePermission(name, permission)
    if not roles.exists(name) then return errors.ROLE_NOT_FOUND end
    local config = getIdentity()
    local perms = config.roles[name].permissions
    for i, v in ipairs(perms) do
        if v == permission then
            table.remove(perms, i)
            saveRoles(config.roles)
            return 0
        end
    end
    return errors.PERMISSION_NOT_FOUND
end

function roles.getPermissions(name)
    local role = roles.getRole(name)
    if not role then return nil end
    return role.permissions
end

function roles.isFull(name)
    local role = roles.getRole(name)
    if not role then return nil end
    return #role.members >= role.seats
end

function roles.addMember(name, accountName)
    if not roles.exists(name) then return errors.ROLE_NOT_FOUND end
    local config = getIdentity()
    table.insert(config.roles[name].members, accountName)
    saveRoles(config.roles)
    return 0
end

function roles.removeMember(name, accountName)
    if not roles.exists(name) then return errors.ROLE_NOT_FOUND end
    local config = getIdentity()
    local members = config.roles[name].members
    for i, v in ipairs(members) do
        if v == accountName then
            table.remove(members, i)
            saveRoles(config.roles)
            return 0
        end
    end
    return errors.ACCOUNT_NOT_FOUND
end

function roles.getMembers(name)
    local role = roles.getRole(name)
    if not role then return nil end
    return role.members
end

return roles