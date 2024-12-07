local utils = require("/GuardLink/client/ui/utils")
local xmlParser = require("/GuardLink/client/ui/xmlParser")
local network = require("/GuardLink/client/network/eventHandler")
local requestSender = require("/GuardLink/client/network/requestSender")

-- updates the list with given category
local function updateList(list, category)
    local name = network.getServerData("username")  
    local param = { category = category}
    requestSender.sendGPSRequest(name, "list", param,  network.getSocket(), function(serverData)
        local locations = textutils.unserializeJSON(serverData.latestGPS)
        if locations then
            list:clear()

            for i, location in ipairs(locations) do
                local bgColor = (i % 2 == 0)and colors.lightBlue or colors.lime
                list:addItem(location, bgColor, colors.orange)
            end
        end
    end)
end

local function add(mainFrame)
    local gpsFrame = mainFrame:addFrame()
    :setSize("parent.w", "parent.h")
    :setBackground(colors.magenta)
    :setVisible(true)

    local uiElements = xmlParser.loadXML(gpsFrame, "/GuardLink/client/ui/xml/gpsFrame.xml")

    local dropdown = utils.addProgramMenu(mainFrame, gpsFrame)   
    dropdown:selectItem(2)

    local categoryDropdown = gpsFrame:addDropdown()
    :setForeground(colors.lightBlue)
    :setBackground(colors.orange)
    :setPosition(2, 3)
    :setSize(15, 1)
    :setSelectionColor(colors.magenta, colors.yellow)
    :addItem("Commercial", colors.orange, colors.lightBlue, "commercial")
    :addItem("Residential", colors.orange, colors.lightBlue, "residential")
    :addItem("Government", colors.orange, colors.lightBlue, "government")
    :addItem("Industrial", colors.orange, colors.lightBlue, "industrial")
    :addItem("Recreational", colors.orange, colors.lightBlue, "recreational")
    :addItem("Infrastructure", colors.orange, colors.lightBlue, "infrastructure")
    :addItem("Religious", colors.orange, colors.lightBlue, "religious")
    :selectItem(1)

    local list = gpsFrame:addList()
    :setBackground(colors.lightBlue)
    :setForeground(colors.orange)
    :setPosition(2, 7)
    :setSize(24, 12)
    :setSelectionColor(nil, colors.yellow)
    :setScrollable(true)

    updateList(list, "commercial")

    categoryDropdown:onChange(function(self, event, item)
        updateList(list, item.args[1])
    end)

end

return {
    add = add
}