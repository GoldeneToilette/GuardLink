local settingsFilePath = "/GuardLink/client/settings.json"
local settings = {}

-- Default settings
local defaultSettings = {
    theme = "default",
    volume = 50,
}

-- Initializes settings, creates the settings file if it doesnt exist and sets default values
function initializeSettings()
    if fs.exists(settingsFilePath) then
        loadSettings()
    else
        settings = defaultSettings
        saveSettings()
    end
end

-- Loads settings from the file
function loadSettings()
    local file = fs.open(settingsFilePath, "r")
    local contents = file.readAll()
    file.close()

    local success, parsed = pcall(textutils.unserializeJSON, contents)
    if success and parsed then
        settings = parsed
    else
        settings = defaultSettings
    end
end

-- Saves the current settings to the file
function saveSettings()
    local dir = fs.getDir(settingsFilePath)
    if not fs.exists(dir) then
        fs.makeDir(dir)
    end

    local file, err = fs.open(settingsFilePath, "w")
    if not file then
        error("Failed to open file for writing: " .. (err or "Unknown error"))
    end

    file.write(textutils.serializeJSON(settings))
    file.close()
end

-- Sets a setting value
function setSetting(key, value)
    settings[key] = value
    saveSettings()
end

-- Gets a setting value
function getSetting(key)
    return settings[key]
end

-- Resets settings to their default values
function resetSettings()
    settings = defaultSettings
    saveSettings()
end

return {
    initializeSettings = initializeSettings,
    setSetting = setSetting,
    getSetting = getSetting,
    resetSettings = resetSettings
}