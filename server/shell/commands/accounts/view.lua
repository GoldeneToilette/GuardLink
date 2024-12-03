local mathUtils = require("/GuardLink/server/utils/mathUtils")

-- accounts view [name]
local function viewAccount(cmd, accountManager)
    _G.logger:debug("[shell] Command 'accounts view' executed")
    local values = accountManager.getAccountValues(cmd[3])
    if values then
        return {
            "Name: " .. values.name,
            "UUID: " .. values.uuid,
            "Created: " .. values.creationDate,
            "Balance: " .. mathUtils.formatNumber(values.balance) .. " GC",
            "Ban Status: " .. tostring(values.banned),
            "Session Token: " .. values.sessionToken
        }
    else
        return {
            "Failed to retrieve Account values for " .. cmd[3]
        }
    end
end

return viewAccount