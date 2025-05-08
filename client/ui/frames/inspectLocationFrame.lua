local utils = require("utils.uihelper")

local function add(mainFrame, location, name)
    local inspectFrame = mainFrame:addFrame()
        :setSize("parent.w", "parent.h")
        :setBackground(colors.lightBlue)
        :setVisible(true)

        utils.createPane(compassFrame, 1, 1, 26, 1, colors.orange)
        utils.createPane(compassFrame, 1, 20, 26, 1, colors.orange)        
end


return {
    add = add
}