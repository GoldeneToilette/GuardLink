local basalt = require("/GuardLink/server/lib/basalt")
local commands = require("/GuardLink/server/shell/commands")

local MAX_LINES = 17

function labelManager(outputFrame)
    local labels = {}

    local function addLine(text, bgColor, fgColor)
        -- Set default colors if not provided
        bgColor = bgColor or colors.black
        fgColor = fgColor or colors.white

        -- Remove the first label if at max capacity
        if #labels == MAX_LINES then
            labels[1]:remove()
            table.remove(labels, 1)

            -- Shift remaining labels up
            for i, label in ipairs(labels) do
                label:setPosition(1, i)
            end
        end

        -- Create new label
        local newLabel = outputFrame:addLabel()
            :setText(text)  -- Ensure text is being set
            :setPosition(1, #labels + 2)
            :setSize(51, 1)
            :setBackground(bgColor)
            :setForeground(fgColor)
            :show()

        -- Debug log
        print("Label added at position:", #labels + 1)

        table.insert(labels, newLabel)

        -- Debug current labels
        for i, label in ipairs(labels) do
            print("Label " .. i .. ": " .. (label:getText() or "nil"))
        end
    end

    return {
        addLine = addLine,
    }
end

local function createShell()
    -- width 51
    -- height 19
    local mainFrame = basalt.createFrame():setVisible(true)
    :setBackground(colors.black)
    :setForeground(colors.white)

    local titleBar = mainFrame:addLabel()
    :setText("GuardShell 1.0")
    :setPosition(1,1)
    :setSize(51,1)
    :setBackground(colors.blue)
    :setForeground(colors.white)

    local label = mainFrame:addLabel()
    :setText(">")
    :setPosition(1,19)
    :setSize(1,1)
    :setBackground(colors.black)
    :setForeground(colors.white)    

    local inputField = mainFrame:addInput()
    :setPosition(2,19)
    :setSize(50,1)
    :setInputLimit(100,1)
    :setBackground(colors.black)
    :setForeground(colors.white)    

    local manager = labelManager(mainFrame)

    local function inputOnKey(self, event, key)
        if key == 257 then
            local input = inputField:getValue()
            inputField:setValue("")
            -- Add the input to the output area as a new line
            manager.addLine("> " .. input, colors.black, colors.orange)

            local response = commands.handleCommand(input)
            if not response then return end
            for _, line in ipairs(response) do
                manager.addLine(line)
            end

            mainFrame:setFocusedChild(inputField)
        end
    end

    mainFrame:setImportant(inputField)
    inputField:onKey(inputOnKey)
end

return {
    createShell = createShell
}
