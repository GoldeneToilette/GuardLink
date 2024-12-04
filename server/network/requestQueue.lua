local RequestQueue = {}
local clientManager = require("/GuardLink/server/network/clientManager")
local securityUtils = require("/GuardLink/server/utils/securityUtils")

local queue = {}
local size = 20
local isProcessing = false
local paused = false
local totalTimeSpent = 0 -- seconds
local processedCount = 0

local isThrottle = false
local throttle = 2

local function doThrottle()
    if isThrottle then
        os.sleep(throttle)
    end
end

function RequestQueue.setThrottle(flag, number)
    isThrottle = flag
    throttle = number
end

function RequestQueue.getThrottle()
    return isThrottle, throttle
end

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
    while #queue > 0 and not paused do
        if not isProcessing then
            isProcessing = true
            -- gets the first request in the queue
            local request = table.remove(queue, 1)
            local message, clientID, timestamp = request.message, request.clientID, request.timestamp
            local client = clientManager.inspect(clientID)  -- fetch the client by ID
            if client then
                -- adds some delay
                doThrottle()
                requestHandler.handleRequest(message, client.socket)  -- handles the message

                local timeSpent = os.clock() - timestamp
                totalTimeSpent = totalTimeSpent + timeSpent
                processedCount = processedCount + 1
                _G.logger:debug("[messageQueue] Processing Request with ID '" .. request.id .. "' for client " .. clientID)
            end
            isProcessing = false
        else
            break
        end
    end
end

-- Add message to queue
function RequestQueue.addToQueue(message, socket, requestHandler)
    if #queue >= size then
        return false
    end
    local client = clientManager.getClientBySocket(socket)
    if client then
        local id = generateUniqueID()
        local timestamp = os.clock() 
        table.insert(queue, {id = id, message = message, clientID = client.id, timestamp = timestamp})
        if not paused and not isProcessing then
            processQueue(requestHandler)
        end
        return true
    end
    return false
end


-- Pause the queue
function RequestQueue.pauseQueue()
    paused = true
end

function RequestQueue.isPaused()
    return paused
end

-- Resume the queue
function RequestQueue.resumeQueue(requestHandler)
    if paused then
        paused = false
        processQueue(requestHandler)
    end
end

-- Get max size limit
function RequestQueue.getSize()
    return size
end

-- Get the current number of messages in the queue
function RequestQueue.getPopulation()
    return #queue
end

-- Set new size limit
function RequestQueue.setSize(newSize)
    size = newSize
end

-- Clears the entire queue
function RequestQueue.clearQueue()
    queue = {}
    totalTimeSpent = 0
    processedCount = 0 
end

-- Adds message without executing it
function RequestQueue.queuePending(message, clientID, id)
    if #queue >= size then
        return false
    end
    local id = id or generateUniqueID()
    local timestamp = os.time()
    table.insert(queue, {id = id, message = message, clientID = clientID, timestamp = timestamp})
    return true
end

-- Removes a specific request by ID
function RequestQueue.removeRequestByID(requestID)
    for i, request in ipairs(queue) do
        if request.id == requestID then
            table.remove(queue, i)
            return true
        end
    end
    return false
end

-- Moves a request with the given ID to the front of the queue
function RequestQueue.prioritize(requestID)
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
function RequestQueue.postpone(requestID)
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
function RequestQueue.inspect(requestID)
    for _, request in ipairs(queue) do
        if request.id == requestID then
            return request
        end
    end
    return nil
end

-- Get the average time spent in the queue
function RequestQueue.getAverageTimeSpent()
    if processedCount == 0 then
        return 0
    end
    return totalTimeSpent / processedCount
end

-- List all request IDs in the queue
function RequestQueue.listRequestIDs()
    local ids = {}
    for _, request in ipairs(queue) do
        table.insert(ids, request.id)
    end
    return ids
end

return RequestQueue