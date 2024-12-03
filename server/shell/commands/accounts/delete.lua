-- accounts delete [name]
local function deleteAccount(cmd, accountManager)
    _G.logger:debug("[shell] Command 'accounts delete' executed")
    if accountManager.deleteAccount(cmd[3]) then
        return { "Account " .. cmd[3] .. " deleted successfully!"}        
    else
        return { "Failed to delete Account " .. cmd[3]}
    end
end

return deleteAccount