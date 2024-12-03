local function queuePause(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue pause' executed")
    requestQueue.pauseQueue()
    return {"Request queue is now paused!"}            
end

return queuePause