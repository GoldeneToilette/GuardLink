os.loadAPI("/GuardLink/client/lib/cryptoNet")
local basalt = require("/GuardLink/client/lib/basalt")
local network = require("/GuardLink/client/network/eventHandler")
local loginFrame = require("/GuardLink/client/ui/frames/loginFrame")
local Logger = require("/GuardLink/client/logger")
local ErrorHandler = require("/GuardLink/client/errorHandler")
local themes = require("/GuardLink/client/ui/themes")
local settingsManager = require("/GuardLink/client/settingsManager")

-- initializes settings file
settingsManager.initializeSettings()

-- create latest log and wipe it
_G.logger = Logger.new("latest")
_G.logger:clearLog()

_G.logger:info("[startup] Launching GuardLinkBank...")
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



