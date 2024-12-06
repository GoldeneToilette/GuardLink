local utils = require("/GuardLink/client/ui/utils")
local xmlParser = require("/GuardLink/client/ui/xmlParser")
local network = require("/GuardLink/client/network/eventHandler")
local requestSender = require("/GuardLink/client/network/requestSender")

local function add(mainFrame)
    local gpsFrame = mainFrame:addFrame()
    :setSize("parent.w", "parent.h")
    :setBackground(colors.orange)
    :setVisible(true)

    local uiElements = xmlParser.loadXML(gpsFrame, "/GuardLink/client/ui/xml/gpsFrame.xml")
    local debugButton = uiElements["debugButton"] 

    local dropdown = utils.addProgramMenu(mainFrame, gpsFrame)   
    dropdown:selectItem(2)

    debugButton:onClick(function(_, event, button)
        if event == "mouse_click" and button == 1 then
            local name = network.getServerData("username")     
            local param = {
                name = "building shop",
                coordinates = "3,5",
                description = "selling building blocks! :D",
                category = "commercial"
            }
            requestSender.sendGPSRequest(name, "add", param, network.getSocket(), function(serverData)
                utils.createPopup(gpsFrame, "Status", "info", serverData.latestGPS)
            end)
        end
    end)
end

return {
    add = add
}