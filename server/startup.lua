local diskManager = require("modules.disk").new()

diskManager:scan()

_G.vfs = require("modules.virtualFilesystem").new(diskManager)

local Logger = require "lib.logger"
_G.utils = require "lib.utils"

_G.logger = Logger.new("latest", "logs")
_G.logger:clearLog()

_G.shutdown = require("modules.shutdown")

local fileUtils = require("lib.fileUtils")
local settings = textutils.unserialize(fileUtils.read("/GuardLink/config/settings.conf"))
if not settings then
    _G.logger:fatal("[startup] Settings file not found!")
    error("Couldn't find settings file!")
    os.shutdown()
end

_G.theme = require("lib.themes")
_G.theme.init()
_G.theme.setTheme(settings.theme)

local session = require("network.networkSession").new(settings)
local uiState = require("modules.uiState").new()
local taskManager = require("modules.taskManager")
taskManager.add(function() session.clientManager:updateChannels() end, session.clientManager.channelRotation)
taskManager.add(function() session.clientManager:heartbeats() end, session.clientManager.heartbeat_interval)

_G.utils.tryCatch(function()
    parallel.waitForAll(
        function() session:listen() end,
        function() session.requestQueue:processQueue() end,
        taskManager.run,
        function() uiState:run() end
    )
end, function(err, stackTrace)
    _G.logger:fatal("[startup] Server crashed :(")
    _G.logger:error("[startup] Error:" .. tostring(err))
    os.shutdown()
end)
