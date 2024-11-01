-- creates a simple pop up frame
function create(frame, title, type, message)
    local popUpFrame = frame:addMovableFrame():setSize(23, 5)
    :setBackground(colors.white, "#", colors.lightGray)
    :setVisible(true)

    local popUpTitle = popUpFrame:addLabel()
    :setText(title)
    :setBackground(colors.blue)
    :setForeground(colors.white)
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
        popUpLabel:setForeground(colors.white)
    end

    local popUpButton = popUpFrame:addButton()
    :setText("X")
    :setBackground(colors.blue)
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

return {
    create = create
}