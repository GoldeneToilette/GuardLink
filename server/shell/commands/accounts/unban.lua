-- accounts unban [name]
local function unbanAccount(cmd, accountManager)
    _G.logger:debug("[shell] Command 'accounts unban' executed")
    accountManager.setAccountValue(cmd[3], "banned", "false")
    return { "Account " .. cmd[3] .. " unbanned successfully!"}
end

return unbanAccount