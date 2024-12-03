local function queueRemove(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue remove' executed")
    if requestQueue.removeRequestByID(cmd[4]) then
        return {"Request " .. cmd[4] .. " removed successfully!"}
    else
        return {"Failed ro remove request" .. cmd[4]}
    end
end

return queueRemove