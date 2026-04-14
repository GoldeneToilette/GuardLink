local utils = requireC("/GuardLink/server/lib/utils.lua")
local errors = requireC("/GuardLink/server/lib/errors.lua")
local audit = requireC("/GuardLink/server/lib/audit.lua")

local debt = {}
debt.__index = debt

local log

function debt.new(ctx)
    local self = setmetatable({}, debt)
    self.ctx = ctx
    self.rules = ctx.configs["rules"]

    self.entityTypes = {
        account = true,
        government = true,
        company = true
    }
    log = ctx.services["logger"]:createInstance("debt", {timestamp = true, level = "INFO", clear = true})

    return self
end

function debt:vfs()
    return self.ctx.services["vfs"]
end

function debt:accounts()
    return self.ctx.services["accounts"]
end

function debt:wallets()
    return self.ctx.services["wallets"]
end

function debt:nation()
    return self.ctx.services["nation"]
end

--[[
Entity format should be like this:
{
    type = "account|government|company",
    name = "cool_name" -- not needed for government
}
]]--
function debt:validateEntity(entity)
    if not entity.type or not type(entity.type) == "string" or not self.entityTypes[entity.type] then
        return errors.INVALID_ENTITY_TYPE
    end
    if (entity.type ~= "government" and not entity.name) or type(entity.name) ~= "string" or entity.name == "" then
        return errors.INVALID_ENTITY_NAME
    end
    if entity.type == "account" then
        if not self:accounts():exists(entity.name) then return errors.ACCOUNT_NOT_FOUND end
    elseif entity.type == "government" then
        -- no checks needed, treasury always exists
    elseif entity.type == "company" then
        -- IMPLEMENT ONCE COMPANIES EXIST!!!
    end
    return 0
end

local emptyRecord = { debt = { total = 0, entries = {} }, claims = { total = 0, entries = {} } }

function debt:getEntityRecord(entity)
    if entity.type == "account" then
        return self:accounts():getAccountValue(entity.name, "record") or utils.deepCopy(emptyRecord)
    elseif entity.type == "government" then
        local content = self:vfs():existsFile("debts/government.json") and self:vfs():readFile("debts/government.json")
        if not content or content == "" then return utils.deepCopy(emptyRecord) end
        return textutils.unserializeJSON(content) or utils.deepCopy(emptyRecord)
    end
end

function debt:saveEntityRecord(entity, record)
    if entity.type == "account" then
        self:accounts():setAccountValue(entity.name, "record", record)
    elseif entity.type == "government" then
        if not self:vfs():existsFile("debts/government.json") then self:vfs():newFile("debts/government.json") end
        self:vfs():writeFile("debts/government.json", textutils.serializeJSON(record))
    end
end

function debt:add(debtor, creditor, amount, reason, sweep)
    local a, b = self:validateEntity(debtor), self:validateEntity(creditor)
    if a ~= 0 then return a elseif b ~= 0 then return b end
    if not amount or amount <= 0 then return errors.INVALID_AMOUNT end

    local id = utils.generateUUID()
    local filePath = "debts/" .. id .. ".json"
    self:vfs():newFile(filePath)
    self:vfs():writeFile(filePath, textutils.serializeJSON({
        id = id,
        debtor = debtor,
        creditor = creditor,
        amount = amount,
        reason      = reason or "unknown_reason",
        since       = os.epoch("utc"),
        sweep       = sweep or false,
        persistence = 0
    }))

    local debtorRecord = self:getEntityRecord(debtor)
    table.insert(debtorRecord.debt.entries, id)
    debtorRecord.debt.total = debtorRecord.debt.total + amount
    self:saveEntityRecord(debtor, debtorRecord)

    local creditorRecord = self:getEntityRecord(creditor)
    table.insert(creditorRecord.claims.entries, id)
    creditorRecord.claims.total = creditorRecord.claims.total + amount
    self:saveEntityRecord(creditor, creditorRecord)

    if debtor.type == "account" then
        audit.log("accounts", debtor.name, {"DEBT_ADD", tostring(amount), reason or ""}, self:vfs())
    end
    if creditor.type == "account" then
        audit.log("accounts", creditor.name, {"RECEIVABLE_ADD", tostring(amount), reason or ""}, self:vfs())
    end

    log:debug("Debt created: " .. id .. " | debtor: " .. (debtor.name or "government") .. " | amount: " .. tostring(amount))
    return id
