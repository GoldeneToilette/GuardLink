local fileUtils

local diskManager = {}
diskManager.__index = diskManager

--[[
example table
local partitions = {
    whitelist = {"GLB_1", "GLB_2", "GLB_3"},
    layout = {
        {name = "accounts", percentage = 50},
        {name = "logs",        percentage = 25},
        {name = "cache",       percentage = 5},
    }
}
]]

local errors = {
    "Disk could not be found: ",
    "Disk already partitioned: ",
    "Percentages dont add up to 100: "
}

function diskManager.new(configPath, labelPrefix, futil)
    local self = setmetatable({}, diskManager)
    self.disks = {}
    self.capacity = 0
    self.freeSpace = 0
    self.configPath = configPath or "/GuardLink/server/config/partitions.json"
    self.labelPrefix = labelPrefix or "DISK"

    fileUtils = futil or require("lib.fileUtils")
    return self
end

function diskManager:getConfig()
    return textutils.unserializeJSON(fileUtils.read(self.configPath))
end

function diskManager:getDisks()
    return self.disks
end

function diskManager:diskCount()
    local i = 0
    for _,_ in pairs(self.disks) do
        i = i+1
    end
    return i
end

function diskManager:disksToString()
    local disks = self:getDisks()
    local result = "Disks: ["
    for k, v in pairs(disks) do
        result = result .. ", " .. k 
    end
    return result .. "]"
end

function diskManager:getDisk(label)
    return self.disks[label]
end

function diskManager:getDiskLabels()
    local tbl = {}
    for _,v in pairs(self.disks) do
        table.insert(tbl, v.label)
    end
    return tbl
end

function diskManager:clearDisk(label)
    local disk = self.disks[label]
    if not disk then return {1, errors[1] .. label} end

    for _, file in ipairs(fs.list(disk.path)) do
        fs.delete(disk.path .. "/" .. file)
    end
    return {0}
end

function diskManager:generateLabel()
    local index = 1
    local newLabel
    repeat
        newLabel = self.labelPrefix .. "_" .. index
        index = index + 1
    until not self.disks[newLabel]

    return newLabel
end

function diskManager:scan()
    self.disks = {}
    self.capacity = 0
    self.freeSpace = 0
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "drive" and disk.isPresent(name) then
            local path = disk.getMountPath(name)
            local label = disk.getLabel(name)
            if not label then 
                label = self:generateLabel()
                disk.setLabel(name, label)
            end
            self.disks[label] = {
                path = path,
                peripheral = name,
                freeSpace = fs.getFreeSpace(path),
                capacity = fs.getCapacity(path),
                label = label
            } 
            self.capacity = self.capacity + fs.getCapacity(path)
            self.freeSpace = self.freeSpace + fs.getFreeSpace(path)
        end
    end
    return {0}
end

function diskManager:validateLayout(partitions)
    local config
    if fs.exists(self.configPath) then
        config = textutils.unserializeJSON(fileUtils.read(self.configPath))
    else
        config = {}
    end

    local usedDisks = {}
    for _, v in pairs(config) do
        for _, e in ipairs(v) do
            if e.disk then usedDisks[e.disk] = true end
        end
    end

    for _, label in ipairs(partitions.whitelist) do
        if not self.disks[label] then return {1, errors[1] .. label} end 
        if usedDisks[label] then return {2, errors[2] .. label} end
    end

    local totalPercentage = 0
    for _, v in ipairs(partitions.layout) do
        if v.percentage <= 0 then return {3, errors[3] .. totalPercentage} end
        totalPercentage = totalPercentage + v.percentage
    end
    if totalPercentage ~= 100 then return {3, errors[3] .. totalPercentage} end
    
    -- no errors good job
    return {0}
end

function diskManager:updateDisk(label)
    local d = self.disks[label]
    if not d then return {1, errors[1] .. label} end

    d.path = disk.getMountPath(d.peripheral)
    d.freeSpace = fs.getFreeSpace(d.path)
    d.capacity = fs.getCapacity(d.path)

    self.capacity = 0
    self.freeSpace = 0
    for _, v in pairs(self.disks) do
        self.capacity = self.capacity + v.capacity
        self.freeSpace = self.freeSpace + v.freeSpace
    end
    return {0}
end

local function copyTable(tbl)
    local new = {whitelist = {}, layout = {} }
    for _, v in ipairs(tbl.whitelist) do
        table.insert(new.whitelist, v)
    end

    for _, v in ipairs(tbl.layout) do
        table.insert(new.layout, {name = v.name, percentage = v.percentage})
    end

    return new
end

function diskManager:partition(partitions)
    if next(self.disks) == nil then
        error("Cant create partitions, no disks were found! Use scan() first")
    end

    local result = self:validateLayout(partitions)
    if result[1] ~= 0 then error(result[2]) end

    local partitions = copyTable(partitions)

    local firstLabel = next(self.disks)
    local capacity = fs.getCapacity(self.disks[firstLabel].path) or 125000

    for _, label in ipairs(partitions.whitelist) do
        self:clearDisk(label)
    end

    local config
    if fs.exists(self.configPath) then
        config = textutils.unserializeJSON(fileUtils.read(self.configPath)) or {}
    else
        config = {}
    end

    for _, part in ipairs(partitions.layout) do
        config[part.name] = config[part.name] or {}
        part.bytes = math.floor(#partitions.whitelist * capacity * (part.percentage / 100))
    end

    local diskIndex = 1
    local diskList = partitions.whitelist
    for _, part in ipairs(partitions.layout) do
        local remainingPartition = part.bytes
        while remainingPartition > 0 and diskIndex <= #diskList do
            local label = diskList[diskIndex]
            local d = self.disks[label]
            local remainingDisk = capacity - (d.usedBytes or 0)
            local bytesToWrite = math.min(remainingPartition, remainingDisk)

            table.insert(config[part.name], {disk = label, bytes = bytesToWrite, percentage = (bytesToWrite / capacity) * 100})

            d.usedBytes = (d.usedBytes or 0) + bytesToWrite
            remainingPartition = remainingPartition - bytesToWrite

            if d.usedBytes >= capacity then
                diskIndex = diskIndex + 1
            end
        end
    end

    for _, label in ipairs(partitions.whitelist) do
        local d = self.disks[label]
        for name, list in pairs(config) do
            for _, e in ipairs(list) do
                if e.disk == label then
                    fs.makeDir(d.path .. "/" .. name)
                end
            end
        end
        fs.makeDir(d.path .. "/.cache")
        d.usedBytes = nil
    end

    local json = textutils.serializeJSON(config)
    fileUtils.newFile(self.configPath)
    return fileUtils.write(self.configPath, json)
end

return diskManager