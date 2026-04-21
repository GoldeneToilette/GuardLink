local utils = requireC("/GuardLink/server/lib/utils.lua")
local errors = requireC("/GuardLink/server/lib/errors.lua")
local audit = requireC("/GuardLink/server/lib/audit.lua")

local law = {}
law.__index = law

local log

local confPath = "/GuardLink/server/config/laws.conf"
local defaultCfg = { categories = {}, passive = {}, periodic = {}, active = {} }

function law.new(ctx)
    local self = setmetatable({}, law)
    self.ctx = ctx
    self.rules = ctx.configs["rules"]
    self.events = requireC("/GuardLink/server/lib/eventSystem.lua")

    if not ctx.configs["laws"] then
        ctx.configs["laws"] = utils.deepCopy(defaultCfg)
        local f = fs.open(confPath, "w")
        f.write(textutils.serialize(ctx.configs["laws"]))
        f.close()
    end

    self.lastRun = {}
    log = ctx.services["logger"]:createInstance("law", {timestamp = true, level = "INFO", clear = true})
    return self
end

function law:nation()
    return self.ctx.services["nation"]
end

function law:getCfg()
    return self.ctx.configs["laws"]
end

function law:saveCfg()
    local f = fs.open(confPath, "w")
    f.write(textutils.serialize(self.ctx.configs["laws"]))
    f.close()
end

function law:existsCategory(displayName)
    for k,v in pairs(self:getCfg().categories) do
        if v.displayName == displayName or k == displayName then return true end
    end
    return false
end

--[[
    format:
    id = {
        displayName = "",
        laws = {}
    }
]]--
function law:newCategory(displayName)
    local cfg = self:getCfg()
    if not self:existsCategory(displayName) then
        cfg.categories[utils.randomString(8, "base32")] = {
            displayName = displayName,
            laws = {}
        }
        self:saveCfg()
        return 0
    end
    return errors.CATEGORY_EXISTS
end

function law:deleteCategory(id)
    local cfg = self:getCfg()
    if not cfg.categories[id] then return errors.UNKNOWN_CATEGORY end
    if #cfg.categories[id].laws ~= 0 then return errors.UNRESOLVED_DEPENDENCIES end
    cfg.categories[id] = nil
    self:saveCfg()
    return 0
end

function law:getLawCount()
    local cfg = self:getCfg()
    return #cfg.passive + #cfg.periodic + #cfg.active
end

function law:lawExists(name)
    local cfg = self:getCfg()
    for _, tbl in ipairs({cfg.passive, cfg.periodic, cfg.active}) do
        for _, l in ipairs(tbl) do
            if l.name == name then return true end
        end
    end
    return false
end

function law:validateCore(args)
    if not args.name or args.name == "" then return errors.INVALID_FORMAT end
    if not args.description or args.description == "" then return errors.INVALID_FORMAT end
    if not args.consequence or args.consequence == "" then return errors.INVALID_FORMAT end
    if args.type ~= "passive" and args.type ~= "periodic" and args.type ~= "active" then return errors.INVALID_LAW_TYPE end
    if not self:getCfg().categories[args.category] then return errors.UNKNOWN_CATEGORY end
    if not args.target or not args.target.type then return errors.INVALID_TARGET end
    local validTargets = {individual=true, company=true, government=true}
    if not validTargets[args.target.type] then return errors.INVALID_TARGET end
    if self:lawExists(args.name) then return errors.LAW_EXISTS end
    local v = self:nation():getEthicValues()
    if self:getLawCount() >= self.rules.server.formulas.lawLimit(v.stability, v.force) then
        return errors.LAW_LIMIT_REACHED
    end
    return 0
end

function law:newPassiveLaw(base)
    local cfg = self:getCfg()
    table.insert(cfg.passive, base)
    table.insert(cfg.categories[base.category].laws, base.id)
    self:saveCfg()
    return base.id
end

function law:newPeriodicLaw(base, args)
    if not args.interval or args.interval <= 0 then return errors.INVALID_FORMAT end
    if not args.grace or args.grace < 0 then return errors.INVALID_FORMAT end
    if args.rate then
        if args.rate <= 0 or args.rate > 1 then return errors.INVALID_EFFECT end
        base.rate = args.rate
    elseif args.amount then
        if args.amount <= 0 then return errors.INVALID_EFFECT end
        base.amount = args.amount
    else
        return errors.INVALID_EFFECT
    end
    base.interval = args.interval
    base.grace    = args.grace
    local cfg = self:getCfg()
    table.insert(cfg.periodic, base)
    table.insert(cfg.categories[base.category].laws, base.id)
    self:saveCfg()
    return base.id
