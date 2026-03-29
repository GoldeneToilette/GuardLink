--[[
This file acts as a source of truth for various guardlink related things.
the "rules" table has rules for RP/world stuff, and "server" contains default settings for the computer itself.

"Values" are multipliers that define how the system behaves.
Force -> Nation can start offensive wars or take aggressive diplomatic actions
Stability -> How much capacity the nation has to pass laws + extra space for roles and surveillance
Commerce -> Changes how the economy behaves, more complex stock market behavior, currency worth more, etc
Autonomy -> Defines how much power the individual has. If its low, normal citizens do not own specific things
Consent -> Some actions need public approval & system has more transparency (public logs, etc)
]]--

local data = { rules = {}, server = {}}

-- SERVER --------------------------------------------------------------------------
data.server.session = {
    discoveryChannel = 65535, 
    keyPath = "/GuardLink/server/"
}
data.server.clients = {
    maxClients = 120,
    throttleLimit = 7200,
    max_idle = 60,
    heartbeat_interval = 30,
    channelRotation = 20,
    clientIDLength = 5
}
data.server.queue = {
    queueSize = 40,
    throttle = 0
}
data.server.health = {
    interval = 60,       -- seconds between checks
    warnThreshold = 0.8, -- 80% full -> warning
    critThreshold = 0.95 -- 95% full -> critical popup
}
data.server.inviteOnly = false -- if set to true, any client registering needs an invite code
data.server.theme = "default"
data.server.debug = false
data.server.registrationsPerHour = 30
data.server.walletsPerHour = 30
data.server.minDiskCount = 20
data.server.settingsPath = "/GuardLink/server/config/settings.conf"
data.server.manifestPath = "/GuardLink/server/config/manifest.json"
data.server.identityPath = "/GuardLink/server/config/identity.conf"
data.server.rulesPath = "/GuardLink/server/config/rules.lua"
data.server.partitions = {
        {name = "accounts", percentage = 10},
        {name = "logs", percentage = 60},
        {name = "cache", percentage = 20},
        {name = "wallets", percentage = 10}
}
-- SERVER --------------------------------------------------------------------------


-- RULES ---------------------------------------------------------------------------
data.rules.maxNationLength = 26
data.rules.maxRoleLength = 20
data.rules.maxCurrencyLength = 12
data.rules.ethics = {
    pacifist = {
        name = "Pacifist",
        description = "Stability and peace are the foundation of any nation",
        values = {
            force = 0.3,
            stability = 1.0,
            commerce = 0.8,
            autonomy = 1.5,
            consent = 1.8
        }
    },
    militarist = {
        name = "Militarist",
        description = "To stay relevant, you need to project your power on everyone",
        values = {
            force = 1.8,
            stability = 1.2,
            commerce = 1.0,
            autonomy = 0.6,
            consent = 0.5
        }
    },
    authoritarian = {
        name = "Authoritarian",
        description = "Order and law over individual freedom",
        values = {
            force = 1.4,
            stability = 1.8,
            commerce = 1.0,
            autonomy = 0.3,
            consent = 0.3
        }
    },
    egalitarian = {
        name = "Egalitarian",
        description = "Everyone has a voice, and we are here to listen",
        values = {
            force = 0.6,
            stability = 1.1,
            commerce = 1.0,
            autonomy = 1.8,
            consent = 1.8
        }
    },
    megacorporation = {
        name = "Megacorporation",
        description = "Money talks, and the market rules supreme",
        values = {
            force = 0.5,
            stability = 0.8,
            commerce = 2.0,
            autonomy = 0.8,
            consent = 0.2
        }
    }
}
data.server.formulas = {
    roleLimit = function(stability)
        return math.floor(5 * stability)
    end,
    lawLimit = function(stability, force)
        return math.floor(35 * (0.8 * stability + 0.2 * force))
    end,
    exchangeRate = function(nationA, nationB)
        local base = 1
        local ratio = (nationA.total / nationB.total) * (nationA.commerce / nationB.commerce)
        local damping = 0.5
        local rate = base * (1 + damping * (ratio - 1))

        return rate
    end,
    logsAccessible = function(autonomy, consent)
        local score = 0.7 * autonomy + 0.3 * consent
        return score >= 1.5
    end,
    marketVolatility = function(commerce, stability)
        local minVol, maxVol = 0.05, 0.35
        local base = minVol + commerce * (maxVol - minVol) / 2
        local adjusted = base * (1 - (stability or 0) * 0.1)
        return math.min(maxVol, math.max(minVol, adjusted))
    end
}
data.server.permissions = {
    -- accounts
    "accounts.view_others",
    "accounts.2fa_required",
    "accounts.create",
    "accounts.delete",
    "accounts.ban",
    "accounts.pardon",
    "accounts.assign_role",
    "accounts.set_value",
    "accounts.create_invite",
    "accounts.delete_invite",
    "accounts.change_password",
    -- wallets
    "wallets.view_others",
    "wallets.create",
    "wallets.delete",
    "wallets.change_balance",
    "wallets.transfer",
    "wallets.lock",
    "wallets.add_member",
    "wallets.remove_member",
    -- clients
    "clients.disconnect",
    "clients.disconnect_all",
    "clients.throttle",
    "clients.update_channels",
    "clients.heartbeats",
    -- disk
    "disk.scan",
    "disk.clear",
    -- queue
    "queue.throttle",
    -- nation
    "nation.set_tag",
    "nation.set_currency",
    "nation.set_starting_balance",
    -- kernel
    "kernel.stop",
    "kernel.pause_task",
    "kernel.resume_task",
    "kernel.refresh_configs",
    "kernel.set_config",
}
-- RULES ---------------------------------------------------------------------------
return data


