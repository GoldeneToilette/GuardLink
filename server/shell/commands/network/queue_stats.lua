local function queueStats(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue stats' executed")
    local flag, delay = requestQueue.getThrottle()
        return {
            "---- Queue Statistics ----",
            "Queue Population: " .. tostring(requestQueue.getPopulation()),
            "Max Queue Size: " .. tostring(requestQueue.getSize()),
            "Average Processing Time: " .. tostring(requestQueue.getAverageTimeSpent()),
            "Throttle: " .. tostring(flag) .. ", " .. tostring(delay),
            "Paused: " .. tostring(requestQueue.isPaused()),
            "---- Queue Statistics ----"
        }
end

return queueStats