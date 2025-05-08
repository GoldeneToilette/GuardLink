local MessageQueue = {}
local clientManager = require("/GuardLink/server/network/clientManager")
local securityUtils = require("/GuardLink/server/utils/securityUtils")

local queue = {}
local size = 20
local isProcessing = false
local paused = false
local totalTimeSpent = 0
local processedCount = 0 

-- Helper function to generate a unique ID
local function generateUniqueID()
    local id
    local idExists
    repeat
        id = securityUtils.generateRandomID(5)
        idExists = false
        for _, request in ipairs(queue) do
            if request.id == id then
                idExists = true
                break
            end
        end
    until not idExists
    return id
end

-- Process the queue
local function processQueue(requestHandler)
    if #queue > 0 and not isProcessing and not paused then
        isProcessing = true
                -- gets the first request in the queue
        local request = table.remove(queue, 1)
        local message, clientID, timestamp = request.message, request.clientID, request.timestamp
        local client = clientManager.inspect(clientID)  -- fetch the client by ID
        if client then
            requestHandler.handleRequest(message, client.socket)  -- handles the message
            _G.logger:debug("[messageQueue] Processing Request " .. request.id .. " for client " .. clientID)
            -- Calculate the time spent in the queue
            local timeSpent = os.time() - timestamp
            totalTimeSpent = totalTimeSpent + timeSpent
            processedCount = processedCount + 1
        end
        isProcessing = false  -- reset the flag for the next request
        processQueue(requestHandler)  -- run the function recursively until all requests are done
    end
end

-- Add message to queue
function MessageQueue.addToQueue(message, socket, requestHandler)
    if #queue >= size then
        return false
    end
    local client = clientManager.getClientBySocket(socket)
    if client then
        local id = generateUniqueID()
        local timestamp = os.time()
        table.insert(queue, {id = id, message = message, clientID = client.id, timestamp = timestamp})
        if not paused then
            processQueue(requestHandler)
        end
        return true
    end
    return false
end

-- Pause the queue
function MessageQueue.pauseQueue()
    paused = true
end

-- Resume the queue
function MessageQueue.resumeQueue(requestHandler)
    if paused then
        paused = false
        processQueue(requestHandler)
    end
end

-- Get max size limit
function MessageQueue.getSize()
    return size
end

-- Get the current number of messages in the queue
function MessageQueue.getPopulation()
    return #queue
end

-- Set new size limit
function MessageQueue.setSize(newSize)
    size = newSize
end

-- Clears the entire queue
function MessageQueue.clearQueue()
    queue = {}
    totalTimeSpent = 0
    processedCount = 0 
end

-- Adds message without executing it
function MessageQueue.queuePending(message, clientID, id)
    if #queue >= size then
        return false
    end
    local id = id or generateUniqueID()
    local timestamp = os.time()
    table.insert(queue, {id = id, message = message, clientID = clientID, timestamp = timestamp})
    return true
end

-- Removes a specific request by ID
function MessageQueue.removeRequestByID(requestID)
    for i, request in ipairs(queue) do
        if request.id == requestID then
            table.remove(queue, i)
            return true
        end
    end
    return false
end

-- Moves a request with the given ID to the front of the queue
function MessageQueue.prioritize(requestID)
    for i, request in ipairs(queue) do
        if request.id == requestID then
            table.remove(queue, i)
            table.insert(queue, 1, request)
            return true
        end
    end
    return false
end

-- Moves a request with the given ID to the back of the queue
function MessageQueue.postpone(requestID)
    for i, request in ipairs(queue) do
        if request.id == requestID then
            table.remove(queue, i)
            table.insert(queue, request)
            return true 
        end
    end
    return false
end

-- Returns a request by ID
function MessageQueue.inspect(requestID)
    for _, request in ipairs(queue) do
        if request.id == requestID then
            return request
        end
    end
    return nil
end

-- Get the average time spent in the queue
function MessageQueue.getAverageTimeSpent()
    if processedCount == 0 then
        return 0
    end
    return totalTimeSpent / processedCount
end

return MessageQueue
