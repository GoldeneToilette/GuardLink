-- accounts balance [name] [set/add/subtract] [value] 
local function changeAccountBalance(cmd, accountManager)
    _G.logger:debug("[shell] Command 'accounts balance' executed")
    if accountManager.changeAccountBalance(cmd[4], cmd[3], tonumber(cmd[5])) then
        return { "Balance changed successfully for " .. cmd[3]}        
    else
        return { "Failed to change balance for "  .. cmd[3]}    
    end
end

return changeAccountBalance