end

function law:newLaw(args)
    local v = self:validateCore(args)
    if v ~= 0 then return v end

    local base = {
        id = utils.randomString(8, "base32"),
        category = args.category,
        name = args.name,
        description = args.description,
        consequence = args.consequence,
        type = args.type,
        active = true,
        target = args.target
    }

    if args.type == "passive" then
        return self:newPassiveLaw(base)
    elseif args.type == "periodic" then
        return self:newPeriodicLaw(base, args)
    elseif args.type == "active" then
        return errors.INVALID_LAW_TYPE -- not implemented yet
    end
end

function law:getEntityBalance(entity)
    local wallets = self.ctx.services["wallets"]
    if entity.type == "government" then
        return wallets:getWalletValue(self:nation():getIdentity().treasury, "balance") or 0
    elseif entity.type == "account" then
        local accounts = self.ctx.services["accounts"]
        local identity = self:nation():getIdentity()
        local systemWallets = {[identity.treasury] = true, [identity.escrow] = true}
        local total = 0
        local connected = accounts:getAccountValue(entity.name, "wallets") or {}
        for _, wName in ipairs(connected) do
            if not systemWallets[wName] then
                local members = wallets:getWalletValue(wName, "members") or {}
                if members[entity.name] == "owner" then
                    total = total + (wallets:getWalletValue(wName, "balance") or 0)
                end
            end
        end
        return total
    end
    return 0
end

function law:getTargetEntities(target)
    local entities = {}
    if target.type == "individual" then
        local accounts = self.ctx.services["accounts"]:listAccounts()
        for _, name in ipairs(accounts) do
            if not target.filter or not target.filter.role or
               self.ctx.services["accounts"]:getAccountValue(name, "role") == target.filter.role then
                table.insert(entities, {type = "account", name = name})
            end
        end
    elseif target.type == "government" then
        table.insert(entities, {type = "government"})
    end
    return entities
end

function law:runPeriodicLaw(l)
    local debt = self.ctx.services["debt"]
    local entities = self:getTargetEntities(l.target)
    local creditor = {type = "government"}

    for _, entity in ipairs(entities) do
        local amount
        if l.rate then
            amount = math.floor(self:getEntityBalance(entity) * l.rate)
        else
            amount = l.amount
        end

        if amount and amount > 0 then
            local debtor = entity.type == "account"
                and {type = "account", name = entity.name}
                or  {type = "government"}
            debt:add(debtor, creditor, amount, l.name, true, l.grace)
        end
    end
    log:debug("Periodic law fired: " .. l.name)
end

function law:getLawsByCategory(categoryId)
    local cfg = self:getCfg()
    if not cfg.categories[categoryId] then return errors.UNKNOWN_CATEGORY end
    local results = {}
    for _, id in ipairs(cfg.categories[categoryId].laws) do
        local l = self:getLaw(id)
        if type(l) == "table" then table.insert(results, l) end
    end
    return results
end

function law:getLaw(id)
    local cfg = self:getCfg()
    for _, tbl in ipairs({cfg.passive, cfg.periodic, cfg.active}) do
        for _, l in ipairs(tbl) do
            if l.id == id then return l end
        end
    end
    return errors.LAW_NOT_FOUND
end

function law:listLaws(lawType)
    local cfg = self:getCfg()
    if lawType then return cfg[lawType] or {} end
    local all = {}
    for _, tbl in ipairs({cfg.passive, cfg.periodic, cfg.active}) do
        for _, l in ipairs(tbl) do table.insert(all, l) end
    end
    return all
end

function law:deleteLaw(id)
    local cfg = self:getCfg()
    for _, tblName in ipairs({"passive", "periodic", "active"}) do
        local tbl = cfg[tblName]
        for i, l in ipairs(tbl) do
            if l.id == id then
                table.remove(tbl, i)
                local catLaws = cfg.categories[l.category] and cfg.categories[l.category].laws
                if catLaws then
                    for j = #catLaws, 1, -1 do
                        if catLaws[j] == id then table.remove(catLaws, j) break end
                    end
                end
                self:saveCfg()
                return 0
            end
        end
    end
    return errors.LAW_NOT_FOUND
end

