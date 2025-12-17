local fileUtils = require "lib.fileUtils"
local themes = {}

local defaultPath = "/GuardLink/server/config/themes.json"

local c = {
    primary = colors.orange,
    secondary = colors.magenta,
    tertiary = colors.lightBlue,
    highlight = colors.yellow,
    subtle = colors.lime,
    accent = colors.pink,
    info = colors.cyan,
    alert = colors.purple,
    emphasis = colors.blue,
    muted = colors.brown
}

local function init(path) 
    if not fs.exists(path or defaultPath) then
        fileUtils.write(path or defaultPath, "")
    end
    themes = textutils.unserializeJSON(fileUtils.read(path or defaultPath))

    -- system colors, they are the same in all themes
    term.setPaletteColour(colors.red, 0xf42929) -- red
    term.setPaletteColour(colors.white, 0xffffff) -- white
    term.setPaletteColour(colors.black, 0x000000) -- black
    term.setPaletteColour(colors.green, 0x2ec120) -- green
    term.setPaletteColour(colors.lightGray, 0x999999) -- light gray
    term.setPaletteColour(colors.gray, 0x4C4C4C) -- gray

    -- rest of the colors, they are customizable. if none of the themes is set, they will appear all white
    term.setPaletteColour(colors.orange, 0xffffff) -- primary
    term.setPaletteColour(colors.magenta, 0xffffff) -- secondary
    term.setPaletteColour(colors.lightBlue, 0xffffff) -- tertiary
    term.setPaletteColour(colors.yellow, 0xffffff) -- highlight
    term.setPaletteColour(colors.lime, 0xffffff) -- subtle
    term.setPaletteColour(colors.pink, 0xffffff) -- accent
    term.setPaletteColour(colors.cyan, 0xffffff) -- info
    term.setPaletteColour(colors.purple, 0xffffff) -- alert
    term.setPaletteColour(colors.blue, 0xffffff) -- emphasis
    term.setPaletteColour(colors.brown, 0xffffff) -- muted
    return 0
end

local function setTheme(theme)
    if not themes[theme] then
        _G.Logger:info("[themes] Theme not found! Using default theme")
        return 1
    end
    for i, color in ipairs(themes[theme]) do
        term.setPaletteColour(c[color[1]], tonumber(color[2], 16))
    end
    term.clear()
    return 0
end

local function getThemes()
    return themes
end

return {
    init = init,
    setTheme = setTheme,
    getThemes = getThemes,
    colors = c
}