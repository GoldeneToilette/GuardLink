os.loadAPI("/GuardLink/client/lib/cryptoNet")
local basalt = require("/GuardLink/client/lib/basalt")
local network = require("/GuardLink/client/Network")

-- Connects to the server
network.connectServer("GuardLinkBank")

-- LOGIN SCREEN LOGIC -----------------------------------------------------------------------------
local loginScreen = basalt.createFrame()
loginScreen:setBackground(colors.blue)

local whitePane = loginScreen:addPane()
whitePane:setSize(22, 18)
whitePane:setBackground(colors.white)
whitePane:setPosition(3, 2)

local titleLabel = loginScreen:addLabel()
titleLabel:setText("GuardLink Banking")
titleLabel:setFontSize(1)
titleLabel:setBackground(colors.white)
titleLabel:setForeground(colors.blue)
titleLabel:setPosition(6, 5)

local nameLabel = loginScreen:addLabel()
nameLabel:setText("Name:")
nameLabel:setFontSize(1)
nameLabel:setBackground(colors.white)
nameLabel:setForeground(colors.black)
nameLabel:setPosition(8, 8)

local passwordLabel = loginScreen:addLabel()
passwordLabel:setText("Password:")
passwordLabel:setFontSize(1)
passwordLabel:setBackground(colors.white)
passwordLabel:setForeground(colors.black)
passwordLabel:setPosition(8, 11)

local nameField = loginScreen:addTextfield()
nameField:addLine("")
nameField:setBackground(colors.lightBlue)
nameField:setForeground(colors.blue)
nameField:setPosition(8, 9)
nameField:setSize(12, 1)

local passwordField = loginScreen:addTextfield()
passwordField:addLine("")
passwordField:setBackground(colors.lightBlue)
passwordField:setForeground(colors.blue)
passwordField:setPosition(8, 12)
passwordField:setSize(12, 1)

local infoLabel = loginScreen:addLabel()
infoLabel:setText("")
infoLabel:setFontSize(1)
infoLabel:setBackground(colors.white)
infoLabel:setForeground(colors.white)
infoLabel:setPosition(9, 17)
infoLabel:setSize(13, 1)

local loginButton = loginScreen:addButton():setText("Login")
loginButton:setSize(12, 3)
loginButton:setPosition(8, 15)
loginButton:setBackground(colors.blue)
loginButton:setForeground(colors.lightBlue)

loginButton:onClick(function(self, event, button, x, y)
    if event == "mouse_click" and button == 1 then
        local username = nameField:getLine(1)
        local password = passwordField:getLine(1)

        if username ~= "" and password ~= "" then
            network.setResponseCallback(function(serverData)
                if serverData.sessionToken then
                    infoLabel:setForeground(colors.green)
                    infoLabel:setText("Success!")
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
-- LOGIN SCREEN LOGIC -----------------------------------------------------------------------------

-- Runs both processes at the same time
parallel.waitForAll(network.startListener, basalt.autoUpdate)