end

function debt:list()
    local files = self:vfs():listDir("debts/") or {}
    local results = {}
    for _, file in ipairs(files) do
        if file ~= "government.json" then
            local entry = self:get(file:sub(1, -6))
            if type(entry) == "table" then
                table.insert(results, entry)
            end
        end
    end
    return results
end

function debt:exists(debtID)
    if debtID == "government" then return false end
    return self:vfs():existsFile("debts/" .. debtID .. ".json")
end

function debt:get(debtID)
    if not self:exists(debtID) then return errors.DEBT_NOT_FOUND end
    return textutils.unserializeJSON(self:vfs():readFile("debts/" .. debtID .. ".json"))
end

function debt:remove(debtID)
    local entry = self:get(debtID)
    if type(entry) ~= "table" then return entry end

    local debtorRecord   = self:getEntityRecord(entry.debtor)
    local creditorRecord = self:getEntityRecord(entry.creditor)

    for i = #debtorRecord.debt.entries, 1, -1 do
        if debtorRecord.debt.entries[i] == debtID then table.remove(debtorRecord.debt.entries, i) break end
    end
    debtorRecord.debt.total = debtorRecord.debt.total - entry.amount

    for i = #creditorRecord.claims.entries, 1, -1 do
        if creditorRecord.claims.entries[i] == debtID then table.remove(creditorRecord.claims.entries, i) break end
    end
    creditorRecord.claims.total = creditorRecord.claims.total - entry.amount

    self:saveEntityRecord(entry.debtor,   debtorRecord)
    self:saveEntityRecord(entry.creditor, creditorRecord)
    self:vfs():deleteFile("debts/" .. debtID .. ".json")

    if entry.debtor.type == "account" then
        audit.log("accounts", entry.debtor.name, {"DEBT_REMOVE", tostring(entry.amount), entry.reason}, self:vfs())
    end

    log:debug("Debt removed: " .. debtID)
    return 0
end

function debt:set(debtID, amount)
    if not amount or amount <= 0 then return errors.INVALID_AMOUNT end
    local entry = self:get(debtID)
    if type(entry) ~= "table" then return entry end

    local delta = amount - entry.amount

    local debtorRecord   = self:getEntityRecord(entry.debtor)
    local creditorRecord = self:getEntityRecord(entry.creditor)
    debtorRecord.debt.total   = debtorRecord.debt.total   + delta
    creditorRecord.claims.total = creditorRecord.claims.total + delta
    self:saveEntityRecord(entry.debtor,   debtorRecord)
    self:saveEntityRecord(entry.creditor, creditorRecord)

    entry.amount = amount
    self:vfs():writeFile("debts/" .. debtID .. ".json", textutils.serializeJSON(entry))

    if entry.debtor.type == "account" then
        audit.log("accounts", entry.debtor.name, {"DEBT_SET", tostring(amount)}, self:vfs())
    end

    log:debug("Debt updated: " .. debtID .. " | amount: " .. tostring(amount))
    return 0
end

function debt:transferDebt(newDebtor, debtID)
    local v = self:validateEntity(newDebtor)
    if v ~= 0 then return v end
    local entry = self:get(debtID)
    if type(entry) ~= "table" then return entry end

    local oldDebtorRecord = self:getEntityRecord(entry.debtor)
    for i = #oldDebtorRecord.debt.entries, 1, -1 do
        if oldDebtorRecord.debt.entries[i] == debtID then table.remove(oldDebtorRecord.debt.entries, i) break end
    end
    oldDebtorRecord.debt.total = oldDebtorRecord.debt.total - entry.amount
    self:saveEntityRecord(entry.debtor, oldDebtorRecord)

    local newDebtorRecord = self:getEntityRecord(newDebtor)
    table.insert(newDebtorRecord.debt.entries, debtID)
    newDebtorRecord.debt.total = newDebtorRecord.debt.total + entry.amount
    self:saveEntityRecord(newDebtor, newDebtorRecord)

    if entry.debtor.type == "account" then
        audit.log("accounts", entry.debtor.name, {"DEBT_TRANSFER_OUT", debtID}, self:vfs())
    end
    if newDebtor.type == "account" then
        audit.log("accounts", newDebtor.name, {"DEBT_TRANSFER_IN", debtID, tostring(entry.amount)}, self:vfs())
    end

    entry.debtor = newDebtor
    self:vfs():writeFile("debts/" .. debtID .. ".json", textutils.serializeJSON(entry))
    log:debug("Debt " .. debtID .. " transferred to " .. (newDebtor.name or "government"))
    return 0
