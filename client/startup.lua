os.loadAPI("/GuardLink/client/lib/cryptoNet")
local basalt = require("/GuardLink/client/lib/basalt")
local network = require("/GuardLink/client/network")

local loginFrame = require("/GuardLink/client/ui/loginFrame")

-- Connects to the server
network.connectServer("GuardLinkBank")

local mainFrame = basalt.createFrame()
:setVisible(true)

loginFrame.add(mainFrame)

-- Runs both the listener and the UI at the same time until both are done
parallel.waitForAll(network.startListener, basalt.autoUpdate)




