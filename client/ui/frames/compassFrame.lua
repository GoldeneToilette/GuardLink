local utils = require("utils.uihelper")
local accountFrame = require("ui.frames.accountFrame")

local function add(mainFrame, element, name)
    local compassFrame = mainFrame:addFrame()
    :setSize("parent.w", "parent.h")
    :setBackground(colors.magenta)
    :setVisible(true)

    utils.createPane(compassFrame, 1, 1, 26, 1, colors.orange)
    utils.createPane(compassFrame, 1, 20, 26, 1, colors.orange)

    utils.createLabel(compassFrame, name, 1, 1, 24, 1, colors.orange, colors.yellow)

    local frame = compassFrame:addFrame()
    :setPosition(1, 2)
    :setSize(26, 18)

    local program = frame:addProgram()
    :setSize("parent.w", "parent.h")
    :setPosition(1, 1)
    


    local closeButton = utils.createButton(compassFrame, "X", 26, 1, 1, 1, colors.orange, colors.red)

    closeButton:onClick(function(self, event, button, x, y)
        if event == "mouse_click" and button == 1 then
            program:stop()
            accountFrame.add(mainFrame)
            frame:remove()   
            compassFrame:remove()
        end
    end)

    program:execute("/GuardLink/client/programs/compassProgram.lua")



    local x, y = element.coordinates:match("(%d+),(%d+)")
    x, y = tonumber(x), tonumber(y)

    utils.createLabel(compassFrame, "At: X[" .. x .. "], Y[".. y .. "]", 1, 20, 26, 1, colors.orange, colors.yellow)

    program:injectEvent("cords", true, x, y)

end

return {
    add = add
}