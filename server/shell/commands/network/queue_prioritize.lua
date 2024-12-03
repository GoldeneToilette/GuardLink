local function queuePrioritize(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue prioritize' executed")
    if requestQueue.prioritize(cmd[4]) then
        return {"Request " .. cmd[4] .. "is now at the top of the queue"}            
    else
        return {"Failed to prioritize request " .. cmd[4]}   
    end
end

return queuePrioritize