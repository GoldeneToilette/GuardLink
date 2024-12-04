local basalt = require("/GuardLink/server/lib/basalt")
local commands = require("/GuardLink/server/shell/commands")

local MAX_LINES = 17

local function labelManager(outputFrame)
    local labels = {}

    local function addLine(text, bgColor, fgColor)
        bgColor = bgColor or colors.black
        fgColor = fgColor or colors.white
    
        local START_ROW = 2
    
        if #labels == MAX_LINES then
            labels[1]:remove()
            table.remove(labels, 1)
    
            for i, label in ipairs(labels) do
                label:setPosition(1, START_ROW + i - 1)
            end
        end
    
        local newLabel = outputFrame:addLabel()
            :setText(text)
            :setPosition(1, START_ROW + #labels)
            :setSize(51, 1)
            :setBackground(bgColor)
            :setForeground(fgColor)
            :show()
    
        table.insert(labels, newLabel)
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
    
            manager.addLine("> " .. input, colors.black, colors.orange)
    
            local response = commands.handleCommand(input)
            if response then
                for _, line in ipairs(response) do
                    manager.addLine(line)
                end
            end
    
            inputField:getParent():setFocusedChild(inputField)
            inputField:getParent():setCursor(true, inputField:getX(), inputField:getY())
            _G.logger:debug("Focused: " .. tostring(inputField:isFocused()))
        end
    end

    inputField:onKey(inputOnKey)
end

return {
    createShell = createShell
}
