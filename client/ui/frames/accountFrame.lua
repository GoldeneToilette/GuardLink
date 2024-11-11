local network = require("/GuardLink/client/network/eventHandler")
local utils = require("/GuardLink/client/ui/utils")
local requestSender = require("/GuardLink/client/network/requestSender")
local ErrorHandler = require("/GuardLink/client/errorHandler")

local function add(mainFrame)
    local accountFrame = mainFrame:addFrame()
        :setSize("parent.w", "parent.h")
        :setBackground(colors.white)
        :setVisible(true)

    local titleBar = utils.createLabel(accountFrame, "GLB 0.8a", 1, 1, 26, 1, colors.blue, colors.white, 1)
    
    -- account information ----------------------------------------------------------------------------------
    local nameLabel = utils.createLabel(accountFrame, " ", 2, 3, 24, 2, colors.lightBlue, colors.blue, 1)
    local statusLabel = utils.createLabel(accountFrame, " ", 2, 6, 14, 1, colors.lightBlue, colors.blue, 1)
    statusLabel:setTextAlign("left")
    local balanceLabel = utils.createLabel(accountFrame, " ", 18, 7, 9, 1, colors.blue, colors.orange, 1)
    utils.createPane(accountFrame, 17, 6, 10, 3, colors.blue)

    local bannedLabel = utils.createLabel(accountFrame, " ", 2, 8, 14, 1, colors.lightBlue, colors.blue, 1)
    -- account information ----------------------------------------------------------------------------------

    -- function for updating account information
    local function updateInfo()
        local name = network.getServerData("username")     
                requestSender.sendAccountInfoRequest(name, network.getSocket(), function(serverData)
                    local accountInfo = textutils.unserializeJSON(serverData.accountInfo)
                    if accountInfo then
                        nameLabel:setText("Name: " .. accountInfo.name)
                        statusLabel:setText("Status: Online")
                        bannedLabel:setText("Banned: " .. tostring(accountInfo.banned))
                        balanceLabel:setText(accountInfo.balance .. " GC")
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


    local transactionPane = utils.createPane(accountFrame, 2, 10, 24, 9, colors.lightBlue)

    utils.createLabel(accountFrame, "Transfer Balance", 6, 11, 17, 1, colors.lightBlue, colors.blue, 1)
    utils.createLabel(accountFrame, "Name: ", 3, 13, 5, 1, colors.lightBlue, colors.blue, 1)
    utils.createLabel(accountFrame, "Amount: ", 3, 16, 7, 1, colors.lightBlue, colors.blue, 1)

    local nameField = utils.createTextfield(accountFrame, 10, 13, 15, 1, colors.white, colors.blue)
    local amountField = utils.createTextfield(accountFrame, 10, 16, 8, 1, colors.white, colors.blue)

    local transactionButton = accountFrame:addButton()
        :setText(" Send")
        :setSize(6, 3)
        :setPosition(19, 15)
        :setBackground(colors.blue)
        :setForeground(colors.white)

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



end


return {
    add = add
}