end

function debt:transferReceivable(newCreditor, debtID)
    local v = self:validateEntity(newCreditor)
    if v ~= 0 then return v end
    local entry = self:get(debtID)
    if type(entry) ~= "table" then return entry end

    local oldCreditorRecord = self:getEntityRecord(entry.creditor)
    for i = #oldCreditorRecord.claims.entries, 1, -1 do
        if oldCreditorRecord.claims.entries[i] == debtID then table.remove(oldCreditorRecord.claims.entries, i) break end
    end
    oldCreditorRecord.claims.total = oldCreditorRecord.claims.total - entry.amount
    self:saveEntityRecord(entry.creditor, oldCreditorRecord)

    local newCreditorRecord = self:getEntityRecord(newCreditor)
    table.insert(newCreditorRecord.claims.entries, debtID)
    newCreditorRecord.claims.total = newCreditorRecord.claims.total + entry.amount
    self:saveEntityRecord(newCreditor, newCreditorRecord)

    if entry.creditor.type == "account" then
        audit.log("accounts", entry.creditor.name, {"CLAIM_TRANSFER_OUT", debtID}, self:vfs())
    end
    if newCreditor.type == "account" then
        audit.log("accounts", newCreditor.name, {"CLAIM_TRANSFER_IN", debtID, tostring(entry.amount)}, self:vfs())
    end

    entry.creditor = newCreditor
    self:vfs():writeFile("debts/" .. debtID .. ".json", textutils.serializeJSON(entry))
    log:debug("Claim " .. debtID .. " transferred to " .. (newCreditor.name or "government"))
    return 0
end

function debt:resetPersistence(debtID)
    local entry = self:get(debtID)
    if type(entry) ~= "table" then return entry end
    entry.persistence = 0
    self:vfs():writeFile("debts/" .. debtID .. ".json", textutils.serializeJSON(entry))
    return 0
end

function debt:findOwnerWallet(accountName)
    local accounts = self:accounts()
    local wallets = self:wallets()
    local primary = accounts:getAccountValue(accountName, "primaryWallet")
    if primary then
        local members = wallets:getWalletValue(primary, "members") or {}
        if members[accountName] == "owner" then return primary end
    end
    local connected = accounts:getAccountValue(accountName, "wallets") or {}
    for _, wName in ipairs(connected) do
        local members = wallets:getWalletValue(wName, "members") or {}
        if members[accountName] == "owner" then return wName end
    end
    return nil
end

function debt:updateCreditScore(entity, paidRatio)
    local v = self:nation():getEthicValues()
    local formulas = self.rules.server.formulas
    local score

    if entity.type == "account" then
        score = self:accounts():getAccountValue(entity.name, "credit_score") or 100
    elseif entity.type == "government" then
        score = self:nation():getIdentity().credit_score or 100
    end

    if paidRatio == 1 then
        score = score + formulas.credit_reward(v.commerce, v.stability)
    else
        score = score - formulas.credit_penalty(1 - paidRatio, v.commerce, v.stability)
    end
    score = math.max(0, score)

    if entity.type == "account" then
        self:accounts():setAccountValue(entity.name, "credit_score", score)
    elseif entity.type == "government" then
        self:nation():getIdentity().credit_score = score
        self:nation():save()
    end
end

