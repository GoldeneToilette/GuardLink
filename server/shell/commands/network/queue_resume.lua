local function queueResume(cmd, requestQueue,requestHandler)
    _G.logger:debug("[shell] Command 'network queue resume' executed")
    requestQueue.resumeQueue(requestHandler)
    return {"Request queue is now running again!"}            
end

return queueResume