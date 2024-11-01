local iostream = require("/GuardLink/server/economy/IOStream")
local sha256 = require("/GuardLink/server/economy/sha256")
local utils = require("/GuardLink/server/utils/Utils")

os.loadAPI("/GuardLink/server/network/cryptoNet")

cryptoNet.setLoggingEnabled(true)

local currentTime = os.time()
local formattedTime = os.date("%H:%M:%S", currentTime)
local timeStamp = "[" .. formattedTime .. "] "

function onStart()
    print("Server started!")
    cryptoNet.host("GuardLinkBank")
end


function onEvent(event)
    if event[1] == "encrypted_message" then
        local message = event[2]
        local parts = {}
        for part in message:gmatch("[^|]+") do
            table.insert(parts, part)
        end
        
        local messageType = parts[1]
        -- LOGIN ATTEMPT --------------------------------------------------
        if messageType == "LOGIN" then
            term.setTextColor(colors.orange)
            local loginMessage = "Login attempt!"
            print(timeStamp .. loginMessage)
            term.setTextColor(colors.white)
            print(timeStamp .. "Name: " .. parts[2])
            print(timeStamp .. "Password: " .. parts[3])
            handleLoginRequest(parts[2], parts[3], event[3])
        -- LOGIN ATTEMPT --------------------------------------------------

        -- TRANSACTION ATTEMPT --------------------------------------------
        elseif messageType == "TRANSACTION" then
            term.setTextColor(colors.lightBlue)
            print("Transaction attempt!")
            handleTransactionRequest(parts[2], parts[3], tonumber(parts[4]), parts[5], event[3])
        -- TRANSACTION ATTEMPT ---------------------------------------------

        -- ACCOUNT INFO ATTEMPT --------------------------------------------
        elseif messageType == "ACCOUNT_INFO" then
            term.setTextColor(colors.lightBlue)
            print("Account Info request attempt!")
            handleAccountInfoRequest(parts[2], parts[3], event[3])
        -- ACCOUNT INFO ATTEMPT --------------------------------------------
        end
    end
end


-- Functions that have to send something back to the client require a socket argument
function handleLoginRequest(username, password, socket)
    local success = iostream.authenticateUser(username, password)
    if success then
        local sessionToken = utils.generateSessionToken(16)
        saveSessionToken(username, sessionToken)

        cryptoNet.send(socket, "SESSION_TOKEN|" .. sessionToken)
        print(timeStamp .. "Login successful")
        print(timeStamp .. "Sending Session Token: " .. sessionToken .. " to " .. username)
    else
        cryptoNet.send(socket, "LOGIN_FAILED")
        print(timeStamp .. "Login failed")
    end
end


function handleTransactionRequest(sender, receiver, amount, sessionToken, socket)
        -- verify session token
        if not verifySessionToken(sender, sessionToken) then
            cryptoNet.send(socket, "TRANSACTION_FAIL|INVALID_TOKEN")
            return
        end
        
        -- checks if sender and receiver accounts exist
        if not iostream.doesAccountExist(sender) then
            cryptoNet.send(socket, "TRANSACTION_FAIL|SENDER_NOT_FOUND")
           return
        end

        if not iostream.doesAccountExist(receiver) then
            cryptoNet.send(socket, "TRANSACTION_FAIL|RECEIVER_NOT_FOUND")
           return
        end

        -- checks if amount is a positive integer
        if type(amount) ~= "number" or amount <= 0 or math.floor(amount) ~= amount then
            cryptoNet.send(socket, "TRANSACTION_FAIL|INVALID_AMOUNT")
            return   
        end
        
        -- checks if sender has enough balance
        if iostream.getAccountBalance(sender) < amount then
            cryptoNet.send(socket, "TRANSACTION_FAIL|INSUFFICIENT_FUNDS")
            return
        end



        iostream.transferBalance(sender, receiver, amount)
        cryptoNet.send(socket, "TRANSACTION_SUCCESS")
end


function handleAccountInfoRequest(username, sessionToken, socket)
    if verifySessionToken(username, sessionToken) then
        local accountInfo = iostream.getSanitizedAccountValues(username) --serialized
        local accountInfoJSON = textutils.serializeJSON(accountInfo)
        cryptoNet.send(socket, "ACCOUNT_INFO|" .. accountInfoJSON)
    else
        cryptoNet.send(socket, "SESSION_EXPIRED")
    end
end




function saveSessionToken(username, sessionToken)
  local accountData = iostream.getAccountValues(username)
  if accountData then
      accountData.sessionToken = sessionToken
      
      local filePath = "/guardlink/server/economy/accounts/" .. username .. ".json"
      local file = fs.open(filePath, "w")
      file.write(textutils.serialize(accountData))
      file.close()
  else
      print("Failed to save session token: Account data not found for username '" .. username .. "'")
  end
end


function verifySessionToken(sender, sessionToken)
  local accountData = iostream.getAccountValues(sender)
  if accountData then
      if accountData.sessionToken == sessionToken then
        return true
      else 
        return false
      end
  else 
    print("Failed to verify session token: Account data not found for username '" .. sender .. "'")        
  end
end

cryptoNet.startEventLoop(onStart, onEvent)

return {
    handleLoginRequest = handleLoginRequest,
    handleTransactionRequest = handleTransactionRequest,
    handleAccountInfoRequest = handleAccountInfoRequest,
    saveSessionToken = saveSessionToken,
    verifySessionToken = verifySessionToken
}

