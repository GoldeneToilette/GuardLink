local Logger = require("/GuardLink/server/utils/logger")
local network = require("/GuardLink/server/network/eventListener")

_G.logger = Logger.new("latest")
_G.logger:clearLog()

local function placeholder()
_G.logger:info("[startup] Placeholder function, no shell implemented :()")
end

parallel.waitForAll(network.startServer, placeholder)