local function queueClear(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue clear' executed")
    requestQueue.clearQueue()
    return { "Queue cleared!"}      
end

return queueClear