local function queuePostpone(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue postpone' executed")
    if requestQueue.postpone(cmd[4]) then
        return {"Request " .. cmd[4] .. "is now at the bottom of the queue"}            
    else
        return {"Failed to prioritize request " .. cmd[4]}   
    end
end

return queuePostpone