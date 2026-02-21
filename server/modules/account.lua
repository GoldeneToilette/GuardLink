local sha256 = requireC("/GuardLink/server/lib/sha256.lua")
local errors = requireC("/GuardLink/server/lib/errors.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")

local accountManager = {}
accountManager.__index = accountManager

local log

function accountManager.new(vfs, logger)
    local self = setmetatable({}, accountManager)
    self.vfs = vfs
    log = logger:createInstance("accounts", {timestamp = true, level = "INFO", clear = true})
    if not vfs:existsDir("accounts") then
        log:fatal("Failed to load accountManager: malformed partitions?") 
        error("Failed to load accountManager: malformed partitions?")        
    end
    return self
end

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

function accountManager:isValidAccountName(name)
    if not name then return errors.ACCOUNT_NAME_EMPTY end
    name = name:match("^%s*(.-)%s*$")
    if name == "" then return errors.ACCOUNT_NAME_EMPTY end
    if name:find("[/\\:*?\"<>|]") then return errors.ACCOUNT_INVALID_CHAR end
    if #name > 20 then return errors.ACCOUNT_NAME_TOO_LONG end
    if #name < 3 then return errors.ACCOUNT_NAME_TOO_SHORT end
    if self.vfs:existsFile("accounts/" .. name .. ".json") then return errors.ACCOUNT_EXISTS end
    return 0
end

function accountManager:getTemplate()
    return utils.deepCopy(accountTemplate)
end

function accountManager:exists(name)
    return self.vfs:existsFile("accounts/" .. name .. ".json")
end

function accountManager:createAccount(name, password)
    local valid = self:isValidAccountName(name)
    if valid ~= 0 then
        log:info(valid.log)
        return valid
    end
    if not password or password == "" then
        log:info(errors.ACCOUNT_PASSWORD_EMPTY.log)
        return errors.ACCOUNT_PASSWORD_EMPTY
    end

    local filePath = "accounts/" .. name .. ".json"
    local template = self:getTemplate()
    template.name = name
    template.uuid = utils.generateUUID()
    template.creationDate = os.date("%Y-%m-%d")
    template.creationTime = os.date("%H:%M:%S")
    local salt = utils.randomString(16, "generic")
    template.salt = salt
    template.password = sha256.digest(salt .. password):toHex()

    self.vfs:newFile(filePath)
    self.vfs:writeFile(filePath, textutils.serializeJSON(template))
    return 0
end

function accountManager:deleteAccount(name)
    if not name or not self:exists(name) then return errors.ACCOUNT_NOT_FOUND end
    self.vfs:deleteFile("accounts/" .. name .. ".json")
    return 0
end

function accountManager:getAccountData(name)
    if name and self:exists(name) then
        return textutils.unserializeJSON(self.vfs:readFile("accounts/" .. name .. ".json"))
    else
        return nil
    end
end

function accountManager:setAccountValue(name, key, value)
    local values = self:getAccountData(name)
    values[key] = value
    self.vfs:writeFile("accounts/" .. name .. ".json", textutils.serializeJSON(values))
end

function accountManager:getAccountValue(name, key)
    local values = self:getAccountData(name)
    if not values then return nil end
    return values[key]
end

function accountManager:listAccounts()
    local accountNames = {}

    local files = self.vfs:listDir("accounts/") or {}
    for _, file in ipairs(files) do
        if file:sub(-5) == ".json" then
            table.insert(accountNames, file:sub(1, -6))
        end
    end
    return accountNames
end

function accountManager:getSanitizedAccountValues(name)
    local accountData = self:getAccountData(name)
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

function accountManager:authenticateUser(username, password)
    local account = self:getAccountData(username)
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

function accountManager:banAccount(name, duration, reason)
    local account = self:getAccountData(name)
    if not account then return errors.ACCOUNT_NOT_FOUND end

    local seconds = 0
    for k, v in pairs(duration) do
        if not v or v < 1 then return errors.INVALID_TIME_FORMAT end
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

    self:setAccountValue(name, "ban", account.ban)
    return 0
end

function accountManager:pardon(name)
    local account = self:getAccountData(name or "")
    if not account then return errors.ACCOUNT_NOT_FOUND end
    account.ban = {
        active = false,
        startTime = nil,
        duration = 0,
        reason = ""
    }
    self:setAccountValue(name, "ban", account.ban)
    return 0
end

function accountManager:isBanned(name)
    local account = self:getAccountData(name)
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
        self:setAccountValue(name, "ban", account.ban)
        return false
    end

    return true, account.ban.reason
end

local service = {
    name = "accounts",
    deps = {"vfs"},
    init = function(ctx)
        return accountManager.new(ctx.services["vfs"], ctx.services["logger"])
    end,
    runtime = nil,
    tasks = nil,
    shutdown = nil,
    api = {
        ["accounts"] = {
            create = function(self, args) return self:createAccount(args.name, args.password) end,
            delete = function(self, args) return self:deleteAccount(args.name) end,
            exists = function(self, args) return self:exists(args.name) end,
            list = function(self) return self:listAccounts() end,
            get = function(self, args) return self:getAccountData(args.name) end,
            get_sanitized = function(self, args) return self:getSanitizedAccountValues(args.name) end,
            get_value = function(self, args) return self:getAccountValue(args.name, args.key) end,
            set_value = function(self, args) return self:setAccountValue(args.name, args.key, args.value) end,
            authenticate = function(self, args) return self:authenticateUser(args.name, args.password) end,
            ban = function(self, args) return self:banAccount(args.name, args.duration, args.reason) end,
            pardon = function(self, args) return self:pardon(args.name) end,
            is_banned = function(self, args) return self:isBanned(args.name) end
        }
    }
}

return service
