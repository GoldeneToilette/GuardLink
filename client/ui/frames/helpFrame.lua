local utils = require("utils.uihelper")
local xmlParser = require("utils.xmlParser")
local basalt = require("lib.basalt")


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
        dropdown:selectItem(4)

        local uiElements = xmlParser.loadXML(subFrame, "/GuardLink/client/ui/xml/helpFrame.xml")

        
        


end


return {
    add = add
}