--[[
This file acts as a source of truth for various guardlink related things.
the "rules" table has rules for RP/world stuff, and "server" contains default settings for the computer itself.

"Values" are multipliers that define how the system behaves. Its basically just a way to configure your nation but "gamified".
Force -> Nation can start offensive wars or take aggressive diplomatic actions
Stability -> How much capacity the nation has to pass laws + extra space for roles and surveillance
Commerce -> Changes how the economy behaves, more complex stock market behavior, higher focus on economy, etc
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
    throttle = 1
}
data.server.theme = "default"
data.server.debug = false
-- SERVER --------------------------------------------------------------------------


-- RULES ---------------------------------------------------------------------------
data.rules.maxNameLength = 26
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
            force = 0.7,
            stability = 0.5,
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

-- RULES ---------------------------------------------------------------------------
return data


