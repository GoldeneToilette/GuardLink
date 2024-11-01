local network = require("/GuardLink/client/network")
local accountFrame = require("/GuardLink/client/ui/accountFrame")

function add(mainFrame)
    local loginFrame = mainFrame:addFrame()
    :setSize("parent.w", "parent.h")
    :setBackground(colors.blue)
    :setVisible(true)

    local whitePane = loginFrame:addPane()
    :setSize(22, 18)
    :setBackground(colors.white)
    :setPosition(3, 2)

    local titleLabel = loginFrame:addLabel()
    :setText("GuardLink Banking")
    :setFontSize(1)
    :setBackground(colors.white)
    :setForeground(colors.blue)
    :setPosition(6, 5)

    local nameLabel = loginFrame:addLabel()
    :setText("Name:")
    :setFontSize(1)
    :setBackground(colors.white)
    :setForeground(colors.black)
    :setPosition(8, 8)

    local passwordLabel = loginFrame:addLabel()
    :setText("Password:")
    :setFontSize(1)
    :setBackground(colors.white)
    :setForeground(colors.black)
    :setPosition(8, 11)

    local nameField = loginFrame:addTextfield()
    :addLine("")
    :setBackground(colors.lightBlue)
    :setForeground(colors.blue)
    :setPosition(8, 9)
    :setSize(12, 1)

    local passwordField = loginFrame:addTextfield()
    :addLine("")
    :setBackground(colors.lightBlue)
    :setForeground(colors.blue)
    :setPosition(8, 12)
    :setSize(12, 1)

    local infoLabel = loginFrame:addLabel()
    :setText("")
    :setFontSize(1)
    :setBackground(colors.white)
    :setForeground(colors.white)
    :setPosition(9, 19)
    :setSize(13, 1)

    local loginButton = loginFrame:addButton():setText("Login")
    :setSize(12, 3)
    :setPosition(8, 15)
    :setBackground(colors.blue)
    :setForeground(colors.lightBlue)

    loginButton:onClick(function(self, event, button, x, y)
        if event == "mouse_click" and button == 1 then
            local username = nameField:getLine(1)
            local password = passwordField:getLine(1)

            if username ~= "" and password ~= "" then
                network.setResponseCallback(function(serverData)
                    if serverData.sessionToken then
                        serverData.username = username

                        infoLabel:setForeground(colors.green)
                        infoLabel:setText("Success!")
                        os.sleep(1)
                        accountFrame.add(mainFrame)                  
                        loginScreen:setVisible(false)
                    else
                        infoLabel:setForeground(colors.red)
                        infoLabel:setText("Invalid Token")
                    end
                end)

                -- Send the login request to the server
                network.sendLoginRequest(username, password, network.getSocket())
            else
                infoLabel:setForeground(colors.red)
                infoLabel:setText("Invalid input!")
            end
        end
    end)
end


return {
    add = add
}
