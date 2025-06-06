local utils = require("utils.uihelper")
local xmlParser = require("utils.xmlParser")
local themes = require("utils.themes")
local settingsManager = require("utils.settingsManager")

local function add(mainFrame)
    local settingsFrame = mainFrame:addFrame()
        :setSize("parent.w", "parent.h")
        :setBackground(colors.lightBlue)
        :setVisible(true)

        local dropdown = utils.addProgramMenu(mainFrame, settingsFrame)   
        dropdown:selectItem(3)

        local uiElements = xmlParser.loadXML(settingsFrame, "/GuardLink/client/ui/xml/settingsFrame.xml")

        local themeDropdown = settingsFrame:addDropdown()
        :setForeground(colors.lightBlue)
        :setBackground(colors.orange)
        :setPosition(11, 4)
        :setSelectionColor(colors.white, colors.yellow)
        :addItem("Default", colors.orange, colors.lightBlue, "default")
        :addItem("Cyberpunk", colors.orange, colors.lightBlue, "cyberpunk")
        :addItem("Darkmode", colors.orange, colors.lightBlue, "darkmode")
        :addItem("Sunset", colors.orange, colors.lightBlue, "sunset")
        :addItem("Monochrome", colors.orange, colors.lightBlue, "monochrome")
        :addItem("Royal", colors.orange, colors.lightBlue, "royal")
        :addItem("Autumn", colors.orange, colors.lightBlue, "autumn")
        :addItem("Emerald", colors.orange, colors.lightBlue, "emerald")
        :onChange(function(self, event, item)
            local selectedTheme = tostring(item.args[1])
            settingsManager.setSetting("theme", selectedTheme)
            themes.initializePaletteWithTheme(selectedTheme)
        end)

        local checkbox = settingsFrame:addCheckbox()
        :setPosition(15,6)
        :setForeground(colors.lightBlue)
        :setBackground(colors.orange)

        checkbox:setValue(settingsManager.getSetting("debug"))

        checkbox:onChange(function(self)
            local checked = self:getValue()
            if checked == true then
                settingsManager.setSetting("debug", true)
            else
                settingsManager.setSetting("debug", false)
            end
            _G.logger:info("[settingsFrame] changed debug mode to: " .. tostring(checked))
        end)
end


return {
    add = add
}