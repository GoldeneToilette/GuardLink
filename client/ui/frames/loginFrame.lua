local network = require("/GuardLink/client/network/eventHandler")
local requestSender = require("/GuardLink/client/network/requestSender")
local accountFrame = require("/GuardLink/client/ui/frames/accountFrame")
local utils = require("/GuardLink/client/ui/utils")

function add(mainFrame)
    local loginFrame = mainFrame:addFrame()
    :setSize("parent.w", "parent.h")
    :setBackground(colors.blue)
    :setVisible(true)

    local titleLable = utils.createLabel(loginFrame, "GuardLink Banking", 6, 5, 17, 1, colors.white, colors.blue, 1)
    local nameLable = utils.createLabel(loginFrame, "Name: ", 8, 8, 5, 1, colors.white, colors.black, 1)
    local passwordLabel = utils.createLabel(loginFrame, "Password: ", 8, 11, 9, 1, colors.white, colors.black, 1)
    local infoLabel = utils.createLabel(loginFrame, "", 9, 19, 13, 1, colors.white, colors.white, 1)

    local whitePane = utils.createPane(loginFrame, 3, 2, 22, 18, colors.white)

    local nameField = utils.createTextfield(loginFrame, 8, 9, 12, 1, colors.lightBlue, colors.blue)
    local passwordField = utils.createTextfield(loginFrame, 8, 12, 12, 1, colors.lightBlue, colors.blue)

    local loginButton = loginFrame:addButton()
    :setText("Login")
    :setPosition(8, 15)
    :setSize(12, 3)
    :setBackground(colors.blue)
    :setForeground(colors.lightBlue)
    :onClick(function(self, event, button, x, y)
        if event == "mouse_click" and button == 1 then
            local name = nameField:getLine(1)
            local password = passwordField:getLine(1)

            if name ~= "" and password ~= "" then
                requestSender.sendLoginRequest(name, password, network.getSocket(), function(serverData)
                    if serverData.sessionToken then
                        serverData.username = name
                        infoLabel:setForeground(colors.green)
                        infoLabel:setText("Success!")
                        _G.logger:info("[loginFrame] Successful Login!")
                        os.sleep(1)
                        accountFrame.add(mainFrame)                  
                        loginScreen:setVisible(false)
                    else
                        infoLabel:setForeground(colors.red)
                        infoLabel:setText("Invalid token!")
                        _G.logger:error("[loginFrame] Invalid token!")
                    end
                end)
            else
                infoLabel:setForeground(colors.red)
                infoLabel:setText("Invalid input!")
                _G.logger:error("[loginFrame] Invalid input: " .. name .. " " .. password)
            end
        end
    end)


end


return {
    add = add
}
