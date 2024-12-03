-- accounts ban [name]
local function banAccount(cmd, accountManager)
    _G.logger:debug("[shell] Command 'accounts ban' executed")
    accountManager.setAccountValue(cmd[3], "banned", "true")
    return { "Account " .. cmd[3] .. " banned successfully!"}
end

return banAccount