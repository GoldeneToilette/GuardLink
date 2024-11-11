-- Parses a message, stores it into memory and returns a string of the message type
function handleEventMessage(message, serverData)
    if message:sub(1, 13) == "ACCOUNT_INFO|" then
        serverData.accountInfo = message:sub(14)
        _G.logger:info("[messageParser] Received message: " .. message:sub(1, 12))
        return "ACCOUNT_INFO"
    elseif message:sub(1, 17) == "TRANSACTION_FAIL|" then
        serverData.transactionStatus = message:sub(18)
        _G.logger:info("[messageParser] Received message: " .. message)
        return "TRANSACTION"
    elseif message:sub(1, 19) == "TRANSACTION_SUCCESS" then
        serverData.transactionStatus = "TRANSACTION_SUCCESS"
        _G.logger:info("[messageParser] Received message: " .. message)
        return "TRANSACTION"
    -- If the message includes "SESSION_TOKEN" at the beginning, it extracts the token and saves it in serverData
    elseif message:sub(1, 14) == "SESSION_TOKEN|" then
        _G.logger:info("[messageParser] Received message: " .. message:sub(1, 13))
      local token = message:sub(15)
      if token ~= "" then
      serverData.sessionToken = token
      return "LOGIN"
      else 
        serverData.sessionToken = "INVALID_FORMAT"
        _G.logger:info("[messageParser] Received message: INVALID_FORMAT")
        return "LOGIN"
      end
    else 
        serverData.unknownMessage = message
        _G.logger:info("[messageParser] Received message: " .. message)
        return "UNKNOWN"
    end    
end

return {
    handleEventMessage = handleEventMessage
}