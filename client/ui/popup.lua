-- creates a simple pop up frame
function create(frame, title, type, message)
    local popUpFrame = frame:addMovableFrame():setSize(10, 5)
    :setBackground(colors.white, "#", colors.gray)
    :setVisible(true)

    local popUpTitle = popUpFrame:addLabel()
    :setText(title)
    :setBackground(colors.blue)
    :setForeground(colors.white)
    :setPosition(1, 1)
    :setSize(10, 1)

    local pupUpLabel = popUpFrame:addLabel()
    :setText(message)
    :setBackground(colors.white)
    :setForeground(colors.black)
    :setPosition(1, 3)

    local pupUpButton = popUpFrame:addButton()
    :setText("X")
    :setBackground(colors.blue)
    :setForeground(colors.red)
    :setPosition(10, 1)
    :setSize(1, 1)

    -- Listener for closing the pop up
    popUpButton:onClick(function(self, event, button, x, y)
        if event == "mouse_click" and button == 1 then
            popUpFrame:remove()
        end
    end)
end