function debt:collect(debtID)
    local entry = self:get(debtID)
    if type(entry) ~= "table" then return entry end

    local wallets = self:wallets()
    local accounts = self:accounts()
    local nation = self:nation()

    local sourceWallet
    if entry.debtor.type == "account" then
        sourceWallet = self:findOwnerWallet(entry.debtor.name)
    elseif entry.debtor.type == "government" then
        sourceWallet = nation:getIdentity().treasury
    end

    if not sourceWallet then
        entry.persistence = entry.persistence + 1
        self:vfs():writeFile("debts/" .. debtID .. ".json", textutils.serializeJSON(entry))
        self:updateCreditScore(entry.debtor, 0)
        return 0
    end

    local balance = wallets:getWalletValue(sourceWallet, "balance") or 0
    local collected = math.min(balance, entry.amount)
    local paidRatio = collected / entry.amount
    entry.persistence = entry.persistence + (1 - paidRatio)

    local destWallet
    if entry.creditor.type == "government" then
        destWallet = nation:getIdentity().treasury
    elseif entry.creditor.type == "account" then
        destWallet = self:findOwnerWallet(entry.creditor.name)
    end

    if destWallet then
        wallets:transferBalance(sourceWallet, destWallet, collected)
    else
        local escrow = nation:getIdentity().escrow
        wallets:transferBalance(sourceWallet, escrow, collected)
        if entry.creditor.type == "account" then
            local pending = accounts:getAccountValue(entry.creditor.name, "pending_money") or 0
            accounts:setAccountValue(entry.creditor.name, "pending_money", pending + collected)
        end
    end

    if paidRatio == 1 then
        self:remove(debtID)
    else
        entry.amount = entry.amount - collected
        self:vfs():writeFile("debts/" .. debtID .. ".json", textutils.serializeJSON(entry))
        local debtorRecord = self:getEntityRecord(entry.debtor)
        debtorRecord.debt.total = debtorRecord.debt.total - collected
        self:saveEntityRecord(entry.debtor, debtorRecord)
        local creditorRecord = self:getEntityRecord(entry.creditor)
        creditorRecord.claims.total = creditorRecord.claims.total - collected
        self:saveEntityRecord(entry.creditor, creditorRecord)
    end

    if entry.debtor.type == "account" then
        audit.log("accounts", entry.debtor.name, {"DEBT_COLLECT", tostring(collected), tostring(entry.amount)}, self:vfs())
    end
    if entry.creditor.type == "account" then
        audit.log("accounts", entry.creditor.name, {"CLAIM_COLLECT", tostring(collected)}, self:vfs())
    end

    self:updateCreditScore(entry.debtor, paidRatio)
    log:debug("Collected " .. tostring(collected) .. "/" .. tostring(entry.amount + collected) .. " for debt " .. debtID)
    return 0
end

function debt:sweep()
    local files = self:vfs():listDir("debts/") or {}
    for _, file in ipairs(files) do
        if file ~= "government.json" then
            local debtID = file:sub(1, -6)
            local entry = self:get(debtID)
            if type(entry) == "table" then
                if entry.sweep then
                    self:collect(debtID)
                else
                    local balance = 0
                    local sourceWallet
                    if entry.debtor.type == "account" then
                        sourceWallet = self:findOwnerWallet(entry.debtor.name)
                    elseif entry.debtor.type == "government" then
                        sourceWallet = self:nation():getIdentity().treasury
                    end
                    if sourceWallet then
                        balance = self:wallets():getWalletValue(sourceWallet, "balance") or 0
                    end
                    local paidRatio = math.min(balance, entry.amount) / entry.amount
                    entry.persistence = entry.persistence + (1 - paidRatio)
                    self:vfs():writeFile("debts/" .. debtID .. ".json", textutils.serializeJSON(entry))
                    self:updateCreditScore(entry.debtor, paidRatio)
                end
            end
        end
    end
    log:debug("Debt sweep completed")
end

local service = {
    name = "debt",
    deps = {"wallets", "accounts", "nation", "vfs"},
    init = function(ctx)
        return debt.new(ctx)
    end,
    runtime = nil,
    tasks = function(self)
        local interval = self.ctx.configs["rules"].server.debt and self.ctx.configs["rules"].server.debt.sweepInterval or 7200
        return {
            debt_sweep = {function(self) self:sweep() end, interval}
        }
    end,
    shutdown = nil,
    api = {
        ["debt"] = {
            list = function(self) return self:list() end,
            add = function(self, args) return self:add(args.debtor, args.creditor, args.amount, args.reason, args.sweep) end,
            get = function(self, args) return self:get(args.id) end,
            exists = function(self, args) return self:exists(args.id) end,
            remove = function(self, args) return self:remove(args.id) end,
            set = function(self, args) return self:set(args.id, args.amount) end,
            transfer_debt = function(self, args) return self:transferDebt(args.debtor, args.id) end,
            transfer_receivable = function(self, args) return self:transferReceivable(args.creditor, args.id) end,
            reset_persistence = function(self, args) return self:resetPersistence(args.id) end,
            collect = function(self, args) return self:collect(args.id) end,
            sweep = function(self) return self:sweep() end,
        }
    }
}

return service
