os.loadAPI("/GuardLink/server/lib/cryptoNet")

local clientManager = require("/GuardLink/server/network/clientManager")

-- Network client [list/remove/inspect] [ID]
local function clientCommand(words)
    local command = words[3]
    local clientID = tonumber(words[4])

    if command == "list" then
        local clients = clientManager.list()
        local output = {"Connected Clients:"}

        for index, id in ipairs(clients) do
            table.insert(output, string.format("%d. %s", index, id))
        end

        table.insert(output, "Total connections: " .. tostring(clientManager.countClients()))
        return output
    end

    if command == "remove" then
        if clientManager.unregisterClient(clientID) then
            return {words[4] .. " removed successfully"}
        else
            return {"Failed to remove client " .. words[4]}
        end
    end

    if command == "inspect" then
        local client = clientManager.inspect(clientID)
        if client then
            return {
                "ID: " .. client.id,
                "Connected At: " .. client.connectedAt,
                "Last Activity: " .. client.lastActivityType
            }
        else
            return {"Failed to inspect client " .. words[4]}
        end
    end

    return {"Command " .. command .. " not found. Use 'network socket [list/remove/inspect] [ID]'"}
end


-- network queue [list/size/clear]
local function queueCommand(words)

end

local networkCommands = {
    client = clientCommand,
    queue = queueCommand,
    status = statusCommand,

}

local function handle(words)
    local action = words[2]
    local handler = networkCommands[action]

    if handler then
        return handler(words)
    else
        if action then
            return { action .. " command not found. Use 'help network'" }
        else
            return {"Missing arguments! Use 'help network'"}
        end
    end
end

return {
    handle = handle
}