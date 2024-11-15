-- Parses a message, stores it into memory, and returns a string of the message type
function handleEventMessage(message, serverData)
    local handlers = {
        ["ACCOUNT_INFO|"] = function(msg)
            serverData.accountInfo = msg:sub(14)
            _G.logger:info("[messageParser] Received message: ACCOUNT_INFO")
            return "ACCOUNT_INFO"
        end,
        ["TRANSACTION_FAIL|"] = function(msg)
            serverData.transactionStatus = msg:sub(18)
            _G.logger:info("[messageParser] Received message: TRANSACTION_FAIL")
            return "TRANSACTION"
        end,
        ["TRANSACTION_SUCCESS"] = function(msg)
            serverData.transactionStatus = "TRANSACTION_SUCCESS"
            _G.logger:info("[messageParser] Received message: TRANSACTION_SUCCESS")
            return "TRANSACTION"
        end,
        ["SESSION_TOKEN|"] = function(msg)
            _G.logger:info("[messageParser] Received message: SESSION_TOKEN")
            local token = msg:sub(15)
            if token ~= "" then
                serverData.sessionToken = token
                return "LOGIN"
            else
                serverData.sessionToken = "INVALID_FORMAT"
                _G.logger:info("[messageParser] Received message: INVALID_FORMAT")
                return "LOGIN"
            end
        end,
    }

    -- goes through the table and executes the associated function
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