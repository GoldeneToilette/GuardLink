-- formats the balance correctly, so it doesnt go out of bounds
local function formatNumber(balance)
    if balance >= 1e9 then
        return string.format("%.1fB GC", balance / 1e9)
    elseif balance >= 1e6 then
        return string.format("%.1fM GC", balance / 1e6)
    else
        return string.format("%d GC", balance)
    end
end

-- creates a basalt label
function createLabel(parent, text, posX, posY, sizeX, sizeY, bgColor, fgColor, fontSize)
    return parent:addLabel()
        :setText(text)
        :setPosition(posX, posY)
        :setSize(sizeX, sizeY)
        :setBackground(bgColor)
        :setForeground(fgColor)
        :setFontSize(fontSize or 1)
end

-- creates a basalt pane
function createPane(parent, posX, posY, sizeX, sizeY, bgColor)
    return parent:addPane()
    :setPosition(posX, posY)
    :setSize(sizeX, sizeY)
    :setBackground(bgColor)
end

-- creates a basalt textfield
function createTextfield(parent, posX, posY, sizeX, sizeY, bgColor, fgColor)
    return parent:addTextfield()
    :addLine("")
    :setPosition(posX, posY)
    :setSize(sizeX, sizeY)
    :setBackground(bgColor)
    :setForeground(fgColor)
end

-- creates a basalt button
function createButton(parent, text, posX, posY, sizeX, sizeY, bgColor, fgColor)
    return parent:addButton()
    :setText(text)
    :setBackground(bgColor)
    :setForeground(fgColor)
    :setPosition(posX, posY)
    :setSize(sizeX, sizeY)
end

-- creates a basalt checkbox
function createCheckbox(parent, posX, posY, sizeX, sizeY, bgColor, fgColor)
    return parent:addCheckbox()
    :setBackground(bgColor)
    :setForeground(fgColor)
    :setPosition(posX, posY)
    :setSize(sizeX, sizeY)
end

-- creates a simple pop up frame
function createPopup(frame, title, type, message, yesCallback)
    local popUpFrame = frame:addMovableFrame():setSize(23, 5)
    :setBackground(colors.white, "#", colors.lightGray)
    :setVisible(true)

    local popUpTitle = popUpFrame:addLabel()
    :setText(title)
    :setBackground(colors.orange)
    :setForeground(colors.yellow)
    :setPosition(1, 1)
    :setSize(23, 1)

    local popUpLabel = popUpFrame:addLabel()
    :setText(message)
    :setBackground(colors.white)
    :setPosition(2, 3)

    if type == "error" then
        popUpLabel:setForeground(colors.red)
    elseif type == "success" then
        popUpLabel:setForeground(colors.green)
    elseif type == "info" then
        popUpLabel:setForeground(colors.black)
    elseif type == "logout" then
        popUpLabel.setForeground(colors.black)
        popUpTitle.setText("Logout?")
        local yesButton = addButton(frame, "Yes", 2, 3, 3, 1, colors.blue, colors.white)
        local noButton = addButton(frame, "No", 4, 3, 3, 1, colors.blue, colors.white)

        yesButton:onClick(function(self, event, button, x, y)
            if event == "mouse_click" and button == 1 then
                yesCallback()
                popUpFrame:remove()
            end
        end)

        noButton:onClick(function(self, event, button, x, y)
            if event == "mouse_click" and button == 1 then                
                popUpFrame:remove()
            end
        end)
    end

    local popUpButton = popUpFrame:addButton()
    :setText("X")
    :setBackground(colors.orange)
    :setForeground(colors.red)
    :setPosition(23, 1)
    :setSize(1, 1)

    -- Listener for closing the pop up
    popUpButton:onClick(function(self, event, button, x, y)
        if event == "mouse_click" and button == 1 then
            popUpFrame:remove()
        end
    end)
end

-- adds the program menu at the top
function addProgramMenu(mainframe, current)
    return current:addDropdown()
    :setForeground(colors.lightBlue)
    :setBackground(colors.orange)
    :setPosition(1, 1)
    :setSelectionColor(colors.magenta, colors.yellow)
    :addItem("Banking", colors.orange, colors.lightBlue, "accountFrame")
    --:addItem("Investments", colors.orange, colors.lightBlue, "investmentsFrame")
    --:addItem("Marketplace", colors.orange, colors.lightBlue, "marketplaceFrame")
    --:addItem("Law", colors.orange, colors.lightBlue, "lawFrame")
    --:addItem("GPS", colors.orange, colors.lightBlue, "gpsFrame")
    --:addItem("Events", colors.orange, colors.lightBlue, "eventsFrame")
    --:addItem("Ledger", colors.orange, colors.lightBlue, "ledgerFrame")
    --:addItem("Mailbox", colors.orange, colors.lightBlue, "mailboxFrame")
    --:addItem("Leaderboard", colors.orange, colors.lightBlue, "leaderboardFrame")
    :addItem("Settings", colors.orange, colors.lightBlue, "settingsFrame")
    --:addItem("Help", colors.orange, colors.lightBlue, "helpFrame")
    :onChange(function(self, event, item)
        local path = "/GuardLink/client/ui/frames/" .. tostring(item.args[1])
        if fs.exists(path) then
                local frame = require(path)
                current:remove()
                frame.add(mainframe)
        end
    end)
end


return {
    createLabel = createLabel,
    createPane = createPane,
    createTextfield = createTextfield,
    createPopup = createPopup,
    createButton = createButton,
    formatNumber = formatNumber,
    addProgramMenu = addProgramMenu,
    createCheckbox = createCheckbox
}