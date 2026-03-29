local nation = {}
nation.__index = nation

local log
local identityPath = "/GuardLink/server/config/identity.conf"

function nation.new(ctx)
    local self = setmetatable({}, nation)
    self.ctx = ctx
    self.identity = ctx.configs["identity"]
    self.rules = ctx.configs["rules"]

    log = ctx.services["logger"]:createInstance("nation", {timestamp = true, level = "INFO", clear = true})

    self:initTreasury()
    return self
end

function nation:save()
    local f = fs.open(identityPath, "w")
    f.write(textutils.serialize(self.identity))
    f.close()
end

function nation:initTreasury()
    local wallets = self.ctx.services["wallets"]
    local treasuryName = self.identity.treasury
    if not treasuryName or not wallets:exists(treasuryName) then
        treasuryName = self.identity.nation_tag .. "_treasury"
        if not wallets:exists(treasuryName) then
            local result = wallets:createWallet(treasuryName)
            if result ~= 0 then
                log:error("Failed to create treasury wallet: " .. tostring(result.log))
                return
            end
            log:info("Treasury wallet created: " .. treasuryName)
        else
            log:info("Treasury wallet already exists, linking: " .. treasuryName)
        end
        self.identity.treasury = treasuryName
        self:save()
    else
        log:debug("Treasury wallet found: " .. treasuryName)
    end
end

function nation:getIdentity()
    return self.identity
end

function nation:getEthicValues()
    local ethic = self.identity.selectedEthic
    return self.rules.rules.ethics[ethic].values
end

function nation:getValue(key)
    return self:getEthicValues()[key]
end

-- formula helpers so dispatchers don't need to touch identity/rules directly
function nation:logsAccessible()
    local v = self:getEthicValues()
    return self.rules.server.formulas.logsAccessible(v.autonomy, v.consent)
end

function nation:roleLimit()
    return self.rules.server.formulas.roleLimit(self:getValue("stability"))
end

function nation:lawLimit()
    local v = self:getEthicValues()
    return self.rules.server.formulas.lawLimit(v.stability, v.force)
end

function nation:marketVolatility()
    local v = self:getEthicValues()
    return self.rules.server.formulas.marketVolatility(v.commerce, v.stability)
end

function nation:exchangeRate(nationB)
    local v = self:getEthicValues()
    return self.rules.server.formulas.exchangeRate(
        {total = self:getCirculation(), commerce = v.commerce},
        nationB
    )
end

-- stats
function nation:getCitizenCount()
    return #self.ctx.services["accounts"]:listAccounts()
end

function nation:getCirculation()
    local wallets = self.ctx.services["wallets"]
    local treasury = self.identity.treasury
    local total = 0
    for _, name in ipairs(wallets:listWallets()) do
        if name ~= treasury then
            local data = wallets:getWalletData(name)
            if data then total = total + (data.balance or 0) end
        end
    end
    return total
end

function nation:getStats()
    local wallets = self.ctx.services["wallets"]
    local treasuryBalance = 0
    if self.identity.treasury then
        treasuryBalance = wallets:getWalletValue(self.identity.treasury, "balance") or 0
    end
    return {
        citizens    = self:getCitizenCount(),
        circulation = self:getCirculation(),
        treasury    = treasuryBalance
    }
end

-- setters
function nation:setTag(tag)
    if not tag or #tag < 2 or #tag > self.rules.rules.maxNationLength then return false end
    self.identity.nation_tag = tag
    self:save()
    return true
end

function nation:setCurrency(name)
    if not name or #name < 1 or #name > self.rules.rules.maxCurrencyLength then return false end
    self.identity.currency_name = name
    self:save()
    return true
end

function nation:setStartingBalance(amount)
    amount = tonumber(amount)
    if not amount or amount < 0 then return false end
    self.identity.starting_balance = tostring(amount)
    self:save()
    return true
end

local service = {
    name = "nation",
    deps = {"wallets", "accounts"},
    init = function(ctx)
        return nation.new(ctx)
    end,
    runtime = nil,
    tasks = nil,
    shutdown = nil,
    api = {
        ["nation"] = {
            get = function(self) return self:getIdentity() end,
            stats = function(self) return self:getStats() end,
            ethic = function(self) return self:getEthicValues() end,
            logs_accessible = function(self) return self:logsAccessible() end,
            role_limit = function(self) return self:roleLimit() end,
            law_limit = function(self) return self:lawLimit() end,
            set_tag = function(self, args) return self:setTag(args) end,
            set_currency = function(self, args) return self:setCurrency(args) end,
            set_starting_balance = function(self, args) return self:setStartingBalance(args) end,
        }
    }
}

return service
