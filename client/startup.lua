os.loadAPI("/GuardLink/client/lib/cryptoNet")
local basalt = require("lib.basalt")
local network = require("network.eventHandler")
local loginFrame = require("ui.frames.loginFrame")
local Logger = require("utils.logger")
local ErrorHandler = require("utils.errorHandler")
local themes = require("utils.themes")
local settingsManager = require("utils.settingsManager")

-- Entry point of the client program. It loads all the important stuff like UI, themes, server connection etc

-- initializes settings file
settingsManager.initializeSettings()

-- create latest log and wipe it
_G.logger = Logger.new("latest")
_G.logger:clearLog()

_G.logger:info("[startup] Connecting to server...")

-- Connects to the server and catches potential errors (like when the server is unreachable)
ErrorHandler.tryCatch(
    function() network.connectServer("GuardLinkBank")
    end,
    function(err, stackTrace)
        _G.logger:fatal("[startup] Failed to connect to server.")
        _G.logger:error("[startup] Error:" .. err)
        os.shutdown()            
    end
)

-- creates the mainframe where all the UI happens and creates the loginFrame
local mainFrame = basalt.createFrame():setVisible(true)
loginFrame.add(mainFrame)

-- initializes the theme palette
themes.initializePaletteWithTheme(settingsManager.getSetting("theme"))

-- starts the UI and catches potential errors (when basalt is buggy as usual)
local function runSecureAutoUpdate()
    ErrorHandler.tryCatch(
        basalt.autoUpdate,
        function(err, stackTrace)
            _G.logger:fatal("[startup] Failed to load UI.")
            _G.logger:error("[startup] Error:" .. err)
            os.shutdown()            
        end
    )
end

-- runs both listeners and UI updates concurrently
parallel.waitForAll(network.startEventListener, runSecureAutoUpdate)



