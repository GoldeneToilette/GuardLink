local function queueAdd(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue add' executed")
    if requestQueue.queuePending(cmd[4], cmd[5], cmd[6]) then
        return {"Request for " .. cmd[5] .. " with ID " .. cmd[6] .. " added successfully!"}
    else
        return {"Failed to add request. Use 'help queue'"}
    end
end

return queueAdd