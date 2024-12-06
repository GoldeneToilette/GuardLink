local fileUtils = require("/GuardLink/server/utils/fileUtils")

local locationPath = "/GuardLink/server/gps/locations/"

local categories = {
    commercial = true,
    residential = true,
    government = true,
    industrial = true,
    recreational = true,
    infrastructure = true,
    religious = true
}

GpsManager = {}

local function isValidCategory(category)
    if not categories[category] then
        _G.logger:error("[gpsManager] Invalid category: " .. category)
        return false
    end
    return true
end

local function loadDataFromCategoryFile(category)
    local path = locationPath .. category .. ".json"
    if not fs.exists(path) then
        _G.logger:error("[gpsManager] No data file found for category: " .. category)
        return nil
    end

    local data = textutils.unserialize(fileUtils.readFile(path)) or {}
    return data
end

local function saveDataToCategoryFile(category, data)
    local path = locationPath .. category .. ".json"
    fileUtils.writeFile(path, textutils.serialize(data))
end

function GpsManager.initializeCategoryFiles()
    for category, _ in pairs(categories) do
        local path = locationPath .. category .. ".json"
        if not fs.exists(path) then
            _G.logger:info("[gpsManager] Initializing file for category: " .. category)
            fileUtils.writeFile(path, "{}")
        end
    end
end

function GpsManager.registerLocation(owner, name, coordinates, description, category)
    if not isValidCategory(category) then
        return false
    end

    local data = loadDataFromCategoryFile(category) or {}

    if data[name] then
        _G.logger:error("[gpsManager] Location with name '" .. name .. "' already exists in category: " .. category)
        return false
    end

    data[name] = {
        owner = owner,
        coordinates = coordinates,
        description = description
    }

    saveDataToCategoryFile(category, data)
    return true
end

function GpsManager.deleteLocation(category, name)
    if not isValidCategory(category) then
        return false
    end

    local data = loadDataFromCategoryFile(category)
    if not data or not data[name] then
        _G.logger:error("[gpsManager] Location with name '" .. name .. "' does not exist in category: " .. category)
        return false
    end

    data[name] = nil

    saveDataToCategoryFile(category, data)
    return true
end

function GpsManager.getLocationNamesByCategory(category)
    if not isValidCategory(category) then
        return nil
    end

    local data = loadDataFromCategoryFile(category)
    if not data then
        return {}
    end

    local locationNames = {}
    for name, _ in pairs(data) do
        table.insert(locationNames, name)
    end

    return locationNames
end

function GpsManager.getLocationDetails(category, name)
    if not isValidCategory(category) then
        return nil
    end

    local data = loadDataFromCategoryFile(category)
    if not data or not data[name] then
        _G.logger:error("[gpsManager] Location with name '" .. name .. "' does not exist in category: " .. category)
        return nil
    end

    return data[name]
end

return GpsManager
