local utils = require("/GuardLink/client/ui/utils")

local function add(mainFrame)
    local compassFrame = mainFrame:addFrame()
    :setSize("parent.w", "parent.h")
    :setBackground(colors.magenta)
    :setVisible(true)

    utils.createPane(compassFrame, 1, 1, 26, 1, colors.orange)
    utils.createPane(compassFrame, 1, 20, 26, 1, colors.orange)

end

return {
    add = add
}