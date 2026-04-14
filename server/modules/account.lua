local sha256 = requireC("/GuardLink/server/lib/sha256.lua")
local errors = requireC("/GuardLink/server/lib/errors.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")
local roles = requireC("/GuardLink/server/lib/roles.lua")
local audit = requireC("/GuardLink/server/lib/audit.lua")

local accountManager = {}
accountManager.__index = accountManager

local log
local invitePath = "/GuardLink/server/config/invite_codes.json"

function accountManager.new(ctx)
    local self = setmetatable({}, accountManager)
    self.ctx = ctx
    log = ctx.services["logger"]:createInstance("accounts", {timestamp = true, level = "INFO", clear = true})

    if not fs.exists(invitePath) then
        log:info("invite_codes config not found! Generating...")
        local f = fs.open(invitePath, "w")
        f.write("")
        f.close()
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
    wallets = {},
    record = {
        debt = { total = 0, entries = {} },
        claims = { total = 0, entries = {} }
    },
    credit_score = 100,
    pending_money = 0,
    primaryWallet = nil,
}

function accountManager:vfs()
    return self.ctx.services["vfs"]
end

function accountManager:isValidInvite(code)
    local f = fs.open(invitePath, "r")
    if not f then return errors.UNKNOWN_INVITE_CODE end
    local content = f.readAll()
    f.close()
    if not content or content == "" then return errors.UNKNOWN_INVITE_CODE end
    local tbl = textutils.unserializeJSON(content)
    if not tbl or not tbl[code] then return errors.UNKNOWN_INVITE_CODE end
    return 0
end

function accountManager:getInviteCodes()
    local f = fs.open(invitePath, "r")
    local content = f.readAll()
    f.close()
    if content and content ~= "" then
        return textutils.unserializeJSON(content)
    end
    return nil
end

function accountManager:useInvite(code)
    local f = fs.open(invitePath, "r")
    local content = f.readAll()
    f.close()
    if content and content ~= "" then
        local tbl = textutils.unserializeJSON(content)
        if tbl[code] then
            tbl[code].uses = tbl[code].uses - 1
            local usesLeft = tbl[code].uses
            if usesLeft < 1 then tbl[code] = nil end
            local w = fs.open(invitePath, "w")
            w.write(textutils.serializeJSON(tbl))
            w.close()
            log:debug("Invite code used: " .. code .. ", uses left: " .. (tbl[code] and usesLeft or 0))
        else
            return errors.UNKNOWN_INVITE_CODE
        end
    end
    return 0
end

function accountManager:deleteInvite(code)
    local f = fs.open(invitePath, "r")
    local content = f.readAll()
    f.close()
    if content and content ~= "" then
        local tbl = textutils.unserializeJSON(content)
        if tbl[code] then
            tbl[code] = nil
            local w = fs.open(invitePath, "w")
            w.write(textutils.serializeJSON(tbl))
            w.close()
            log:debug("Invite code deleted: " .. code)
        else
            return errors.UNKNOWN_INVITE_CODE
        end
    end
    return 0
end

function accountManager:createInvite(code, uses)
    local f = fs.open(invitePath, "r")
    local content = f.readAll()
    f.close()
    if not content or content == "" then content = "{}" end
    local tbl = textutils.unserializeJSON(content)
    tbl[code or utils.randomString(8, "generic")] = {uses = uses or 1}
    local w = fs.open(invitePath, "w")
    w.write(textutils.serializeJSON(tbl))
    w.close()
    log:debug("Created invite code with " .. (uses or 1) .. " uses")
    return 0
end

function accountManager:isValidAccountName(name)
    if not name then return errors.ACCOUNT_NAME_EMPTY end
    name = name:match("^%s*(.-)%s*$")
    if name == "" then return errors.ACCOUNT_NAME_EMPTY end
    if name:find("[/\\:*?\"<>|§]") then return errors.ACCOUNT_INVALID_CHAR end
    if #name > 20 then return errors.ACCOUNT_NAME_TOO_LONG end
    if #name < 3 then return errors.ACCOUNT_NAME_TOO_SHORT end
    if self:vfs():existsFile("accounts/" .. name .. ".json") then return errors.ACCOUNT_EXISTS end
    return 0
end

function accountManager:getTemplate()
    return utils.deepCopy(accountTemplate)
end

function accountManager:exists(name)
    return self:vfs():existsFile("accounts/" .. name .. ".json")
end

function accountManager:createAccount(name, password, role)
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

    self:vfs():newFile(filePath)
    self:vfs():writeFile(filePath, textutils.serializeJSON(template))

    local defaultRole = role or self.ctx:execute("kernel.get_config", "identity").defaultRole
    if defaultRole then
        self:assignRole(name, defaultRole)
    end
    audit.log("accounts", name, {"CREATE"}, self:vfs())
    return 0
end

function accountManager:deleteAccount(name)
    if not name or not self:exists(name) then return errors.ACCOUNT_NOT_FOUND end
    local walletList = self:getAccountValue(name, "wallets") or {}
    local walletService = self.ctx.services["wallets"]
    for _, wName in ipairs(walletList) do
        walletService:removeMember(wName, name)
    end
    local role = self:getAccountValue(name, "role")
    if role and role ~= "" then roles.removeMember(role, name) end
    self:vfs():deleteFile("accounts/" .. name .. ".json")
    audit.log("accounts", name, {"DELETE"}, self:vfs())
    return 0
end

