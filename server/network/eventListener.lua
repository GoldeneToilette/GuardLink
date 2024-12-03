os.loadAPI("/GuardLink/server/lib/cryptoNet")

local requestHandler = require("/GuardLink/server/network/requestHandler")
local clientManager = require("/GuardLink/server/network/clientManager")
local requestQueue = require("/GuardLink/server/network/requestQueue")

local function onStart()
    _G.logger:info("Launching GuardLinkBank Server!")
    cryptoNet.host("GuardLinkBank")
end

local function onEvent(event)
    if event[1] == "encrypted_message" then
        local message = event[2]
        local socket = event[3]

        -- Register the client in the list
        clientManager.registerClient(socket)

        -- Adds the message to the queue before processing it
        local success = requestQueue.addToQueue(message, socket, requestHandler)
    end
end

local function startServer()
    cryptoNet.startEventLoop(onStart, onEvent)
end

return {
    startServer = startServer
}
