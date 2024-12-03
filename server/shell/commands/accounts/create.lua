-- accounts create [name] [password]
local function createAccount(cmd, accountManager)
    _G.logger:debug("[shell] Command 'accounts create' executed")
    if accountManager.createAccount(cmd[3], cmd[4]) then
        return { "Account " .. cmd[3] .. " created successfully!"}
    else
        return { "Failed to create Account " .. cmd[3]}
    end
end

return createAccount