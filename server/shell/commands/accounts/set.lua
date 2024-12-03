-- accounts set [name] [key] [value]
local function setAccountKey(cmd, accountManager)
    _G.logger:debug("[shell] Command 'accounts set' executed")
    accountManager.setAccountValue(cmd[3], cmd[4], cmd[5])
    return { cmd[4] .. " set to " .. cmd[5] .. " for " .. cmd[3]}
end

return setAccountKey