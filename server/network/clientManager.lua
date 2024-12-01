local mathUtils = require("/GuardLink/server/utils/mathUtils")

-- stores all connected clients
local clients = {}

-- updates last activity (requests, etc)
local function updateLastActivity(clientID, activityType)
    if clients[clientID] then
        clients[clientID].lastActivityDate = os.date("%Y-%m-%d %H:%M:%S")
        clients[clientID].lastActivityType = activityType
    end
end

-- adds a client to the table
local function registerClient(socket)
    -- check if the socket already exists or not
    for clientID, client in pairs(clients) do
        if client.socket.target == socket.target then
            return false
        end
    end

    local clientID = mathUtils.randomNumber(10000, 99999)

    -- if ID already exists, pick a new one
    while clients[clientID] do
        clientID = mathUtils.randomNumber(10000, 99999)
    end

    clients[clientID] = {
        socket = socket,
        id = clientID,
        connectedAt = os.date("%Y-%m-%d %H:%M:%S"),
        lastActivityDate = os.date("%Y-%m-%d %H:%M:%S"),
        lastActivityType = "connected"
    }
    _G.logger:info("[clientManager] New client connected: " .. clientID)
    return true
end

-- remove client from table by ID
local function unregisterClient(clientID)
    if clients[clientID] then
        clients[clientID] = nil
        _G.logger:info("[clientManager] Client disconnected: " .. clientID)
    else
        _G.logger:error("[clientManager] Client ID not found: " .. clientID)
    end
end

-- returns a list of all client IDs
local function list()
    local clientList = {}
    for clientID, _ in pairs(clients) do
        table.insert(clientList, clientID)
    end
    return clientList
end

-- returns all details for a clientID
local function inspect(clientID)
    local client = clients[clientID]
    if client then
        return client
    else
        return nil
    end
end

-- returns a number of all clients
local function countClients()
    local count = 0
    for _ in pairs(clients) do
        count = count + 1
    end
    return count
end


-- Get a client by socket
local function getClientBySocket(socket)
    for clientID, client in pairs(clients) do
        if client.socket.target == socket.target then
            return client
        end
    end
    return nil
end

return {
    registerClient = registerClient,
    updateLastActivity = updateLastActivity,
    unregisterClient = unregisterClient,
    list = list,
    inspect = inspect,
    countClients = countClients,
    getClientBySocket = getClientBySocket
}