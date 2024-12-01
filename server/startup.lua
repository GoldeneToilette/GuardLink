local Logger = require("/GuardLink/server/utils/logger")
local network = require("/GuardLink/server/network/eventListener")
local shell = require("/GuardLink/server/shell/shell")
local basalt = require("/GuardLink/server/lib/basalt")

_G.logger = Logger.new("latest")
_G.logger:clearLog()

shell.createShell()

parallel.waitForAll(network.startServer, basalt.autoUpdate)