local diskManager = require("modules.disk").new()

diskManager:scan()
diskManager:partition({
    whitelist = {"GLB_1", "GLB_2", "GLB_3", "GLB_4"},
    layout = {
        {name = "accounts", percentage = 10},
        {name = "logs", percentage = 60},
        {name = "cache", percentage = 20},
        {name = "wallets", percentage = 10}
    }
})

_G.vfs = require("modules.virtualFilesystem").new(diskManager)

local Logger = require "lib.logger"
_G.utils = require "lib.utils"

_G.logger = Logger.new("latest", "logs")
_G.logger:clearLog()

_G.shutdown = require("modules.shutdown")

local settings = {
    session = {
        discoveryChannel = 65535,
        keyPath = "/GuardLink/server/"
    },
    clients = {
        maxClients = 120,
        throttleLimit = 7200,
        max_idle = 60,
        heartbeat_interval = 30,
        channelRotation = 20,
        clientIDLength = 5
    },
    queue = {
        queueSize = 40,
        throttle = 1
    },
    theme = "default"
}

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
