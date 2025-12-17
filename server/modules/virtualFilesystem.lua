local fileUtils = require "lib.fileUtils"

local VFS = {}
VFS.__index = VFS

local errors = {
    "Failed to write to file: Path could not be found!",
    "Failed to write to file: file size too big!",
    "Cannot delete partition folder: "
}

function VFS.new(diskManager)
    local self = setmetatable({}, VFS)
    self.diskManager = diskManager
    self.config = self.diskManager:getConfig()
    return self
end

function VFS:parsePath(path)
    local parts = {}
    path = path:gsub("//+", "/"):gsub("/$", "")
    for v in string.gmatch(path, "[^/]+") do
        table.insert(parts, v)
    end
    local partitionName = parts[1]

    local partition = self.config[partitionName]
    if not partition then error("Failed to read path, partition not found: " .. partitionName) end    
    return parts, partitionName, partition
end

function VFS:makeDir(path)
    local _, _, partition = self:parsePath(path)

    for _, disk in ipairs(partition) do
        local diskPath = self.diskManager:getDisks()[disk.disk].path
        fileUtils.makeDir(diskPath .. "/" .. path)
    end
    return true
end

function VFS:existsFile(path)
    local parts, _, partition = self:parsePath(path)
    for _, disk in ipairs(partition) do
        local diskInfo = self.diskManager:getDisk(disk.disk)
        local fullPath = diskInfo.path .. "/" .. table.concat(parts, "/")
        if fs.exists(fullPath) then return diskInfo end
    end
    return false
end

function VFS:existsDir(path)
    local parts, _, partition = self:parsePath(path)
    for _, disk in ipairs(partition) do
        local diskInfo = self.diskManager:getDisk(disk.disk)
        local fullPath = diskInfo.path .. "/" .. table.concat(parts, "/")
        if fs.exists(fullPath) and fs.isDir(fullPath) then
            return true
        end
    end
    return false  
end

function VFS:getCapacity(partitionName, disk)
    for _, v in ipairs(self.config[partitionName]) do
        if v.disk == disk then
            return v.bytes
        end
    end
end

function VFS:writeFile(path, data)
    local _, partitionName, _ = self:parsePath(path)
    local disk = self:existsFile(path)
    if not disk then return {1, errors[1]} end 

    local usedBytes = fs.getSize(disk.path .. "/" .. partitionName)
    local capacity = self:getCapacity(partitionName, disk.label)
    if usedBytes + #data > capacity then return {2, errors[2]} end

    fileUtils.write(disk.path .. "/" .. path, data)
    return {0}
end

function VFS:newFile(path)
    if not self:existsFile(path) then
        local _, name, partition = self:parsePath(path)
        local chosenDisk = nil
        local maxFree = 0

        for _, disk in ipairs(partition) do
            local diskInfo = self.diskManager:getDisk(disk.disk)
            local usedBytes = fs.getSize(diskInfo.path .. "/" .. name)
            local available = self:getCapacity(name, disk.disk) - usedBytes
            if available > maxFree then
                maxFree = available
                chosenDisk = diskInfo
            end
        end

        if not chosenDisk or maxFree <= 0 then return false end
        return fileUtils.newFile(chosenDisk.path .. "/" .. path)
    end
    return false
end

function VFS:deleteFile(path)
    local disk = self:existsFile(path)
    if disk then return fileUtils.delete(disk.path .. "/" .. path) end
end

function VFS:deleteDir(path)
    local parts, partitionName, partition = self:parsePath(path)
    if #parts == 1 then error(errors[3] .. partitionName .. "!") end
 
    local success = true
    for _, disk in ipairs(partition) do
        local diskInfo = self.diskManager:getDisk(disk.disk)
        local fullPath = diskInfo.path .. "/" .. path
        if fs.exists(fullPath) then
            local s = fileUtils.delete(fullPath)
            if not s then success = false end
        end
    end
    return success
end

function VFS:readFile(path)
    local disk = self:existsFile(path)
    if not disk then return nil end
    return fileUtils.read(disk.path .. "/" .. path)
end

function VFS:appendFile(path, data)
    local disk = self:existsFile(path)
    if not disk then return {1, errors[1]} end    

    local usedBytes = fs.getSize(disk.path .. "/" .. path)
    local _, partitionName, _ = self:parsePath(path)
    local capacity = self:getCapacity(partitionName, disk.label)

    if usedBytes + #data > capacity then return {2, errors[2]} end
    fileUtils.append(disk.path .. "/" .. path, data)

    return {0}    
end

function VFS:listDir(path)
    local parts, partitionName, partition = self:parsePath(path)
    local results = {}
    for _, disk in ipairs(partition) do
        local diskInfo = self.diskManager:getDisk(disk.disk)
        local fullPath = diskInfo.path .. "/" .. path
        if fs.exists(fullPath) then 
            for _, name in ipairs(fs.list(fullPath)) do
                table.insert(results, name)
            end
        end
    end
    return #results > 0 and results or nil
end

return VFS
