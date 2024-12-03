local function queueThrottle(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue throttle' executed")
    if cmd[4] then
        if cmd[4] == "set" then
            requestQueue.setThrottle(cmd[5], tonumber(cmd[6]))
            return {"Throttle set to " .. cmd[5] .. " with delay " .. cmd[6]}
        elseif cmd[4] == "get" then
            local flag, delay = requestQueue.getThrottle()
            return {"Throttle: " .. flag .. ", Delay: " .. delay}
        end
    end

    return { "Queue Size: " .. tostring(requestQueue.getSize())}
end

return queueThrottle