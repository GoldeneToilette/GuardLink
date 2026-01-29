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
data.version = "0.1.1"

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
data.server.theme = "default"
data.server.debug = false
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
    end
}
-- RULES ---------------------------------------------------------------------------
return data


