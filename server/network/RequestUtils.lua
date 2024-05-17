local RequestTypes = require("RequestTypes")

-- Transforms the request message into a for the computer readable table
function interpretRequest(message)
    local parts = {}
    for part in message:gmatch("[^|]+") do
        table.insert(parts, part)
    end
    
    local requestType = parts[1]
    local requestData = {}
    for i = 2, #parts do
        table.insert(requestData, parts[i])
    end
    
    return requestType, requestData
end


-- Returns only the request Type
function getRequestType(message)
    local parts = message:split("|")
    return parts[1]
end


-- Returns the request Data
function getRequestData(message)
    local parts = message:split("|")
    table.remove(parts, 1)
    return parts
end


-- Checks if the message follows the format "REQUEST_TYPE|ASSOCIATED_DATA_WITH_IT|MORE_DATA_IF_NEEDED"
function isValidRequestFormat(message)
    return message:match("^%w+|%w+(|[%w|]*)$") ~= nil
end


-- Checks if the request type exists
local function isValidRequestType(requestType)
    for _, validType in ipairs(RequestTypes) do
        if requestType == validType then
            return true
        end
    end
    return false
end


-- Creates a formatted request string
function createFormattedRequest(requestType, ...)
    local requestData = {...}
    local formattedRequest = requestType .. "|" .. table.concat(requestData, "|")
    return formattedRequest
end


return {
    interpretRequest = interpretRequest,
    getRequestType = getRequestType,
    getRequestData = getRequestData,
    isValidRequestFormat = isValidRequestFormat,
    isValidRequestType = isValidRequestType,
    createFormattedRequest = createFormattedRequest
}