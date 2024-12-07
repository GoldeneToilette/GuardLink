local accountManager = require("/GuardLink/server/economy/accountManager")
local securityUtils = require("/GuardLink/server/utils/securityUtils")
local mathUtils = require("/GuardLink/server/utils/mathUtils")
local clientManager = require("/GuardLink/server/network/clientManager")
local gpsManager = require("/GuardLink/server/gps/gpsManager")

os.loadAPI("/GuardLink/server/lib/cryptoNet")

-- maps message types to handler functions
local requestHandlers = {}

-- LOGIN handler
local function handleLoginRequest(parts, socket, client)
    local username = parts[2]
    local password = parts[3]
    local success = accountManager.authenticateUser(username, password)

    if success then
        local sessionToken = securityUtils.generateSessionToken(16)
        accountManager.setAccountValue(username, "sessionToken", sessionToken)
        cryptoNet.send(socket, "SESSION_TOKEN|" .. sessionToken)
        _G.logger:info("[requestHandler] Successful login: " .. username)
        clientManager.updateLastActivity(client.id, "login")
    else
        cryptoNet.send(socket, "LOGIN_FAILED")
        _G.logger:info("[requestHandler] Failed login: " .. username)
    end
end

-- TRANSACTION handler
local function handleTransactionRequest(parts, socket, client)
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
    if not amount or amount <= 0 or not mathUtils.isInteger(amount) then
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
    clientManager.updateLastActivity(client.id, "transaction")
end

-- ACCOUNT INFO handler
local function handleAccountInfoRequest(parts, socket, client)
    local username = parts[2]
    local sessionToken = parts[3]

    if accountManager.verifySessionToken(username, sessionToken) then
        local accountInfo = accountManager.getSanitizedAccountValues(username)
        local accountInfoJSON = textutils.serializeJSON(accountInfo)
        cryptoNet.send(socket, "ACCOUNT_INFO|" .. accountInfoJSON)
        _G.logger:info("[requestHandler] Successful account info request: " .. username)       
        clientManager.updateLastActivity(client.id, "account_info")
    else
        cryptoNet.send(socket, "SESSION_EXPIRED")
        _G.logger:info("[requestHandler] Failed account info request: Session expired!")
    end
end

-- GPS handler
local function handleGPSRequest(parts, socket, client)
    local username = parts[2]
    local type = parts[3]
    local paramJSON = parts[4]
    local param = textutils.unserializeJSON(paramJSON)
    local sessionToken = parts[5]

    _G.logger:debug("[requestHandler] processing GPS request")   

    if accountManager.verifySessionToken(username, sessionToken) then
        if type == "single" then
            local location = gpsManager.getLocationDetails(param.category, param.name)
            if location then
                local locationJSON = textutils.serializeJSON(location)
                cryptoNet.send(socket, "GPS|" .. locationJSON)
                _G.logger:info("[requestHandler] Successful gps request 'single': " .. username)       
            else
                cryptoNet.send(socket, "GPS|UNKNOWN_LOCATION")
                _G.logger:info("[requestHandler] Failed gps request 'single': " .. username)                       
            end
            clientManager.updateLastActivity(client.id, "gps_single")

        elseif type == "list" then
            local locations = gpsManager.getLocationNamesByCategory(param.category)
            if locations then
                local locationsJSON = textutils.serializeJSON(locations)
                cryptoNet.send(socket, "GPS|" .. locationsJSON)
                _G.logger:info("[requestHandler] Successful gps request 'list': " .. username)                      
            else
                cryptoNet.send(socket, "GPS|UNKNOWN_CATEGORY")
                _G.logger:info("[requestHandler] Failed gps request 'list': " .. username)        
            end
            clientManager.updateLastActivity(client.id, "gps_list")

        elseif type == "add" then
            if gpsManager.registerLocation(username, param.name, param.coordinates, param.description, param.category) then
                cryptoNet.send(socket, "GPS|CREATION_SUCCESS") 
                _G.logger:info("[requestHandler] Successful gps request 'add': " .. username)                      
            else
                cryptoNet.send(socket, "GPS|CREATION_FAIL") 
                _G.logger:info("[requestHandler] Failed gps request 'add': " .. username)         
            end
        else
            cryptoNet.send(socket, "GPS|INVALID_REQUEST") 
            _G.logger:info("[requestHandler] Unknown gps request: " .. username .. ", " .. type .. ", " .. param .. ", " .. sessionToken)                 
        end
    else
        cryptoNet.send(socket, "SESSION_EXPIRED")
        _G.logger:info("[requestHandler] Failed account info request: Session expired!")        
    end
end

-- registers handler functions
requestHandlers["LOGIN"] = handleLoginRequest
requestHandlers["TRANSACTION"] = handleTransactionRequest
requestHandlers["ACCOUNT_INFO"] = handleAccountInfoRequest
requestHandlers["GPS"] = handleGPSRequest

-- Main function that passes the requests to the associated handlers
local function handleRequest(message, socket)
    local parts = {}
    -- Parses the message into parts
    for part in message:gmatch("[^|]+") do
        table.insert(parts, part)
    end

    local messageType = parts[1]
    local handler = requestHandlers[messageType]

    _G.logger:debug("[requestHandler] message:" .. message)
    local client = clientManager.getClientBySocket(socket)
    if handler then
        handler(parts, socket, client)
    else
        _G.logger:error("[requestHandler] Unknown message: " .. message)
        return
    end
end

return {
    handleRequest = handleRequest
}