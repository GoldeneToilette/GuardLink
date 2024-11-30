local utils = require("/GuardLink/client/ui/utils")
local xmlParser = require("/GuardLink/client/ui/xmlParser")

local function add(mainFrame)
    local gpsFrame = mainFrame:addFrame()
    :setSize("parent.w", "parent.h")
    :setBackground(colors.orange)
    :setVisible(true)

    local uiElements = xmlParser.loadXML(gpsFrame, "/GuardLink/client/ui/xml/gpsFrame.xml")

    local dropdown = utils.addProgramMenu(mainFrame, gpsFrame)   
    dropdown:selectItem(2)
end

return {
    add = add
}