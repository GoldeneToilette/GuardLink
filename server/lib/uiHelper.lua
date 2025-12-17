local uihelper = {}

function uihelper.newLabel(parent, text, posX, posY, sizeX, sizeY, bgColor, fgColor, fontSize)
    return parent:addLabel()
        :setText(text)
        :setPosition(posX, posY)
        :setSize(sizeX or #text, sizeY)
        :setBackground(bgColor)
        :setForeground(fgColor)
        :setFontSize(fontSize or 1)
end

function uihelper.newPane(parent, posX, posY, sizeX, sizeY, bgColor)
    return parent:addPane()
        :setPosition(posX, posY)
        :setSize(sizeX, sizeY)
        :setBackground(bgColor)
end

function uihelper.newTextfield(parent, posX, posY, sizeX, sizeY, bgColor, fgColor)
    return parent:addTextfield()
        :addLine("")
        :setPosition(posX, posY)
        :setSize(sizeX, sizeY)
        :setBackground(bgColor)
        :setForeground(fgColor)
end

function uihelper.newButton(parent, text, posX, posY, sizeX, sizeY, bgColor, fgColor, callback)
    return parent:addButton()
        :setText(text)
        :setBackground(bgColor)
        :setForeground(fgColor)
        :setPosition(posX, posY)
        :setSize(sizeX, sizeY)
        :onClick(callback)
end

function uihelper.newCheckbox(parent, posX, posY, sizeX, sizeY, bgColor, fgColor)
    return parent:addCheckbox()
        :setBackground(bgColor)
        :setForeground(fgColor)
        :setPosition(posX, posY)
        :setSize(sizeX, sizeY)
end

function uihelper.newInputfield(parent, posX, posY, sizeX, sizeY, bgColor, fgColor)
    return parent:addInput()
        :setInputType("text")
        :setBackground(bgColor)
        :setForeground(fgColor)
        :setPosition(posX, posY)
        :setSize(sizeX, sizeY)
end

function uihelper.newPopup(parent, sizeX, sizeY, title, type, message, canClose, buttons)
    local frame = parent:addMovableFrame():setSize(sizeX, sizeY)
    :setBackground(colors.white, "#", colors.lightGray)
    :setPosition(2, 8)
    :setVisible(true)

    local title = frame:addLabel()
    :setText(title)
    :setBackground(colors.blue)
    :setForeground(colors.white)
    :setPosition(1, 1)
    :setSize(sizeX, 1)

    local label = frame:addLabel()
    :setText(message)
    :setBackground(colors.white)
    :setPosition(3, 3)
    :setSize(#message, 1)

    if type == "error" then
        label:setForeground(colors.red)
    elseif type == "success" then
        label:setForeground(colors.green)
    elseif type == "info" then
        label:setForeground(colors.black)
    elseif type == "action" then
        label:setForeground(colors.black)
        for _,v in ipairs(buttons) do
            uihelper.newButton(frame, v.name, v.posX, v.posY, v.sizeX, v.sizeY, v.bg, v.fg, v.callback)
        end
    end
    if canClose then
        local closeButton = uihelper.newButton(frame, "X", sizeX, 1, 1, 1, colors.blue, colors.red)
        closeButton:onClick(function(self, event, button, x, y)
            if event == "mouse_click" and button == 1 then
                frame:remove()
                frame:disable()
            end
        end)
    end
end

return uihelper