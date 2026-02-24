local errors = requireC("/GuardLink/server/lib/errors.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")

local walletManager = {}
walletManager.__index = walletManager

local log

function walletManager.new(vfs, accounts, logger)
    local self = setmetatable({}, walletManager)
    self.vfs = vfs
    self.accountManager = accounts

    log = logger:createInstance("wallet", {timestamp = true, level = "INFO", clear = true})
    if not vfs:existsDir("wallets") then
        log:fatal("Failed to load walletManager: malformed partitions?") 
        error("Failed to load walletManager: malformed partitions?") 
    end
    return self
end

local walletTemplate = {
    id = "",
    name = "",
    members = {},
    balance = 0,
    locked = false,
    creationDate = "",
    creationTime = ""
}

function walletManager:getTemplate()
    return utils.deepCopy(walletTemplate)
end

function walletManager:isValidWalletName(name)
    if not name or name:match("^%s*$") then
        return errors.WALLET_NAME_EMPTY
    end
    if name:find("[/\\:*?\"<>|§]") then
        return errors.WALLET_INVALID_CHAR
    end
    if #name > 20 then return errors.WALLET_NAME_TOO_LONG end
    if #name < 3 then return errors.WALLET_NAME_TOO_SHORT end
    if self.vfs:existsFile("wallets/" .. name .. ".json") then
        return errors.WALLET_EXISTS
    end
    return 0
end

function walletManager:exists(name)
    return self.vfs:existsFile("wallets/" .. name .. ".json")
end

function walletManager:createWallet(name)
    local valid = self:isValidWalletName(name)
    if valid ~= 0 then return valid end

    local filePath = "wallets/" .. name .. ".json"
    local template = self:getTemplate()

    template.name = name
    template.id = utils.randomString(16, "generic")
    template.creationDate = os.date("%Y-%m-%d")
    template.creationTime = os.date("%H:%M:%S")

    self.vfs:newFile(filePath)
    self.vfs:writeFile(filePath, textutils.serializeJSON(template))
    return 0
end

function walletManager:getWalletData(name)
    if name then
        return textutils.unserializeJSON(self.vfs:readFile("wallets/" .. name .. ".json"))
    else
        return nil
    end
end

function walletManager:getWalletValue(name, key)
    local values = self:getWalletData(name)
    if not values then return nil end
    return values[key]    
end

function walletManager:isLocked(name)
    return self:getWalletValue(name, "locked")
end

function walletManager:deleteWallet(name)
    if not self:exists(name) then return errors.WALLET_NOT_FOUND end
    local wallet = self:getWalletData(name)
    for member, _ in pairs(wallet.members) do
        local account = self.accountManager.getAccountData(member) or {}
        for i = #account.wallets, 1, -1 do
            if account.wallets[i] == wallet.id then
                table.remove(account.wallets, i)
            end
        end
        self.accountManager.setAccountValue(member, "wallets", account.wallets)
    end
    self.vfs:deleteFile("wallets/" .. name .. ".json")
    return 0
end

-- NOT SAFE; ONLY USE IF YOU KNOW WHAT YOU ARE DOING 
function walletManager:setWalletValue(name, key, value)
    if not self:exists(name) then return errors.WALLET_NOT_FOUND end
    local values = self:getWalletData(name)
    values[key] = value
    self.vfs:writeFile("wallets/" .. name .. ".json", textutils.serializeJSON(values))
    return 0
end

function walletManager:listWallets()
    local walletNames = {}

    local files = self.vfs:listDir("wallets/") or {}
    for _, file in ipairs(files) do
        if file:sub(-5) == ".json" then
            table.insert(walletNames, file:sub(1, -6))
        end
    end
    return walletNames
end

function walletManager:addMember(name, member, role)
    if not self:exists(name) then return errors.WALLET_NOT_FOUND end
    if self:isLocked(name) then return errors.WALLET_LOCKED end

    local members = self:getWalletValue(name, "members") or {}
    if members[member] then return errors.WALLET_MEMBER_EXISTS end
    if role ~= "owner" and role ~= "associate" then
        return errors.WALLET_INVALID_ROLE
    end
    if not self.accountManager.exists(member) then return errors.WALLET_ACCOUNT_NOT_FOUND end

    members[member] = role
    self:setWalletValue(name, "members", members)
    local accountWallets = self.accountManager.getAccountValue(member, "wallets") or {}
    table.insert(accountWallets, self:getWalletValue(name, "name"))
    self.accountManager.setAccountValue(member, "wallets", accountWallets)
    return 0
