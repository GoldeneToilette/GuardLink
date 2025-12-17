local sha256 = require "lib.sha256"
local errors = require "lib.errors"

if not _G.vfs:existsDir("accounts") then 
    _G.logger:fatal("[AccountManager] Failed to load accountManager: malformed partitions?") 
    error("Failed to load accountManager: malformed partitions?")
end

local accountManager = {}

local accountTemplate = {
    name = "",
    uuid = "",
    role = "",
    creationDate = "",
    creationTime = "",
    twofactor = false,
    ban = {
        active = false,
        startTime = nil,
        duration = 0,
        reason = ""
    },
    password = "",
    salt = "",
    wallets = {}
}

function accountManager.isValidAccountName(name)
    if not name then return errors.ACCOUNT_NAME_EMPTY end
    name = name:match("^%s*(.-)%s*$")
    if name == "" then return errors.ACCOUNT_NAME_EMPTY end
    if name:find("[/\\:*?\"<>|]") then return errors.ACCOUNT_INVALID_CHAR end
    if #name > 20 then return errors.ACCOUNT_NAME_TOO_LONG end
    if #name < 3 then return errors.ACCOUNT_NAME_TOO_SHORT end
    if _G.vfs:existsFile("accounts/" .. name .. ".json") then return errors.ACCOUNT_EXISTS end
    return 0
end

function accountManager.getTemplate()
    return _G.utils.deepCopy(accountTemplate)
end

function accountManager.exists(name)
    return _G.vfs:existsFile("accounts/" .. name .. ".json")
end

function accountManager.createAccount(name, password)
    local valid = accountManager.isValidAccountName(name)
    if valid ~= 0 then
        _G.logger:error(valid.log)
        return valid
    end
    if not password or password == "" then
        _G.logger:error(errors.ACCOUNT_PASSWORD_EMPTY.log)
        return errors.ACCOUNT_PASSWORD_EMPTY
    end

    local filePath = "accounts/" .. name .. ".json"
    local template = accountManager.getTemplate()
    template.name = name
    template.uuid = _G.utils.generateUUID()
    template.creationDate = os.date("%Y-%m-%d")
    template.creationTime = os.date("%H:%M:%S")
    local salt = _G.utils.randomString(16, "generic")
    template.salt = salt
    template.password = sha256.digest(salt .. password):toHex()

    _G.vfs:newFile(filePath)
    _G.vfs:writeFile(filePath, textutils.serializeJSON(template))
    return 0
end

function accountManager.deleteAccount(name)
    _G.vfs:deleteFile("accounts/" .. name .. ".json")
end

function accountManager.getAccountData(name)
    if name and accountManager.exists(name) then
        return textutils.unserializeJSON(_G.vfs:readFile("accounts/" .. name .. ".json"))
    else
        return nil
    end
end

function accountManager.setAccountValue(name, key, value)
    local values = accountManager.getAccountData(name)
    values[key] = value
    _G.vfs:writeFile("accounts/" .. name .. ".json", textutils.serializeJSON(values))
end

function accountManager.getAccountValue(name, key)
    local values = accountManager.getAccountData(name)
    if not values then return nil end
    return values[key]
end

function accountManager.listAccounts()
    local accountNames = {}

    local files = _G.vfs:listDir("accounts/") or {}
    for _, file in ipairs(files) do
        if file:sub(-5) == ".json" then
            table.insert(accountNames, file:sub(1, -6))
        end
    end
    return accountNames
end

function accountManager.getSanitizedAccountValues(name)
    local accountData = accountManager.getAccountData(name)
    if accountData then
        return {
            name = accountData.name,
            uuid = accountData.uuid,
            creationDate = accountData.creationDate,
            creationTime = accountData.creationTime,
            ban = accountData.ban,
            role = accountData.role,
            wallets = accountData.wallets
        }
    else
        return nil
    end
end

function accountManager.authenticateUser(username, password)
    local account = accountManager.getAccountData(username)
    if not account then return errors.ACCOUNT_NOT_FOUND end
    if username == "" then return errors.ACCOUNT_NAME_EMPTY end
    if password == "" then return errors.ACCOUNT_PASSWORD_EMPTY end
    
    local salt = account.salt
    local storedPasswordHash = account.password
    local saltedPassword = salt .. password
    local hashedPassword = sha256.digest(saltedPassword):toHex()
    if hashedPassword == storedPasswordHash then
        return 0
    else
        return errors.INVALID_CREDENTIALS
    end
end

function accountManager.banAccount(name, duration, reason)
    local account = accountManager.getAccountData(name)
    if not account then return false end

    local seconds = 0
    for k, v in pairs(duration) do
        if v < 1 then return false end
        if k == "seconds" then
            seconds = seconds + v
        elseif k == "minutes" then
            seconds = seconds + (v*60)
        elseif k == "hours" then
            seconds = seconds + (v*3600)
        elseif k == "days" then
            seconds = seconds + (v*86400)
        elseif k == "permanent" then
            seconds = -1
        end
    end

    account.ban = {
        active = true,
        startTime = os.epoch("utc"),
        duration = (seconds == -1) and -1 or (seconds * 1000),
        reason = reason or ""
    }

    accountManager.setAccountValue(name, "ban", account.ban)
    return true
end

function accountManager.pardon(name)
    local account = accountManager.getAccountData(name)
    if not account then return false end
    account.ban = {
        active = false,
        startTime = nil,
        duration = 0,
        reason = ""
    }
    accountManager.setAccountValue(name, "ban", account.ban)
    return true
end

function accountManager.isBanned(name)
    local account = accountManager.getAccountData(name)
    if not account then return false end

    local ban = account.ban
    if not ban.active then return false end
    if ban.duration == -1 then return true, ban.reason end
    if not ban.startTime then return false end

    local now = os.epoch("utc")
    if account.ban.duration == -1 then return true, account.ban.reason end
    if now - account.ban.startTime >= account.ban.duration then
        account.ban = {
            active = false,
            startTime = nil,
            duration = 0,
            reason = ""
        }
        accountManager.setAccountValue(name, "ban", account.ban)
        return false
    end

    return true, account.ban.reason
end

return accountManager
