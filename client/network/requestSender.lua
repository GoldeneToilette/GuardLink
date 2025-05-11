-- File for sending requests to the server. Functions require a callback (what to do when the client receives an answer)

local network = require("network.eventHandler")

-- Sends a login request to the server
local function sendLoginRequest(username, password, socket, callback) 
    _G.logger:debug("[requestSender] Sending Login Request with callback " .. tostring(callback))
    network.registerCallback("LOGIN", callback)
    cryptoNet.send(socket, "LOGIN|" .. username .. "|" .. password .. "|")
  end
  
-- Sends a transaction request to the server
local function sendTransactionRequest(sender, receiver, amount, socket, callback)
    _G.logger:debug("[requestSender] Sending Transaction Request with callback " .. tostring(callback))
    network.registerCallback("TRANSACTION", callback)
    local sessionToken = network.getServerData("sessionToken")
    cryptoNet.send(socket, "TRANSACTION|" .. sender .. "|" .. receiver .. "|" .. amount .. "|" .. sessionToken)
  end
  
-- Request all account information from an account (you can only request yours since you need a token)
local function sendAccountInfoRequest(username, socket, callback)
    _G.logger:debug("[requestSender] Sending Account Info Request with callback " .. tostring(callback))
    network.registerCallback("ACCOUNT_INFO", callback)
    local sessionToken = network.getServerData("sessionToken")
    cryptoNet.send(socket, "ACCOUNT_INFO|" .. username .. "|" .. sessionToken)
  end
  
--[[
Request GPS Information. There are 3 types:
1. "single" - Fetch info for a specific location (requires "name").
2. "list" - Fetch locations by category (requires "category").
3. "add" - Add a new location (requires "name", "coordinates", "description", "category").
]]
local function sendGPSRequest(username, type, param, socket, callback) -- param should always be a table
    _G.logger:debug("[requestHandler] Sending GPS Request with type: " .. type .. " and callback: " .. tostring(callback))
    network.registerCallback("GPS", callback)
    local sessionToken = network.getServerData("sessionToken")
    cryptoNet.send(socket, "GPS|" .. username .. "|" .. type .. "|" .. textutils.serializeJSON(param) .. "|" .. sessionToken)
end

  return {
    sendLoginRequest,
    sendTransactionRequest,
    sendAccountInfoRequest,
    sendGPSRequest
  }