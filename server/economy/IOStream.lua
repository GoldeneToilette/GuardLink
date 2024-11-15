local utils = require("/GuardLink/server/utils/Utils")
local sha256 = require("/GuardLink/server/economy/sha256")


-- creates the directory if it doesnt exist
function initializeAccountsDirectory()
    local guardlinkDir = "/guardlink"
    local serverDir = guardlinkDir .. "/server"
    local economyDir = serverDir .. "/economy"
    local accountsDir = economyDir .. "/accounts"

    if not fs.exists(guardlinkDir) then
        fs.makeDir(accountsDir)
        print("Accounts directory created successfully.")
    end
end


-- Creates Account and stores it in a .json file
function createAccount(name, password)
    local filePath = "/guardlink/server/economy/accounts/" .. name .. ".json"
    if doesAccountExist(name) then
        print("Account '" .. name .. "' already exists!")
        return
    end

    if name ~= "" and password ~= "" then
        local salt = utils.generateSalt(16)
        local saltedPassword = salt .. password


        local hashedPassword = sha256.digest(saltedPassword):toHex()

        local uuid = utils.generateUUID()
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

        local file = fs.open(filePath, "w")
        file.write(textutils.serialize(accountData))
        file.close()

        print("Account '" .. name .. "' created successfully!")
    else
        print("Both name and password cannot be empty!")
    end
end


-- deletes account file 
function deleteAccount(name)
    local filePath = "/guardlink/server/economy/accounts/" .. name .. ".json"

    if doesAccountExist(name) then
        fs.delete(filePath)
        print("Account '" .. name .. "' deleted successfully!")
    end
end


-- returns account values in a table
function getAccountValues(name)
    local filePath = "/guardlink/server/economy/accounts/" .. name .. ".json"

    if doesAccountExist(name) then
        local file = fs.open(filePath, "r")
        if file then
            local contents = file.readAll()
            file.close()

            local success, values = pcall(textutils.unserialize, contents)
            if success then
                return values
            else
                print("Error deserializing account data for '" .. name .. "': " .. values)
                return nil
            end
        else
            print("Error opening file for account '" .. name .. "'")
            return nil
        end
    else
        print("Account '" .. name .. "' does not exist!")
        return nil
    end
end

-- same as above but without sensitive data
function getSanitizedAccountValues(name)
    local accountData = getAccountValues(name)
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
        return nil
    end
end

-- checks if the given account file exists
function doesAccountExist(name)
    local filePath = "/guardlink/server/economy/accounts/" .. name .. ".json"
    return fs.exists(filePath)
end


-- sets the account balance to a specific value
function setAccountBalance(name, newBalance)
    local accountValues = getAccountValues(name)

    if accountValues then
        accountValues.balance = newBalance

        local filePath = "/guardlink/server/economy/accounts/" .. name .. ".json"
        local file = fs.open(filePath, "w")
        file.write(textutils.serialize(accountValues))
        file.close()
    end
end


-- adds money
function addAccountBalance(name, value)
    local accountValues = getAccountValues(name)
    if value <= 0 and Utils.isInteger(value) == false then
        print("Invalid transfer amount.")
        return
    end

    if accountValues then
        accountValues.balance = accountValues.balance + value

        local filePath = "/guardlink/server/economy/accounts/" .. name .. ".json"
        local file = fs.open(filePath, "w")
        file.write(textutils.serialize(accountValues))
        file.close()
    else
        print("Account '" .. name .. "' does not exist.")
    end
end


-- removes money
function subtractAccountBalance(name, value)
    local accountValues = getAccountValues(name)
    if value <= 0 and Utils.isInteger(value) == false then
        print("Invalid transfer amount.")
        return
    end

    if accountValues then
        if accountValues.balance - value >= 0 then
            accountValues.balance = accountValues.balance - value

            local filePath = "/guardlink/server/economy/accounts/" .. name .. ".json"
            local file = fs.open(filePath, "w")
            file.write(textutils.serialize(accountValues))
            file.close()
        else
            print("Balance cannot be negative or result in a negative balance!")
        end
    else
        print("Account '" .. name .. "' does not exist.")
    end
end

-- get the account balance
function getAccountBalance(name)
    local accountValues = getAccountValues(name)
    if accountValues then
        return accountValues.balance
    else
        print("Account '" .. name .. "' does not exist.")
        return nil
    end
end

-- sets the boolean for the banstatus
function setBanStatus(name, isBanned)
    local accountValues = getAccountValues(name)

    if accountValues then
        accountValues.banned = isBanned

        local filePath = "/guardlink/server/economy/accounts/" .. name .. ".json"
        local file = fs.open(filePath, "w")
        file.write(textutils.serialize(accountValues))
        file.close()
    else
        print("Account '" .. name .. "' does not exist.")
    end
end


-- transfers money from one account to the other
function transferBalance(sender, receiver, value)
    if value <= 0 and Utils.isInteger(value) == false then
        print("Invalid transfer amount.")
        return 
    end

    local senderValues = getAccountValues(sender)
    local receiverValues = getAccountValues(receiver)

    if senderValues and receiverValues then
        if senderValues.balance >= value then
            senderValues.balance = senderValues.balance - value
            receiverValues.balance = receiverValues.balance + value

            setAccountBalance(sender, senderValues.balance)
            setAccountBalance(receiver, receiverValues.balance)

            print(value .. " was successfully transferred from " .. sender .. " to " .. receiver)
        else
            print("Insufficient balance in sender's account.")
        end
    else
        print("One or both accounts do not exist.")
    end
end


-- returns all account names in a table (not sorted)
function listAccounts()
    local accountsDir = "/guardlink/server/economy/accounts/"
    local accountNames = {}

    if fs.exists(accountsDir) and fs.isDir(accountsDir) then
        local accountFiles = fs.list(accountsDir)

        for _, filename in ipairs(accountFiles) do
            table.insert(accountNames, filename)
        end
    else
        print("Accounts directory does not exist or is not a directory.")
    end

    return accountNames
end


-- Checks if the given password matches the username, returns true or false
function authenticateUser(username, password)
    local accountValues = getAccountValues(username)
    if accountValues then
        local salt = accountValues.salt
        local storedPasswordHash = accountValues.password
        local saltedPassword = salt .. password
        local hashedPassword = sha256.digest(saltedPassword):toHex()
        if hashedPassword == storedPasswordHash then
            return true
        else
            return false
        end
    else
        print("Account '" .. username .. "' does not exist.")
        return false
    end
  end


return {
    initializeAccountsDirectory = initializeAccountsDirectory,
    createAccount = createAccount,
    deleteAccount = deleteAccount,
    getAccountValues = getAccountValues,
    getAccountBalance = getAccountBalance,
    doesAccountExist = doesAccountExist,
    setAccountBalance = setAccountBalance,
    addAccountBalance = addAccountBalance,
    subtractAccountBalance = subtractAccountBalance,
    transferBalance = transferBalance,
    setBanStatus = setBanStatus,
    listAccounts = listAccounts,
    authenticateUser = authenticateUser,
    getSanitizedAccountValues = getSanitizedAccountValues
}