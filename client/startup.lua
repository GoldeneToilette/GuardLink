os.loadAPI("/GuardLink/client/lib/cryptoNet")
local basalt = require("/GuardLink/client/lib/basalt")
local network = require("/GuardLink/client/network/eventHandler")
local loginFrame = require("/GuardLink/client/ui/frames/loginFrame")
local Logger = require("/GuardLink/client/logger")
local ErrorHandler = require("/GuardLink/client/errorHandler")

-- create latest log and wipe it
_G.logger = Logger.new("latest")
_G.logger:clearLog()

_G.logger:info("[startup] Launching GuardLinkBank...")
_G.logger:info("[startup] Connecting to server...")


ErrorHandler.tryCatch(
    function() network.connectServer("GuardLinkBank")
    end,
    function(err, stackTrace)
        _G.logger:fatal("[startup] Failed to connect to server.")
        _G.logger:error("[startup] Error:" .. err)
        os.shutdown()            
    end
)

local mainFrame = basalt.createFrame():setVisible(true)
--local testImage = mainFrame:addImage()

--testImage:loadImage("/GuardLink/client/logo.nfp")
--testImage:shrink()
loginFrame.add(mainFrame)

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



