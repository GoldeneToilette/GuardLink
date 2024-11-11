local network = require("/GuardLink/client/network/eventHandler")

-- Sends a login request to the server
function sendLoginRequest(username, password, socket, callback) 
    _G.logger:debug("[requestSender] Sending Login Request with callback " .. tostring(callback))
    network.registerCallback("LOGIN", callback)
    cryptoNet.send(socket, "LOGIN|" .. username .. "|" .. password .. "|")
  end
  
  -- Sends a transaction request to the server
  function sendTransactionRequest(sender, receiver, amount, socket, callback)
    _G.logger:debug("[requestSender] Sending Transaction Request with callback " .. tostring(callback))
    network.registerCallback("TRANSACTION", callback)
    local sessionToken = network.getServerData("sessionToken")
    cryptoNet.send(socket, "TRANSACTION|" .. sender .. "|" .. receiver .. "|" .. amount .. "|" .. sessionToken)
  end
  
  -- Request all account information from an account (you can only request yours since you need a token)
  function sendAccountInfoRequest(username, socket, callback)
    _G.logger:debug("[requestSender] Sending Account Info Request with callback " .. tostring(callback))
    network.registerCallback("ACCOUNT_INFO", callback)
    local sessionToken = network.getServerData("sessionToken")
    cryptoNet.send(socket, "ACCOUNT_INFO|" .. username .. "|" .. sessionToken)
  end
  
  return {
    sendLoginRequest = sendLoginRequest,
    sendTransactionRequest = sendTransactionRequest,
    sendAccountInfoRequest = sendAccountInfoRequest
  }