local utils = require("/GuardLink/client/ui/utils")
local xmlParser = require("/GuardLink/client/ui/xmlParser")
local network = require("/GuardLink/client/network/eventHandler")
local requestSender = require("/GuardLink/client/network/requestSender")

local allLocations = {}

local doubleClickMaxTime = 0.25

function string.lowercase(str)
    return str:gsub("%u", string.lower)
end

function isPrefix(first, second)
    if not first or not second then return false end
    
    for i = 1, #first do
        if first:sub(i, i) ~= second:sub(i, i) then
            return false
        end
    end
    
    return true
end

-- updates the list with given category
local function updateList(list, category)
    local name = network.getServerData("username")  
    local param = { category = category}
    requestSender.sendGPSRequest(name, "list", param,  network.getSocket(), function(serverData)
        local locations = textutils.unserializeJSON(serverData.latestGPS)
        if locations then
            allLocations = locations
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
    local searchField = uiElements["searchTextfield"]

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

    -- dynamically adjust the list to show the result
    searchField:onKeyUp(function(self, event, key)
        local searchTerm = string.lowercase(searchField:getLine(1))   
        list:clear()
    
        if searchTerm == "" then
            for i, location in ipairs(allLocations) do
                local bgColor = (i % 2 == 0) and colors.lightBlue or colors.lime
                list:addItem(location, bgColor, colors.orange)
            end
        else
            for i, location in ipairs(allLocations) do
                if isPrefix(searchTerm, string.lowercase(location)) then
                    local bgColor = (i % 2 == 0) and colors.lightBlue or colors.lime
                    list:addItem(location, bgColor, colors.orange)
                end
            end
        end
    end)


    local function listDoubleClick(list, func)
        local doubleClick = 0       
        list:onClick(function()
            if(os.epoch("local")-doubleClickMaxTime*1000<=doubleClick)then
                func()
            end
            doubleClick = os.epoch("local")    
        end)        
    end


    listDoubleClick(list, function()
        utils.createPopup(gpsFrame, "Confirm", "action", "Track location?", function()
            -- callback here
            print("balls")
        end)   
    end)

end

return {
    add = add
}