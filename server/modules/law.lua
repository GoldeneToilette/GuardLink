local law = {}
law.__index = law

local log

function law.new(ctx)
    local self = setmetatable({}, law)
    self.ctx = ctx
    self.rules = ctx.configs["rules"]
    self.events = requireC("/GuardLink/server/lib/eventSystem.lua")

    log = ctx.services["logger"]:createInstance("law", {timestamp = true, level = "INFO", clear = true})

    return self
end

function law:vfs()
    return self.ctx.services["vfs"]
end

function law:accounts()
    return self.ctx.services["accounts"]
end

function law:wallets()
    return self.ctx.services["wallets"]
end

function law:nation()
    return self.ctx.services["nation"]
end

function law:existsLaw(lawID)

end

local service = {
    name = "law",
    deps = {"nation", "wallets", "accounts", "vfs"},
    init = function(ctx)
        return law.new(ctx)
    end,
    runtime = nil,
    tasks = nil,
    shutdown = nil,
    api = {
        ["law"] = {

        }
    }
}

return service
