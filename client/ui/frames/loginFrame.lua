local network = require("network.eventHandler")
local requestSender = require("network.requestSender")
local accountFrame = require("ui.frames.accountFrame")
local xmlParser = require("utils.xmlParser")

local function add(mainFrame)
    local loginFrame = mainFrame:addFrame()
    :setSize("parent.w", "parent.h")
    :setBackground(colors.orange)
    :setVisible(true)

    local uiElements = xmlParser.loadXML(loginFrame, "/GuardLink/client/ui/xml/loginFrame.xml")

    local loginButton = uiElements["loginButton"]
    local nameField = uiElements["nameField"]
    local passwordField = uiElements["passwordField"]
    local infoLabel = uiElements["infoLabel"] 

    -- MINOR BUG: callbacks for failed logins are still put in the queue, causes longer loading times if you fail login
    loginButton:onClick(function(self, event, button, x, y)
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
                        loginFrame:remove()                 
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
