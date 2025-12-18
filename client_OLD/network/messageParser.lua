-- Parses a message, stores it into memory, and returns a string of the message type
local function handleEventMessage(message, serverData)
    -- table of all responses from the server and what function they should execute
    local handlers = {
        -- account information response
        ["ACCOUNT_INFO|"] = function(msg)
            serverData.accountInfo = msg:sub(14)
            _G.logger:debug("[messageParser] Received message: ACCOUNT_INFO")
            return "ACCOUNT_INFO"
        end,

        -- transaction fail response
        ["TRANSACTION_FAIL|"] = function(msg)
            serverData.transactionStatus = msg:sub(18)
            _G.logger:debug("[messageParser] Received message: TRANSACTION_FAIL")
            return "TRANSACTION"
        end,

        -- transaction success response
        ["TRANSACTION_SUCCESS"] = function(msg)
            serverData.transactionStatus = "TRANSACTION_SUCCESS"
            _G.logger:debug("[messageParser] Received message: TRANSACTION_SUCCESS")
            return "TRANSACTION"
        end,

        -- session token response (usually for login)
        ["SESSION_TOKEN|"] = function(msg)
            _G.logger:debug("[messageParser] Received message: SESSION_TOKEN")
            local token = msg:sub(15)
            if token ~= "" then
                serverData.sessionToken = token
                return "LOGIN"
            else
                serverData.sessionToken = "INVALID_FORMAT"
                _G.logger:debug("[messageParser] Received message: INVALID_FORMAT")
                return "LOGIN"
            end
        end,

        -- gps response
        ["GPS|"] = function(msg)
            _G.logger:debug("[messageParser] Received message: GPS")
            serverData.latestGPS = msg:sub(5)
            return "GPS"
        end,

    }

    -- depending on what the "message" argument is, it takes the element from the table and executes its
    -- associated function
    for prefix, handler in pairs(handlers) do
        if message:sub(1, #prefix) == prefix then
            return handler(message)
        end
    end

    -- if everything else fails it marks it as an unknown message
    serverData.unknownMessage = message
    _G.logger:info("[messageParser] Received unknown message: " .. message)
    return "UNKNOWN"
end


return {
    handleEventMessage = handleEventMessage
}