local function queueAverage(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue average' executed")
    return { "Average processing time per request: " .. tostring(requestQueue.getAverageTimeSpent())}      
end

return queueAverage