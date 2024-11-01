os.loadAPI("/GuardLink/client/lib/cryptoNet")

-- Stores all responses from server in memory
serverData = {}
-- Socket used to connect to the server
socket = nil
-- idk what that is
responseCallback = nil

-- Executed at the start of the loop
function onStart()
    cryptoNet.connect("GuardLinkBank")
    cryptoNet.setLoggingEnabled(false)

    
end

-- Listens for responses from server
function onEvent(event)
  if event[1] == "encrypted_message" then
      -- The message received from the server
      local message = event[2]
      if message:sub(1, 13) == "ACCOUNT_INFO|" then
          serverData.accountInfo = message:sub(14)

      elseif message:sub(1, 17) == "TRANSACTION_FAIL|" then
          serverData.transactionStatus = message:sub(18)

      elseif message:sub(1, 19) == "TRANSACTION_SUCCESS" then
          serverData.transactionStatus = "TRANSACTION_SUCCESS"
      
      -- If the message includes "SESSION_TOKEN" at the beginning, it extracts the token and saves it in serverData
      elseif message:sub(1, 14) == "SESSION_TOKEN|" then
        local token = message:sub(15)
        if token ~= "" then
        serverData.sessionToken = token
        else 
          serverData.sessionToken = "INVALID_FORMAT"
        end

      else 
          serverData.unknownMessage = message
      end
      
      -- I have no idea what it does but it works
      if responseCallback then
        responseCallback(serverData)
        responseCallback = nil
      end
  end
end

-- This part is dedicated to sending requests to the server ------------------------------------------------------------------------
-- Sends a login request to the server
function sendLoginRequest(username, password, socket) 
  cryptoNet.send(socket, "LOGIN|" .. username .. "|" .. password .. "|")
end

-- Sends a transaction request to the server
function sendTransactionRequest(sender, receiver, amount, socket)
  cryptoNet.send(socket, "TRANSACTION|" .. sender .. "|" .. receiver .. "|" .. amount .. "|" .. serverData.sessionToken)
end

-- Request all account information from an account (you can only request yours since you need a token)
function sendAccountInfoRequest(username, socket)
  cryptoNet.send(socket, "ACCOUNT_INFO|" .. username .. "|" .. serverData.sessionToken)
end
-- This part is dedicated to sending requests to the server ------------------------------------------------------------------------

-- starts the listener loop
function startListener()
  cryptoNet.startEventLoop(onStart, onEvent)
end

-- returns all the server responses stored in memory
function getServerData()
  return serverData
end

-- returns server socket
function getSocket()
  return socket
end

-- connects to the server with given name
function connectServer(serverName)
  socket = cryptoNet.connect(serverName)
end

-- again idk what the fuck this does and at this point i dont even care anymore
function setResponseCallback(callback)
  responseCallback = callback
end

return {
    sendLoginRequest = sendLoginRequest,
    sendTransactionRequest = sendTransactionRequest,
    sendAccountInfoRequest = sendAccountInfoRequest,
    startListener = startListener,
    getServerData = getServerData,
    connectServer = connectServer,
    getSocket = getSocket,
    setResponseCallback = setResponseCallback
}
