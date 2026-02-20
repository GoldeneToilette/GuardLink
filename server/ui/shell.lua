local ctx
local frame 

local console = {
    lines = {},
    cursorX = 1,
    cursorY = 1,
    width = 0,
    height = 0,
    symbolColor = colors.lightGray,
    textColor = colors.white,
    backgroundColor = colors.black,
    engine = requireC("/GuardLink/server/shell/engine.lua")  
}
console.engine:setup()

local function printResult(tbl)
    if tbl.type == "success" then
        term.setTextColor(colors.green)
    elseif tbl.type == "fail" or tbl.type == "error" then
        term.setTextColor(colors.red)        
    elseif tbl.type == "info" then
        term.setTextColor(console.textColor)
    elseif tbl.type == "empty" then
        return
    end
    if type(tbl.str) == "string" then
        print(tbl.str)
    else    
        for i,v in ipairs(tbl.str) do
            print(v)
        end
    end
end

local function repl()
    while true do
        local input = read()
        local result = console.engine:run(input)
        printResult(result)
        term.setTextColor(console.symbolColor)
        write((console.engine.cwd:sub(2) or "") .. console.symbol)
        term.setTextColor(console.textColor)
    end
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
        console.width, console.height = term.getSize()
        console.symbol = console.engine.cfg.prompt or ">"
        if console.engine.cfg.use_theme == true then
            console.symbolColor = ctx.theme.colors["highlight"]
            console.textColor = ctx.theme.colors["tertiary"]
            console.backgroundColor = ctx.theme.colors["primary"]
        end
        term.setBackgroundColor(console.backgroundColor)
        term.setTextColor(console.symbolColor)
        write((console.engine.cwd:sub(2) or "") .. console.symbol)
        term.setTextColor(console.textColor)
        repl()
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