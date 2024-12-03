local function removeClient(cmd, clientManager)
    _G.logger:debug("[shell] Command 'network client remove' executed")
        if clientManager.unregisterClient(tonumber(cmd[4])) then
            return {cmd[4] .. " removed successfully"}
        else
            return {"Failed to remove client " .. cmd[4]}
        end
end

return removeClient