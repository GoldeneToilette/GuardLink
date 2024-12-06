local Logger = require("/GuardLink/server/utils/logger")
local network = require("/GuardLink/server/network/eventListener")
local shell = require("/GuardLink/server/shell/shell")
local basalt = require("/GuardLink/server/lib/basalt")
local gpsManager = require("/GuardLink/server/gps/gpsManager")

_G.logger = Logger.new("latest")
_G.logger:clearLog()

gpsManager.initializeCategoryFiles()

shell.createShell()

parallel.waitForAll(network.startServer, basalt.autoUpdate)