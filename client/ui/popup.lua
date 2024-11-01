-- creates a simple pop up frame
function create(frame, title, type, message)
    local popUpFrame = frame:addMovableFrame():setSize(18, 5)
    :setBackground(colors.white, "#", colors.gray)
    :setVisible(true)

    local popUpTitle = popUpFrame:addLabel()
    :setText(title)
    :setBackground(colors.blue)
    :setForeground(colors.white)
    :setPosition(1, 1)
    :setSize(18, 1)

    local popUpLabel = popUpFrame:addLabel()
    :setText(message)
    :setBackground(colors.white)
    :setPosition(1, 3)

    if type == "error" then
        popUpLabel.setForeground(colors.red)
    elseif type == "success" then
        popUpLabel.setForeground(colors.green)
    elseif type == "info" then
        popUpLabel.setForeground(colors.white)
    end

    local pupUpButton = popUpFrame:addButton()
    :setText("X")
    :setBackground(colors.blue)
    :setForeground(colors.red)
    :setPosition(18, 1)
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