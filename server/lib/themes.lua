local active = nil

local kernel = require("kernel.kernel")

local c = {
    primary = colors.orange,
    secondary = colors.magenta,
    background = colors.lightBlue,
    surface = colors.yellow,
    textprimary = colors.lime,
    textsecondary = colors.pink,
    border = colors.cyan,
    success = colors.purple,
    error = colors.blue,
    highlight = colors.brown
}

local function init() 
    -- system colors, they are the same in all themes
    term.setPaletteColor(colors.red, 0xf42929) -- red
    term.setPaletteColor(colors.white, 0xffffff) -- white
    term.setPaletteColor(colors.black, 0x000000) -- black
    term.setPaletteColor(colors.green, 0x2ec120) -- green
    term.setPaletteColor(colors.lightGray, 0x999999) -- light gray
    term.setPaletteColor(colors.gray, 0x4C4C4C) -- gray

    -- rest of the colors, they are customizable. if none of the themes are set, they will appear all white
    term.setPaletteColor(colors.orange, 0xffffff)
    term.setPaletteColor(colors.magenta, 0xffffff)
    term.setPaletteColor(colors.lightBlue, 0xffffff)
    term.setPaletteColor(colors.yellow, 0xffffff)
    term.setPaletteColor(colors.lime, 0xffffff)
    term.setPaletteColor(colors.pink, 0xffffff)
    term.setPaletteColor(colors.cyan, 0xffffff)
    term.setPaletteColor(colors.purple, 0xffffff)
    term.setPaletteColor(colors.blue, 0xffffff)
    term.setPaletteColor(colors.brown, 0xffffff)
    return 0
end

local function setTheme(theme, ter)
    local themes = kernel:execute("kernel.get_config", "themes")
    if not themes[theme] then return "UNKNOWN_THEME" end
    for i, color in ipairs(themes[theme]) do
        term.native().setPaletteColor(c[color[1]], tonumber(color[2], 16))
        if ter then ter.setPaletteColor(c[color[1]], tonumber(color[2], 16)) end
    end
    active = theme
    return 0
end

local function getThemes()
    return kernel:execute("kernel.get_config", "themes")
end

local function getTheme()
    return active
end

local function setColor(t, hex, ter)
    if c[t] then
        hex = hex:gsub("^#", "0x") 
        term.native().setPaletteColor(c[t], tonumber(hex, 16))
        if ter then ter.setPaletteColor(c[t], tonumber(hex, 16)) end
    end
end

local function resetColors()
    term.setPaletteColor(colors.white, 0xF0F0F0)
    term.setPaletteColor(colors.orange, 0xF2B233)
    term.setPaletteColor(colors.magenta, 0xE57FD8)
    term.setPaletteColor(colors.lightBlue, 0x99B2F2)
    term.setPaletteColor(colors.yellow, 0xDEDE6C)
    term.setPaletteColor(colors.lime, 0x7FCC19)
    term.setPaletteColor(colors.pink, 0xF2B2CC)
    term.setPaletteColor(colors.gray, 0x4C4C4C)
    term.setPaletteColor(colors.lightGray, 0x999999)
    term.setPaletteColor(colors.cyan, 0x4C99B2)
    term.setPaletteColor(colors.purple, 0xB266E5)
    term.setPaletteColor(colors.blue, 0x3366CC)
    term.setPaletteColor(colors.brown, 0x7F664C)
    term.setPaletteColor(colors.green, 0x57A64E)
    term.setPaletteColor(colors.red, 0xCC4C4C)
    term.setPaletteColor(colors.black, 0x111111)
end

return {
    init = init,
    setTheme = setTheme,
    getThemes = getThemes,
    colors = c,
    getTheme = getTheme,
    setColor = setColor,
    resetColors = resetColors
}