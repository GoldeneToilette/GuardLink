os.loadAPI("/GuardLink/server/lib/cryptoNet")

local requestHandler = require("/GuardLink/server/network/requestHandler")
local clientManager = require("/GuardLink/server/network/clientManager")

-- Queue to hold the messages
local messageQueue = {}
local isProcessing = false

-- Function to process the queue
local function processQueue()
    if #messageQueue > 0 and not isProcessing then
        isProcessing = true
        local message, socket = table.unpack(table.remove(messageQueue, 1))  -- Unpack the first element in the queue
        requestHandler.handleRequest(message, socket)  -- passes the message and socket to the handler
        isProcessing = false  -- reset the flag, so the next one can be processed
        processQueue()  -- executes the function again
    end
end

-- Function to add a message to the queue
local function addToQueue(message, socket)
    table.insert(messageQueue, {message, socket})
    processQueue()
end

local function onStart()
    _G.logger:info("Launching GuardLinkBank Server!")
    cryptoNet.host("GuardLinkBank")
end

local function onEvent(event)
    if event[1] == "encrypted_message" then
        local message = event[2]
        local socket = event[3]

        -- register the client in the list
        clientManager.registerClient(socket)

        -- adds the message to the queue before processing it, to prevent race conditions
        addToQueue(message, socket)
    end
end

function startServer() 
    cryptoNet.startEventLoop(onStart, onEvent)
end

return {
    startServer = startServer
}