function law:getViolations(entity)
    if entity.type == "account" then
        local record = self.ctx.services["accounts"]:getAccountValue(entity.name, "record") or {}
        return record.violations or {}
    elseif entity.type == "government" then
        return self:nation():getIdentity().violations or {}
    end
    return {}
end

function law:saveViolations(entity, violations)
    if entity.type == "account" then
        local accounts = self.ctx.services["accounts"]
        local record = accounts:getAccountValue(entity.name, "record") or {}
        record.violations = violations
        accounts:setAccountValue(entity.name, "record", record)
    elseif entity.type == "government" then
        self:nation():getIdentity().violations = violations
        self:nation():save()
    end
end

function law:addViolation(entity, lawId, createdBy, notes)
    local l = self:getLaw(lawId)
    if not l or l.client then return errors.LAW_NOT_FOUND end
    if l.type ~= "passive" then return errors.INVALID_LAW_TYPE end
    if not entity or not entity.type then return errors.INVALID_TARGET end
    if entity.type == "account" and not self.ctx.services["accounts"]:exists(entity.name) then
        return errors.ACCOUNT_NOT_FOUND
    end
    local violations = self:getViolations(entity)
    table.insert(violations, {
        id         = utils.randomString(8, "base32"),
        law_id     = lawId,
        timestamp  = os.epoch("utc"),
        created_by = createdBy,
        notes      = notes or ""
    })
    self:saveViolations(entity, violations)
    if entity.type == "account" then
        audit.log("accounts", entity.name, {"VIOLATION_ADD", lawId, createdBy}, self.ctx.services["vfs"])
    end
    log:info("Violation added for " .. (entity.name or "government") .. " under law " .. lawId)
    return 0
end

function law:removeViolation(entity, violationId)
    if not entity or not entity.type then return errors.INVALID_TARGET end
    local violations = self:getViolations(entity)
    for i = #violations, 1, -1 do
        if violations[i].id == violationId then
            table.remove(violations, i)
            self:saveViolations(entity, violations)
            if entity.type == "account" then
                audit.log("accounts", entity.name, {"VIOLATION_REMOVE", violationId}, self.ctx.services["vfs"])
            end
            return 0
        end
    end
    return errors.LAW_NOT_FOUND
end

function law:listViolations(entity)
    if not entity or not entity.type then return errors.INVALID_TARGET end
    return self:getViolations(entity)
end

function law:setActive(id, state)
    local cfg = self:getCfg()
    for _, tbl in ipairs({cfg.passive, cfg.periodic, cfg.active}) do
        for _, l in ipairs(tbl) do
            if l.id == id then
                l.active = state
                self:saveCfg()
                log:debug("Law " .. id .. " set active: " .. tostring(state))
                return 0
            end
        end
    end
    return errors.LAW_NOT_FOUND
end

local service = {
    name = "law",
    deps = {"nation", "debt", "wallets", "accounts"},
    init = function(ctx)
        return law.new(ctx)
    end,
    runtime = nil,
    tasks = function(self)
        return {
            law_scheduler = {function(self)
                local now = os.epoch("utc")
                for _, l in ipairs(self:getCfg().periodic) do
                    if l.active then
                        local lastRun = self.lastRun[l.id] or 0
                        if (now - lastRun) >= (l.interval * 1000) then
                            self:runPeriodicLaw(l)
                            self.lastRun[l.id] = now
                        end
                    end
                end
            end, 60}
        }
    end,
    shutdown = nil,
    api = {
        ["law"] = {
            new_law = function(self, args) return self:newLaw(args) end,
            get_law = function(self, args) return self:getLaw(args.id) end,
            list_laws = function(self, args) return self:listLaws(args and args.type) end,
            delete_law = function(self, args) return self:deleteLaw(args.id) end,
            set_active = function(self, args) return self:setActive(args.id, args.state) end,
            new_category = function(self, args) return self:newCategory(args.name) end,
            delete_category = function(self, args) return self:deleteCategory(args.id) end,
            list_categories = function(self) return self:getCfg().categories end,
            get_by_category = function(self, args) return self:getLawsByCategory(args.id) end,
            add_violation = function(self, args) return self:addViolation(args.entity, args.law_id, args.created_by, args.notes) end,
            remove_violation = function(self, args) return self:removeViolation(args.entity, args.violation_id) end,
            list_violations = function(self, args) return self:listViolations(args.entity) end,
        }
    }
}

return service
