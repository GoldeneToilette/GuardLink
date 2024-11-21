local network = require("/GuardLink/client/network/eventHandler")
local utils = require("/GuardLink/client/ui/utils")
local requestSender = require("/GuardLink/client/network/requestSender")
local ErrorHandler = require("/GuardLink/client/errorHandler")
local xmlParser = require("/GuardLink/client/ui/xmlParser")

local function add(mainFrame)
    local accountFrame = mainFrame:addFrame()
        :setSize("parent.w", "parent.h")
        :setBackground(colors.lightBlue)
        :setVisible(true)

    local uiElements = xmlParser.loadXML(accountFrame, "/GuardLink/client/ui/xml/accountFrame.xml")

    local nameLabel = uiElements["nameLabel"]
    local statusLabel = uiElements["statusLabel"]
    local balanceLabel = uiElements["balanceLabel"]
    local bannedLabel = uiElements["bannedLabel"] 

    -- function for updating account information
    local function updateInfo()
        local name = network.getServerData("username")     
                requestSender.sendAccountInfoRequest(name, network.getSocket(), function(serverData)
                    local accountInfo = textutils.unserializeJSON(serverData.accountInfo)
                    if accountInfo then
                        nameLabel:setText("Name: " .. accountInfo.name)
                        statusLabel:setText("Status: Online")
                        bannedLabel:setText("Banned: " .. tostring(accountInfo.banned))
                        balanceLabel:setText(utils.formatNumber(accountInfo.balance) .. " GC")
                    else
                        local placeHolder = "N/A"
                        nameLabel:setText(placeHolder)
                        statusLabel:setText("Status: Offline")
                        bannedLabel:setText(placeHolder)
                        balanceLabel:setText(placeHolder)
                    end
                end)
    end

    -- update info right after declaring the function
    updateInfo()

    local nameField = uiElements["nameField"] 
    local amountField = uiElements["amountField"] 

    local transactionButton = uiElements["transactionButton"]     

        transactionButton:onClick(function(_, event, button)
            if event == "mouse_click" and button == 1 then
                local receiver = nameField:getLine(1)
                local amount = amountField:getLine(1)
    
                -- Send transaction request
                local name = network.getServerData("username")     
                requestSender.sendTransactionRequest(name, receiver, amount, network.getSocket(), function(serverData)
                    local status = serverData.transactionStatus
                    if status then
                        if status == "TRANSACTION_SUCCESS" then
                            updateInfo()
                            utils.createPopup(accountFrame, "Success", "success", "Transaction Success!")
                            _G.logger:info("[accountFrame] Successful transaction!")
                        else
                            utils.createPopup(accountFrame, "Error", "error", status)
                            _G.logger:info("[accountFrame] Failed transaction: " .. status)
                        end
                    else
                        utils.createPopup(accountFrame, "Error", "error", "Failed to reach server")
                        _G.logger:info("[accountFrame] Failed transaction: Failed to reach server")
                    end
                end)
            end
        end)

    local dropdown = accountFrame:addDropdown()
    :setForeground(colors.lightBlue)
    :setBackground(colors.orange)
    :setPosition(1, 1)
    :setSelectionColor(colors.magenta, colors.yellow)
    :addItem("Banking", colors.orange)
    :addItem("Investments", colors.orange)
    :addItem("Marketplace", colors.orange)
    :addItem("Law", colors.orange)
    :addItem("GPS", colors.orange)
    :addItem("Events", colors.orange)
    :addItem("Ledger", colors.orange)
    :addItem("Mailbox", colors.orange)
    :addItem("Leaderboard", colors.orange)
    :addItem("Settings", colors.orange)
    :addItem("Help", colors.orange)

end


return {
    add = add
}
