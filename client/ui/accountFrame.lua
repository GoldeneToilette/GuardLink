local network = require("/GuardLink/client/network")
local popup = require("/GuardLink/client/ui/popup")

local data = network.getServerData()

function add(mainFrame)
    local accountFrame = mainFrame:addFrame()
    :setSize("parent.w", "parent.h")
    :setBackground(colors.white)
    :setVisible(true)

    local titleBar = accountFrame:addLabel()
    :setText("GLB 0.8a")
    :setFontSize(1)
    :setBackground(colors.blue)
    :setForeground(colors.white)
    :setPosition(1, 1)
    :setSize(25, 1)

    local logoutLabel = accountFrame:addLabel()
    :setText("X")
    :setBackground(colors.blue)
    :setForeground(colors.red)
    :setPosition(26, 1)
    :setSize(1, 1)

    -- ACCOUNT INFO DISPLAY ------------------------------------------------------
    local scrollableFrame = accountFrame:addScrollableFrame()
    :setPosition(1, 2)
    :setSize(26, 21)
    :setBackground(colors.white)
    :setForeground(colors.blue)
    :setDirection("vertical")

    local nameLabel = scrollableFrame:addLabel()
    :setBackground(colors.lightBlue)
    :setText("")
    :setForeground(colors.blue)
    :setPosition(2, 2)
    :setSize(24, 2)

    local statusLabel = scrollableFrame:addLabel()
    :setTextAlign("left")
    :setText("")
    :setFontSize(1)
    :setBackground(colors.lightBlue)
    :setForeground(colors.blue)
    :setPosition(2, 5)
    :setSize(14, 1)

    local balanceLabel = scrollableFrame:addLabel()
    :setFontSize(1)
    :setText("")
    :setBackground(colors.blue)
    :setForeground(colors.orange)
    :setPosition(18, 6)
    :setSize(10, 1)

    local balancePane = scrollableFrame:addPane()
    :setSize(10, 3)
    :setPosition(17, 5)
    :setBackground(colors.blue)

    local bannedLabel = scrollableFrame:addLabel()
    :setBackground(colors.lightBlue)
    :setText("")
    :setForeground(colors.blue)
    :setPosition(2, 7)
    :setSize(14, 1)
    -- ACCOUNT INFO DISPLAY ------------------------------------------------------

    -- fetches the account data from the server
    function updateInfo()
        network.setResponseCallback(function(serverData)
            if serverData.accountInfo then
                local accountInfo = textutils.unserializeJSON(serverData.accountInfo)
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
        network.sendAccountInfoRequest(data.username, network.getSocket())
    end


    updateInfo()

    -- TRANSACTION PANE ----------------------------------------------------------
    local transactionPane = scrollableFrame:addPane()
    :setSize(24, 9)
    :setPosition(2, 9)
    :setBackground(colors.lightBlue)

    local transactionLabel = scrollableFrame:addLabel()
    :setText("Transfer Balance")
    :setBackground(colors.lightBlue)
    :setForeground(colors.blue)
    :setPosition(6, 10)
    :setSize(17, 1)

    local transactionNameLabel = scrollableFrame:addLabel()
    :setText("Name:")
    :setBackground(colors.lightBlue)
    :setForeground(colors.blue)
    :setPosition(3, 12)
    :setSize(5, 1)

    local transactionAmountLabel = scrollableFrame:addLabel()
    :setText("Amount:")
    :setBackground(colors.lightBlue)
    :setForeground(colors.blue)
    :setPosition(3, 15)
    :setSize(7, 1)

    local nameField = scrollableFrame:addTextfield()
    :addLine("")
    :setBackground(colors.white)
    :setForeground(colors.blue)
    :setPosition(10, 12)
    :setSize(15, 1)

    local amountField = scrollableFrame:addTextfield()
    :addLine("")
    :setBackground(colors.white)
    :setForeground(colors.blue)
    :setPosition(10, 15)
    :setSize(8, 1)

    local transactionButton = scrollableFrame:addButton()
    :setText(" Send")
    :setSize(6, 3)
    :setPosition(19, 14)
    :setBackground(colors.blue)
    :setForeground(colors.white)
    -- TRANSACTION PANE ----------------------------------------------------------

    -- handles the transaction button
    transactionButton:onClick(function(self, event, button, x, y)
        if event == "mouse_click" and button == 1 then
            local receiver = nameField:getLine(1)
            local amount = amountField:getLine(1)

                network.setResponseCallback(function(serverData)
                    local status = serverData.transactionStatus
                    if status then
                        -- if transaction is successful
                        if status == "TRANSACTION_SUCCESS" then
                            popup.create(accountFrame, "Success", "success", "Success!")
                            updateInfo()
                        -- all other cases
                        elseif status == "INVALID_TOKEN" then
                            popup.create(accountFrame, "Error", "error", status)
                        elseif status == "SENDER_NOT_FOUND" then
                            popup.create(accountFrame, "Error", "error", status)
                        elseif status == "RECEIVER_NOT_FOUND" then
                            popup.create(accountFrame, "Error", "error", status)
                        elseif status == "INVALID_AMOUNT" then
                            popup.create(accountFrame, "Error", "error", status)
                        elseif status == "INSUFFICIENT_FUNDS" then
                            popup.create(accountFrame, "Error", "error", status)
                        else
                            popup.create(accountFrame, "Error", "error", status)
                        end
                    else
                        popup.create(accountFrame, "Error", "error", "Failed to reach server")
                    end
                end)

                -- Send the login request to the server
                network.sendTransactionRequest(data.username, receiver, amount, network.getSocket())
        end
    end)



end

return {
    add = add
}