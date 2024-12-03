local function queueSize(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue size' executed")
    if cmd[4] and cmd[4] == "set" then
        requestQueue.setSize(tonumber(cmd[4]))
        return {"Queue size set to: " .. tostring(cmd[4])}
    end

    return { "Queue Size: " .. tostring(requestQueue.getSize())}
end

return queueSize