local function listClient(cmd, clientManager)
    _G.logger:debug("[shell] Command 'network client list' executed")
    local clients = clientManager.list()
    local output = {"Connected Clients:"}

    for index, id in ipairs(clients) do
        table.insert(output, string.format("%d. %s", index, id))
    end

    table.insert(output, "Total connections: " .. tostring(clientManager.countClients()))
    return output
end

return listClient