local function queueInspect(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue inspect' executed")
    local request = requestQueue.inspect(cmd[4])
    if request then
        return {
            "Request-ID: " .. request.id,
            "Message: " .. request.message,
            "Client: " .. request.clientID,
            "Time-stamp: " .. request.timestamp,
            "Priority Level: " .. request.priority
        }
    else
        return {"Failed to inspect request with id " .. cmd[4]}
    end
end

return queueInspect
