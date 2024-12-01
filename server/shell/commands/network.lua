os.loadAPI("/GuardLink/server/lib/cryptoNet")

local clientManager = require("/GuardLink/server/network/clientManager")

-- network client [list/remove/inspect] [ID] 
local function clientCommand(words)
    if words[3] and words[3] == "list" then
        local clients = clientManager.list()
        local output = {"Connected Clients:"}

        for index, clientID in ipairs(clients) do
            table.insert(output, string.format("%d. %s", index, clientID))
        end

        table.insert(output, "Total connections: " .. tostring(clientManager.countClients()))
        return output
    elseif words[3] and words[3] == "remove" then
        if clientManager.unregisterClient(tonumber(words[4])) then
            return { words[4] .. " removed successfully"}
        else
            return {"Failed to remove client " .. words[4]}
        end
    elseif words[3] and words[3] == "inspect" then
        local client = clientManager.inspect(tonumber(words[4]))
        if client then
            return {
                "ID: " .. client.id,
                "Connected At: " .. client.connectedAt,
                "Last Activity Date: " .. client.lastActivityDate,
                "Last Activity: " .. client.lastActivityType
            }
        else
            return {"Failed to inspect client " .. words[4]}            
        end
    else
        return { "Command " .. words[3] .. " not found. Use 'network socket [list/delete/inspect] [ID] '"}
    end
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