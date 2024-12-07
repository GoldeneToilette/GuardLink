-- This script defines a few themes for the app
-- It changes the entire 16 color palette. There are system colors that are always the same
-- the other colors are up to the theme

local themes = {
    default = {
        {colors.orange, 0x3366CC}, -- primary (blue)
        {colors.magenta, 0x99B2F2}, -- secondary (light blue)
        {colors.lightBlue, 0xF0F0F0}, -- third (white)
        {colors.yellow, 0xF2B233}, -- highlight (yellow)
        {colors.lime, 0xD0D0D0}, -- subtle (darker white)
    },
    cyberpunk = {
        {colors.orange, 0x1D1D2C}, -- primary
        {colors.magenta, 0xA64DFF}, -- secondary
        {colors.lightBlue, 0x4A90E2}, -- third
        {colors.yellow, 0xFF4081}, -- highlight 
        {colors.lime, 0x3C7BB1},
    },
    darkmode = {
        {colors.orange, 0x121212},
        {colors.magenta, 0xB0BEC5},
        {colors.lightBlue, 0x333333},
        {colors.yellow, 0xBB86FC},
        {colors.lime, 0x222222},
    },
    sunset = {
        {colors.orange, 0x3D1C5D},
        {colors.magenta, 0xFF6F61},
        {colors.lightBlue, 0xFFD54F},
        {colors.yellow, 0xFF8A80},
        {colors.lime, 0xFFC107},
    },
    monochrome = {
        {colors.orange, 0x121212},
        {colors.magenta, 0x424242},
        {colors.lightBlue, 0xBDBDBD},
        {colors.yellow, 0xFFFFFF},
        {colors.lime, 0x9E9E9E},
    },
    royal = {
        {colors.orange, 0x1976D2},
        {colors.magenta, 0xFBC02D},
        {colors.lightBlue, 0xFFFFFF},
        {colors.yellow, 0x7bb5ff},
        {colors.lime, 0xE0E0E0},
    },
    autumn = {
        {colors.orange, 0x6E4B3A},
        {colors.magenta, 0xC75B35},
        {colors.lightBlue, 0xA89F91},
        {colors.yellow, 0xFFB74D},
        {colors.lime, 0x8D7A65},
    },
    emerald = {
        {colors.orange, 0x2E7D32},
        {colors.magenta, 0x388E3C},
        {colors.lightBlue, 0xC5E1A5},
        {colors.yellow, 0xFFD700},
        {colors.lime, 0xA5D6A7},
    }
}


-- takes the theme from the list and sets all the colors. Doesnt change system colors
function setTheme(theme)
    local selectedTheme = themes[theme]
    if not selectedTheme then
        _G.Logger:error("[themes] Theme not found! Using default theme")
        selectedTheme = themes["default"]
    end

    -- Apply the colors by changing palette for each element
    for i, colorPair in ipairs(selectedTheme) do
        term.setPaletteColour(colorPair[1], colorPair[2])
    end
    
    term.clear()  -- Clear the terminal to apply the changes
end

-- Sets system colors and placeholders for the themes
function initializePalette() 
    -- system colors, they are the same in all themes
    term.setPaletteColour(colors.red, 0xf42929) -- red
    term.setPaletteColour(colors.white, 0xffffff) -- white
    term.setPaletteColour(colors.black, 0x000000) -- black
    term.setPaletteColour(colors.green, 0x2ec120) -- green
    term.setPaletteColour(colors.lightGray, 0x999999) -- light gray
    term.setPaletteColour(colors.gray, 0x4C4C4C) -- gray

    -- rest of the colors, they are customizable. if none of the themes is set, they will appear all white
    term.setPaletteColour(colors.orange, 0xffffff) -- primary color
    term.setPaletteColour(colors.magenta, 0xffffff) -- secondary color
    term.setPaletteColour(colors.lightBlue, 0xffffff) -- third color
    term.setPaletteColour(colors.yellow, 0xffffff) -- highlight color
    term.setPaletteColour(colors.lime, 0xffffff) -- subtle color
    term.setPaletteColour(colors.pink, 0xffffff) 
    term.setPaletteColour(colors.cyan, 0xffffff) 
    term.setPaletteColour(colors.purple, 0xffffff) 
    term.setPaletteColour(colors.blue, 0xffffff) 
    term.setPaletteColour(colors.brown, 0xffffff) 
end

-- Initializes the palette with the colors from the selected theme
function initializePaletteWithTheme(theme)
    initializePalette()
    setTheme(theme)
end

function getThemes()
    return themes
end

return {
    initializePalette = initializePalette,
    setTheme = setTheme,
    initializePaletteWithTheme = initializePaletteWithTheme,
    getThemes = getThemes
}