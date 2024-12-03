local function queueList(cmd, RequestQueue)
    _G.logger:debug("[shell] Command 'network queue list' executed")
    local requestIDs = RequestQueue.listRequestIDs()
    local output = {"Current Requests:"}

    for index, id in ipairs(requestIDs) do
        table.insert(output, string.format("%d. %s", index, id))
    end

    table.insert(output, "Total requests in queue: " .. tostring(RequestQueue.getPopulation()))
    return output
end

return queueList