local accountManager = require "modules.account"
local errors = require "lib.errors"

local walletManager = {}

if not _G.vfs:existsDir("wallets") then 
    _G.logger:fatal("[walletManager] Failed to load walletManager: malformed partitions?") 
    error("Failed to load walletManager: malformed partitions?")
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

function walletManager.getTemplate()
    return _G.utils.deepCopy(walletTemplate)
end

function walletManager.isValidWalletName(name)
    if not name or name:match("^%s*$") then
        return errors.WALLET_NAME_EMPTY
    end
    if name:find("[/\\:*?\"<>|]") then
        return errors.WALLET_INVALID_CHAR
    end
    if #name > 20 then return errors.WALLET_NAME_TOO_LONG end
    if #name < 3 then return errors.WALLET_NAME_TOO_SHORT end
    if _G.vfs:existsFile("wallets/" .. name .. ".json") then
        return errors.WALLET_EXISTS
    end
    return 0
end

function walletManager.exists(name)
    return _G.vfs:existsFile("wallets/" .. name .. ".json")
end

function walletManager.createWallet(name)
    local valid = walletManager.isValidWalletName(name)
    if valid ~= 0 then return valid end

    local filePath = "wallets/" .. name .. ".json"
    local template = walletManager.getTemplate()

    template.name = name
    template.id = _G.utils.randomString(16, "generic")
    template.creationDate = os.date("%Y-%m-%d")
    template.creationTime = os.date("%H:%M:%S")

    _G.vfs:newFile(filePath)
    _G.vfs:writeFile(filePath, textutils.serializeJSON(template))
    return 0
end

function walletManager.getWalletData(name)
    if name then
        return textutils.unserializeJSON(_G.vfs:readFile("wallets/" .. name .. ".json"))
    else
        return nil
    end
end

function walletManager.getWalletValue(name, key)
    local values = walletManager.getWalletData(name)
    if not values then return nil end
    return values[key]    
end

function walletManager.isLocked(name)
    return walletManager.getWalletValue(name, "locked")
end

function walletManager.deleteWallet(name)
    if not walletManager.exists(name) then return errors.WALLET_NOT_FOUND end
    local wallet = walletManager.getWalletData(name)
    for member, _ in pairs(wallet.members) do
        local account = accountManager.getAccountData(member) or {}
        for i = #account.wallets, 1, -1 do
            if account.wallets[i] == wallet.id then
                table.remove(account.wallets, i)
            end
        end
        accountManager.setAccountValue(member, "wallets", account.wallets)
    end
    _G.vfs:deleteFile("wallets/" .. name .. ".json")
    return 0
end

-- NOT SAFE; ONLY USE IF YOU KNOW WHAT YOU ARE DOING 
function walletManager.setWalletValue(name, key, value)
    if not walletManager.exists(name) then return errors.WALLET_NOT_FOUND end
    local values = walletManager.getWalletData(name)
    values[key] = value
    _G.vfs:writeFile("wallets/" .. name .. ".json", textutils.serializeJSON(values))
    return 0
end

function walletManager.listWallets()
    local walletNames = {}

    local files = _G.vfs:listDir("wallets/") or {}
    for _, file in ipairs(files) do
        if file:sub(-5) == ".json" then
            table.insert(walletNames, file:sub(1, -6))
        end
    end
    return walletNames
end

function walletManager.addMember(name, member, role)
    if not walletManager.exists(name) then return errors.WALLET_NOT_FOUND end
    if walletManager.isLocked(name) then return errors.WALLET_LOCKED end

    local members = walletManager.getWalletValue(name, "members") or {}
    if members[member] then return errors.WALLET_MEMBER_EXISTS end
    if role ~= "owner" and role ~= "associate" then
        return errors.WALLET_INVALID_ROLE
    end
    if not accountManager.exists(member) then return errors.WALLET_ACCOUNT_NOT_FOUND end

    members[member] = role
    walletManager.setWalletValue(name, "members", members)
    local accountWallets = accountManager.getAccountValue(member, "wallets") or {}
    table.insert(accountWallets, walletManager.getWalletValue(name, "name"))
    accountManager.setAccountValue(member, "wallets", accountWallets)
    return 0
end

function walletManager.removeMember(name, member)
    if not walletManager.exists(name) then return errors.WALLET_NOT_FOUND end
    if walletManager.isLocked(name) then return errors.WALLET_LOCKED end 
    
    local members = walletManager.getWalletValue(name, "members") or {}    
    if not accountManager.exists(member) then return errors.WALLET_ACCOUNT_NOT_FOUND end
    
    members[member] = nil
    walletManager.setWalletValue(name, "members", members)
    local accountWallets = accountManager.getAccountValue(member, "wallets") or {}
    local walletName = walletManager.getWalletValue(name, "name")
    for i = #accountWallets, 1, -1 do
        if accountWallets[i] == walletName then
            table.remove(accountWallets, i)
        end
    end
    accountManager.setAccountValue(member, "wallets", accountWallets)
    return 0
end

function walletManager.lockWallet(name, flag)
    if not walletManager.exists(name) then return errors.WALLET_NOT_FOUND end
    walletManager.setWalletValue(name, "locked", flag or true)
    return 0
end

function walletManager.changeBalance(operation, name, value)
    if walletManager.isLocked(name) then return errors.WALLET_LOCKED end
    if not walletManager.exists(name) then return errors.WALLET_NOT_FOUND end
    local wallet = walletManager.getWalletData(name)
    if operation == "set" then
        wallet.balance = value
    elseif _G.utils.isInteger(value) then
        if operation == "add" then
            wallet.balance = wallet.balance + value
        elseif operation == "subtract" then
            wallet.balance = wallet.balance - value
        end
    else
        return errors.BALANCE_INVALID_OPERATION
    end
    _G.vfs:writeFile("wallets/" .. name .. ".json", textutils.serializeJSON(wallet))
    return 0
end

function walletManager.transferBalance(sender, receiver, value)
    if value <= 0 or _G.utils.isInteger(value) == false or not value then
        return errors.TRANSACTION_INVALID_NUMBER
    end
    if not walletManager.exists(sender) then return errors.TRANSACTION_UNKNOWN_SENDER end
    if not walletManager.exists(receiver) then return errors.TRANSACTION_UNKNOWN_RECEIVER end
    if sender == receiver then return errors.TRANSACTION_TRANSFER_TO_SELF end

    local senderBalance = walletManager.getWalletValue(sender, "balance")
    if senderBalance < value then return errors.INSUFFICIENT_FUNDS end

    local a = walletManager.changeBalance("subtract", sender, value)
    local b = walletManager.changeBalance("add", receiver, value)
    if a ~= 0 then return a end
    if b ~= 0 then return b end
    return 0
end

return walletManager