os.loadAPI("/GuardLink/client/lib/cryptoNet")
local messageParser = require("/GuardLink/client/network/messageParser")

-- Stores all responses from server in memory
local serverData = {
  username = nil,
  accountInfo = nil,
  transactionStatus = nil,
  sessionToken = nil,
  unknownMessage = nil,
  gpsLocations = {
    byName = {},
    byCategory = {}
  }
}

-- Queue for holding callbacks, mapped by message type
local callbackQueue = {}

-- Socket used to connect to the server, example "GuardLinkBank"
local socket = nil

-- Executed at the start of the loop
local function onStart()
    cryptoNet.connect("GuardLinkBank")
    cryptoNet.setLoggingEnabled(false)

    _G.logger:debug("[eventHandler] Connecting to server with name 'GuardLinkBank'")
end

-- Register a callback for a specific message type
local function registerCallback(messageType, callback)
    if not callbackQueue[messageType] then
        callbackQueue[messageType] = {}
    end
    table.insert(callbackQueue[messageType], callback)
    _G.logger:debug("[eventHandler] Registering callback for message type " .. messageType .. " and function " .. callback)
end

-- Handles executing callbacks for a specific message type
local function executeCallbacks(messageType, serverData)
    if callbackQueue[messageType] then
        -- Execute all callbacks registered for this message type
        for _, callback in ipairs(callbackQueue[messageType]) do
            callback(serverData)
        end
        -- Clear callbacks after executing them
        callbackQueue[messageType] = nil
    else
        _G.logger:debug("[eventHandler] No callbacks set for message type: " .. messageType)
    end
end

-- Listens for responses from server
local function onEvent(event)
    if event[1] == "encrypted_message" then
        -- The message received from the server
        local message = event[2]
        -- Interprets the message and updates serverData
        local messageType = messageParser.handleEventMessage(message, serverData)

        -- Execute and clear callbacks for specific message type
        executeCallbacks(messageType, serverData)
    end
end

-- starts the listener loop
local function startEventListener()
    _G.logger:debug("[eventHandler] Starting Event loop!")
    cryptoNet.startEventLoop(onStart, onEvent)
end

-- returns server socket
local function getSocket()
    return socket
end

-- connects to the server with given name
local function connectServer(serverName)
    socket = cryptoNet.connect(serverName)
end

-- generic setter function
local function setServerData(key, value)
    if serverData[key] ~= nil then
        serverData[key] = value
    else
        error("Invalid key: " .. key)
    end
end

-- generic getter function
local function getServerData(key)
    return serverData[key]
end

return {
    startEventListener = startEventListener,
    getServerData = getServerData,
    connectServer = connectServer,
    getSocket = getSocket,
    registerCallback = registerCallback,
    setServerData = setServerData,
    getServerData = getServerData
}
