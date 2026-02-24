local ctx
local frame 

local c = {
    symbol = colors.lightGray,
    text = colors.white,
    background = colors.black,
    success = colors.green,
    fail = colors.red,
}
local codeMap = {
    ["0"] = "background",
    ["1"] = "surface",
    ["2"] = "border",
    ["3"] = "primary",
    ["4"] = "secondary",
    ["5"] = "textprimary",
    ["6"] = "textsecondary",
    ["7"] = "success",
    ["8"] = "error",
    ["9"] = "highlight"    
}

local prompt

local engine = requireC("/GuardLink/server/shell/engine.lua")
engine:setup()

local function printColor(str, default)
    local fg = default
    local bg = c.background
    local pos = 1
    while pos <= #str do
        local s, e, b, f = str:find("\167([0-9r])([0-9r])", pos)
        if s then
            if s > pos then
                term.setBackgroundColor(bg)
                term.setTextColor(fg)
                io.write(str:sub(pos, s - 1))
            end
            bg = (b == "r") and c.background or (ctx.theme.colors[codeMap[b]] or c.background)
            fg = (f == "r") and default or (ctx.theme.colors[codeMap[f]] or default)
            pos = e + 1
        else
            term.setBackgroundColor(bg)
            term.setTextColor(fg)
            io.write(str:sub(pos))
            break
        end
    end
    term.setBackgroundColor(c.background)
    print()
end

local function printResult(tbl)
    local def = c.text
    if tbl.type == "success" then
        def = c.success
    elseif tbl.type == "fail" or tbl.type == "error" then
        def = c.fail  
    elseif tbl.type == "info" then
        def = c.text
    elseif tbl.type == "empty" then
        return
    end
    if type(tbl.str) == "string" then
        if tbl.str ~= "" then printColor(tbl.str, def) end
    else    
        for i,v in ipairs(tbl.str) do
            if tbl.str ~= "" then printColor(v, def) end
        end
    end
end

local function autoComplete(s)
    if s == "" then return {} end 
    local matches = {}
    for k, _ in pairs(engine.cmds) do
        if k:sub(1, #s) == s then
            table.insert(matches, k:sub(#s + 1))
        end
    end
    return matches
end

local function repl()
    while true do
        local input = read(engine.hideInput ~= false and " " or nil, engine.history, autoComplete)
        local result = engine:run(input)
        printResult(result)
        term.setTextColor(c.symbol)
        term.setBackgroundColor(c.background)
        write((engine.cwd:gsub("^/", "") or "") .. prompt)
        term.setTextColor(c.text)
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
        local cfg = engine.cfg
        local theme = ctx.theme.colors
        prompt = cfg.prompt or ">"
        if cfg.use_theme then
            c.symbol = theme["highlight"]
            c.text = theme["textprimary"]
            c.background = theme["background"]
            c.success = theme["success"]
            c.fail = theme["error"]
            ctx.theme.setTheme(ctx.theme.getTheme())
        end
        term.setBackgroundColor(c.background)
        term.clear()        
        term.setTextColor(c.symbol)
        write((engine.cwd:gsub("^/", "") or "") .. prompt)
        term.setTextColor(c.text)        
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