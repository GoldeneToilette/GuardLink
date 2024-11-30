local accountManager = require("/GuardLink/server/economy/accountManager")
local securityUtils = require("/GuardLink/server/utils/securityUtils")
local mathUtils = require("/GuardLink/server/utils/mathUtils")

os.loadAPI("/GuardLink/server/lib/cryptoNet")

-- maps message types to handler functions
local requestHandlers = {}

-- LOGIN handler
local function handleLoginRequest(parts, socket)
    local username = parts[2]
    local password = parts[3]
    local success = accountManager.authenticateUser(username, password)
    
    if success then
        local sessionToken = securityUtils.generateSessionToken(16)
        accountManager.setAccountValue(username, "sessionToken", sessionToken)
        cryptoNet.send(socket, "SESSION_TOKEN|" .. sessionToken)
        _G.logger:info("[requestHandler] Successful login: " .. username)
    else
        cryptoNet.send(socket, "LOGIN_FAILED")
        _G.logger:info("[requestHandler] Failed login: " .. username)
    end
end

-- TRANSACTION handler
local function handleTransactionRequest(parts, socket)
    local sender = parts[2]
    local receiver = parts[3]
    local amount = tonumber(parts[4])
    local sessionToken = parts[5]

    if accountManager.getAccountValues(sender) == nil then
        cryptoNet.send(socket, "TRANSACTION_FAIL|SENDER_NOT_FOUND")
        _G.logger:info("[requestHandler] Failed transaction request: Sender not found.")
        return
    end
    if not accountManager.verifySessionToken(sender, sessionToken) then
        cryptoNet.send(socket, "TRANSACTION_FAIL|INVALID_TOKEN")
        _G.logger:info("[requestHandler] Failed transaction request: Invalid token.")
        return
    end
    if not amount or amount <= 0 or mathUtils.isInteger(amount) then
        cryptoNet.send(socket, "TRANSACTION_FAIL|INVALID_AMOUNT")
        _G.logger:info("[requestHandler] Failed transaction request: Invalid amount.")
        return
    end
    if accountManager.getAccountValues(receiver) == nil then
        cryptoNet.send(socket, "TRANSACTION_FAIL|RECEIVER_NOT_FOUND")
        _G.logger:info("[requestHandler] Failed transaction request: Receiver not found.")
        return
    end
    if sender == receiver then
        cryptoNet.send(socket, "TRANSACTION_FAIL|INVALID_TRANSACTION")
        _G.logger:info("[requestHandler] Failed transaction request: Invalid transaction.")
        return
    end
    if accountManager.getAccountValue(sender, "balance") < amount then
        cryptoNet.send(socket, "TRANSACTION_FAIL|INSUFFICIENT_FUNDS")
        _G.logger:info("[requestHandler] Failed transaction request: Insufficient funds.")
        return
    end

    -- if it passes all the checks, proceed with the transaction
    accountManager.transferBalance(sender, receiver, amount)
    cryptoNet.send(socket, "TRANSACTION_SUCCESS")
    _G.logger:info("[requestHandler] Successful transaction: Transfered " .. amount .. " GC from " .. sender .. " to " .. receiver)
end

-- ACCOUNT INFO handler
local function handleAccountInfoRequest(parts, socket)
    local username = parts[2]
    local sessionToken = parts[3]
    
    if accountManager.verifySessionToken(username, sessionToken) then
        local accountInfo = accountManager.getSanitizedAccountValues(username)
        local accountInfoJSON = textutils.serializeJSON(accountInfo)
        cryptoNet.send(socket, "ACCOUNT_INFO|" .. accountInfoJSON)
        _G.logger:info("[requestHandler] Successful account info request: " .. username)        
    else
        cryptoNet.send(socket, "SESSION_EXPIRED")
        _G.logger:info("[requestHandler] Failed account info request: Session expired!")
    end
end

-- registers handler functions
requestHandlers["LOGIN"] = handleLoginRequest
requestHandlers["TRANSACTION"] = handleTransactionRequest
requestHandlers["ACCOUNT_INFO"] = handleAccountInfoRequest

-- Main function that passes the requests to the associated handlers
function handleRequest(message, socket)
    local parts = {}
    -- Parses the message into parts
    for part in message:gmatch("[^|]+") do
        table.insert(parts, part)
    end

    local messageType = parts[1]
    local handler = requestHandlers[messageType]
    
    if handler then
        handler(parts, socket)
    else
        _G.logger:error("[requestHandler] Unknown message: " .. message)
        return
    end
end

return {
    handleRequest = handleRequest
}