end

function walletManager:removeMember(name, member)
    if not self:exists(name) then return errors.WALLET_NOT_FOUND end
    if self:isLocked(name) then return errors.WALLET_LOCKED end 
    
    local members = self:getWalletValue(name, "members") or {}    
    if not self.accountManager.exists(member) then return errors.WALLET_ACCOUNT_NOT_FOUND end
    
    members[member] = nil
    self:setWalletValue(name, "members", members)
    local accountWallets = self.accountManager.getAccountValue(member, "wallets") or {}
    local walletName = self:getWalletValue(name, "name")
    for i = #accountWallets, 1, -1 do
        if accountWallets[i] == walletName then
            table.remove(accountWallets, i)
        end
    end
    self.accountManager.setAccountValue(member, "wallets", accountWallets)
    return 0
end

function walletManager:lockWallet(name, flag)
    if not self:exists(name) then return errors.WALLET_NOT_FOUND end
    self:setWalletValue(name, "locked", flag or true)
    return 0
end

function walletManager:changeBalance(operation, name, value)
    if self:isLocked(name) then return errors.WALLET_LOCKED end
    if not self:exists(name) then return errors.WALLET_NOT_FOUND end
    local wallet = self:getWalletData(name)
    if operation == "set" then
        wallet.balance = value
    elseif utils.isInteger(value) then
        if operation == "add" then
            wallet.balance = wallet.balance + value
        elseif operation == "subtract" then
            wallet.balance = wallet.balance - value
        end
    else
        return errors.BALANCE_INVALID_OPERATION
    end
    self.vfs:writeFile("wallets/" .. name .. ".json", textutils.serializeJSON(wallet))
    return 0
end

function walletManager:transferBalance(sender, receiver, value)
    if value <= 0 or utils.isInteger(value) == false or not value then
        return errors.TRANSACTION_INVALID_NUMBER
    end
    if not walletManager.exists(sender) then return errors.TRANSACTION_UNKNOWN_SENDER end
    if not walletManager.exists(receiver) then return errors.TRANSACTION_UNKNOWN_RECEIVER end
    if sender == receiver then return errors.TRANSACTION_TRANSFER_TO_SELF end

    local senderBalance = self:getWalletValue(sender, "balance")
    if senderBalance < value then return errors.INSUFFICIENT_FUNDS end

    local a = self:changeBalance("subtract", sender, value)
    local b = self:changeBalance("add", receiver, value)
    if a ~= 0 then return a end
    if b ~= 0 then return b end
    return 0
end

local service = {
    name = "wallets",
    deps = {"vfs", "accounts"},
    init = function(ctx)
        return walletManager.new(ctx.services["vfs"], ctx.services["accounts"], ctx.services["logger"])
    end,
    runtime = nil,
    tasks = nil,
    shutdown = nil,
    api = {
        ["wallets"] = {
            create = function(self, args) return self:createWallet(args.name) end,
            delete = function(self, args) return self:deleteWallet(args.name) end,
            exists = function(self, args) return self:exists(args.name) end,
            list = function(self) return self:listWallets() end,
            add_member = function(self, args) return self:addMember(args.wallet, args.member, args.role) end,
            remove_member = function(self, args) return self:removeMember(args.wallet, args.member) end,
            lock = function(self, args) return self:lockWallet(args.wallet, args.flag) end,
            change_balance = function(self, args) return self:changeBalance(args.op, args.wallet, args.value) end,
            transfer = function(self, args) return self:transferBalance(args.sender, args.receiver, args.value) end,
            get = function(self, args) return self:getWalletData(args.wallet) end,
            get_value = function(self, args) return self:getWalletValue(args.wallet, args.key) end,
            is_locked = function(self, args) return self:isLocked(args.wallet) end
        }
    }
}

return service