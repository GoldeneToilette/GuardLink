local fileUtils = require("/GuardLink/server/utils/fileUtils")
local securityUtils = require("/GuardLink/server/utils/securityUtils")
local mathUtils = require("/GuardLink/server/utils/mathUtils")
local sha256 = require("/GuardLink/server/lib/sha256")

local accountPath = "/GuardLink/server/economy/accounts/"

accountManager = {}

-- creates an account 
function accountManager.createAccount(name, password)
    local filePath = accountPath .. name .. ".json"
    if fs.exists(filePath) then 
        _G.logger:error("[accountManager] Failed to create account: file already exists!")
        return 
    end

    if name ~= "" and password ~= "" then
        local salt = securityUtils.generateSalt(16)
        local saltedPassword = salt .. password

        local hashedPassword = sha256.digest(saltedPassword):toHex()

        local uuid = securityUtils.generateUUID()
        local currentDate = os.date("%Y-%m-%d")
        local currentTime = os.date("%H:%M:%S")

        local accountData = {
            name = name,
            uuid = uuid,
            creationDate = currentDate,
            creationTime = currentTime,
            balance = 0,
            banned = false,
            password = hashedPassword,
            salt = salt,
            sessionToken = ""
        }

        fileUtils.writeAccountFile(tostring(name), textutils.serialize(accountData))
    else
        _G.logger:error("[accountManager] Failed to create account: Invalid name or password")
    end
end

-- changes a specific value
function accountManager.setAccountValue(name, key, value)
    local values = accountManager.getAccountValues(name)
    values[key] = value
    fileUtils.writeAccountFile(name, textutils.serialize(values))
end

-- retrieves a specific value
function accountManager.getAccountValue(name, key)
    local values = accountManager.getAccountValues(name)
    return values[key]
end

-- deletes an account
function accountManager.deleteAccount(name)
    fileUtils.deleteFile(accountPath .. name .. ".json")
end

-- returns all values of an account as a table
function accountManager.getAccountValues(name)
    if name then
        return fileUtils.readAccountFile(name)
    else
        return nil
    end
end

-- Changes the balance of an account. Valid operations: add, subtract, set
function accountManager.changeAccountBalance(operation, name, value)
    local accountData = accountManager.getAccountValues(name)
    if operation == "set" then
        accountData.balance = value
    elseif mathUtils.isInteger(value) then
        if operation == "add" then
            accountData.balance = accountData.balance + value
        elseif operation == "subtract" then
            accountData.balance = accountData.balance - value
        end
    else
        _G.logger:error("[accountManager] Failed to modify balance: Invalid operator " .. operator)
    end

    fileUtils.writeAccountFile(name, textutils.serialize(accountData))
end

-- Transfers balance between 2 accounts.
function accountManager.transferBalance(sender, receiver, value)
    if value <= 0 or mathUtils.isInteger(value) == false then
        return
    end

    local senderValues = accountManager.getAccountValues(sender)
    local receiverValues = accountManager.getAccountValues(receiver)

    if senderValues and receiverValues and sender ~= receiver then
        if senderValues.balance >= value then
            accountManager.changeAccountBalance("subtract", sender, value)
            accountManager.changeAccountBalance("add", receiver, value)
        end
    end
end

-- returns all account names in a table (not sorted)
function accountManager.listAccounts()
    local accountNames = {}

    local files = fs.list(accountPath)
    for _, file in ipairs(files) do
        if file:sub(-5) == ".json" then
            table.insert(accountNames, file:sub(1, -6))
        end
    end

    return accountNames
end

-- returns table with account values but without sensitive information
function accountManager.getSanitizedAccountValues(name)
    local accountData = accountManager.getAccountValues(name)
    if accountData then
        return {
            name = accountData.name,
            uuid = accountData.uuid,
            creationDate = accountData.creationDate,
            creationTime = accountData.creationTime,
            balance = accountData.balance,
            banned = accountData.banned
        }
    else
        _G.logger:error("[accountManager] Failed to retrieve account data: Account doesnt exist!")
    end
end

-- Checks if the given password matches the username, returns true or false
function accountManager.authenticateUser(username, password)
    local account = accountManager.getAccountValues(username)
    if not account then return false end

    local salt = account.salt
    local storedPasswordHash = account.password
    local saltedPassword = salt .. password
    local hashedPassword = sha256.digest(saltedPassword):toHex()
    if hashedPassword == storedPasswordHash then
        return true
    else
        return false
    end
end

function accountManager.verifySessionToken(username, token)
    local values = accountManager.getAccountValues(username)
    if not values then return false end

    return token == values.sessionToken
end

return accountManager