function accountManager:getAccountData(name)
    if name and self:exists(name) then
        return textutils.unserializeJSON(self:vfs():readFile("accounts/" .. name .. ".json"))
    else
        return nil
    end
end

function accountManager:setAccountValue(name, key, value)
    local values = self:getAccountData(name)
    values[key] = value
    self:vfs():writeFile("accounts/" .. name .. ".json", textutils.serializeJSON(values))
end

function accountManager:getAccountValue(name, key)
    local values = self:getAccountData(name)
    if not values then return nil end
    return values[key]
end

function accountManager:listAccounts()
    local accountNames = {}
    local files = self:vfs():listDir("accounts/") or {}
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
            wallets = accountData.wallets,
            primaryWallet = accountData.primaryWallet,
            credit_score = accountData.credit_score,
            pending_money = accountData.pending_money,
            record = accountData.record
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

    local hashedPassword = sha256.digest(account.salt .. password):toHex()
    if hashedPassword == account.password then
        audit.log("accounts", username, {"AUTH_OK"}, self:vfs())
        return 0
    else
        audit.log("accounts", username, {"AUTH_FAIL"}, self:vfs())
        return errors.INVALID_CREDENTIALS
    end
end

function accountManager:banAccount(name, duration, reason)
    local account = self:getAccountData(name)
    if not account then return errors.ACCOUNT_NOT_FOUND end

    local seconds = 0
    for k, v in pairs(duration) do
        if not v or v < 1 then return errors.INVALID_TIME_FORMAT end
        if k == "seconds" then seconds = seconds + v
        elseif k == "minutes" then seconds = seconds + (v * 60)
        elseif k == "hours" then seconds = seconds + (v * 3600)
        elseif k == "days" then seconds = seconds + (v * 86400)
        elseif k == "permanent" then seconds = -1
        end
    end

    account.ban = {
        active = true,
        startTime = os.epoch("utc"),
        duration = (seconds == -1) and -1 or (seconds * 1000),
        reason = reason or ""
    }
    self:setAccountValue(name, "ban", account.ban)
    audit.log("accounts", name, {"BAN", textutils.serialize(duration), reason}, self:vfs())
    return 0
end

function accountManager:pardon(name)
    local account = self:getAccountData(name or "")
    if not account then return errors.ACCOUNT_NOT_FOUND end
    self:setAccountValue(name, "ban", {
        active = false,
        startTime = nil,
        duration = 0,
        reason = ""
    })
    audit.log("accounts", name, {"PARDON"}, self:vfs())
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
    if now - ban.startTime >= ban.duration then
        self:setAccountValue(name, "ban", {
            active = false,
            startTime = nil,
            duration = 0,
            reason = ""
        })
        return false
    end

    return true, ban.reason
end

function accountManager:changePassword(name, oldPassword, newPassword)
    local account = self:getAccountData(name)
    if not account then return errors.ACCOUNT_NOT_FOUND end
    if not newPassword or newPassword == "" then return errors.ACCOUNT_PASSWORD_EMPTY end
    
    local hashedOld = sha256.digest(account.salt .. oldPassword):toHex()
    if hashedOld ~= account.password then return errors.INVALID_CREDENTIALS end

    local salt = utils.randomString(16, "generic")
    local hashedNew = sha256.digest(salt .. newPassword):toHex()
    self:setAccountValue(name, "salt", salt)
    self:setAccountValue(name, "password", hashedNew)
    audit.log("accounts", name, {"PASSWORD_CHANGE"}, self:vfs())
    return 0
end

function accountManager:assignRole(name, roleName)
    if not self:exists(name) then return errors.ACCOUNT_NOT_FOUND end
    if not roles.exists(roleName) then return errors.ROLE_NOT_FOUND end
    if roles.isFull(roleName) then return errors.ROLE_FULL end
    local current = self:getAccountValue(name, "role")
    if current and current ~= "" then
        roles.removeMember(current, name)
    end
    self:setAccountValue(name, "role", roleName)
    roles.addMember(roleName, name)
    audit.log("accounts", name, {"ROLE_ASSIGN",roleName}, self:vfs())
    return 0
end

function accountManager:unassignRole(name)
    if not self:exists(name) then return errors.ACCOUNT_NOT_FOUND end
    local current = self:getAccountValue(name, "role")
    if not current or current == "" then return errors.ACCOUNT_HAS_NO_ROLE end
    roles.removeMember(current, name)
    self:setAccountValue(name, "role", "")
    audit.log("accounts", name, {"ROLE_UNASSIGN"}, self:vfs())
    return 0
end

function accountManager:hasPermission(name, permission)
    if not self:exists(name) then return false end
    local role = self:getAccountValue(name, "role")
    if not role or role == "" then return false end
    return roles.hasPermission(role, permission)
end

local service = {
    name = "accounts",
    deps = {"vfs"},
    init = function(ctx)
        return accountManager.new(ctx)
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
            is_banned = function(self, args) return self:isBanned(args.name) end,
            get_invite_codes = function(self) return self:getInviteCodes() end,
            use_invite = function(self, args) return self:useInvite(args.code) end,
            delete_invite = function(self, args) return self:deleteInvite(args.code) end,
            create_invite = function(self, args) return self:createInvite(args.code, args.uses) end,
            assign_role = function(self, args) return self:assignRole(args.name, args.role) end,
            unassign_role = function(self, args) return self:unassignRole(args.name) end,
            has_permission = function(self, args) return self:hasPermission(args.name, args.permission) end,
            change_password = function(self, args) return self:changePassword(args.name, args.old_password, args.new_password) end,
        }
    }
}

return service