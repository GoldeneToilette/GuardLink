local utils = require("/GuardLink/client/ui/utils")
local xmlParser = require("/GuardLink/client/ui/xmlParser")
local basalt = require("/GuardLink/client/lib/basalt")


local function add(mainFrame)
    local helpFrame = mainFrame:addFrame()
        :setSize("parent.w", "parent.h")
        :setBackground(colors.black)
        :setVisible(true)
        local subFrame = helpFrame:addScrollableFrame()
        :setSize("parent.w", 20 )
        :setPosition(1,1)
        :setBackground(colors.lightBlue)
        local dropdown = utils.addProgramMenu(mainFrame, subFrame)   
        dropdown:selectItem(3)

        local uiElements = xmlParser.loadXML(subFrame, "/GuardLink/client/ui/xml/helpFrame.xml")

        
        


end


return {
    add = add
}