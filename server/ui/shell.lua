local ctx
local frame 

local commands = {}
for _, file in ipairs(fs.list("/GuardLink/server/commands")) do
    local cmd = require("commands." .. file:sub(1, #file-4))
    commands[cmd.name] = cmd
end

local function add()
    local f = ctx.mainframe:addFrame()
    :setSize("parent.w", "parent.h - 1")
    :setPosition(1,2)
    :setVisible(true)
    :setZIndex(1)
    frame = f
    
    local program = f:addProgram()
    :setSize("parent.w", "parent.h")
    :setPosition(1, 1)

    program:execute(function()
        local function parse(input)
            local args = {}
            for word in input:gmatch("%S+") do
                table.insert(args, word)
            end
            return table.remove(args, 1), args
        end
        term.setBackgroundColor(colors.black)
        term.setTextColor(_G.theme.colors.highlight)
        write("> ")
        term.setTextColor(colors.white)
        while true do
            local input = read()
            if input and input ~= "" then
                local name, args = parse(input)
                local cmd = commands[name]
                if cmd then
                    local ok, err = pcall(cmd.run, args)
                    if not ok then
                        term.setTextColor(colors.red)
                        print("Error: "..tostring(err))
                        term.setTextColor(colors.white)
                    end
                else
                    term.setTextColor(colors.red)
                    print("Unknown command: " .. name .. ", type 'help'!")
                    term.setTextColor(colors.white)
                end
            end
            term.setTextColor(_G.theme.colors.highlight)
            write("> ")
            term.setTextColor(colors.white)
        end
    end)
end

local function remove()
    frame:setVisible(false)
    frame:remove()
end

local function setContext(ui)
    ctx = ui
end

return {
    displayName = "Shell",
    add = add,
    remove = remove,
    setContext = setContext
}