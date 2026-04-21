local fileUtils = requireC("/GuardLink/server/lib/fileUtils.lua")

local VFS = {}
VFS.__index = VFS

local log

local errors = {
    "Failed to write to file: Path could not be found!",
    "Failed to write to file: Not enough space!",
    "Cannot delete partition folder: "
}

function VFS.new(diskManager)
    local self = setmetatable({}, VFS)
    self.diskManager = diskManager
    self.config = self.diskManager:getConfig()
    self.criticalWarningShown = false
    self.manifest = nil
    self.degraded = {}
    if self.config then
        for partitionName, entries in pairs(self.config) do
            for _, entry in ipairs(entries) do
                if not diskManager:getDisk(entry.disk) then
                    self.degraded[partitionName] = entry.disk
                    break
                end
            end
        end
    end
    return self
end

function VFS:getManifest()
    if not self.manifest then
        self.manifest = self.ctx.configs["vfs_manifest"] or {}
    end
    return self.manifest
end

function VFS:flushManifest()
    local f = fs.open("/GuardLink/server/config/vfs_manifest.json", "w")
    f.write(textutils.serializeJSON(self.manifest))
    f.close()
    self.ctx.configs["vfs_manifest"] = self.manifest
end

function VFS:isChunked(path)
    local _, partitionName = self:parsePath(path)
    local m = self:getManifest()
    return m[partitionName] ~= nil and m[partitionName][path] ~= nil
end

function VFS:deleteChunks(path)
    local _, partitionName, partition = self:parsePath(path)
    local m = self:getManifest()
    if m[partitionName] and m[partitionName][path] then
        for _, chunk in ipairs(m[partitionName][path]) do
            fileUtils.delete(self.diskManager:getDisk(chunk.disk).path .. "/" .. chunk.path)
        end
        m[partitionName][path] = nil
        if not next(m[partitionName]) then m[partitionName] = nil end
        self:flushManifest()
    else
        for _, d in ipairs(partition) do
            local diskInfo = self.diskManager:getDisk(d.disk)
            local idx = 0
            while true do
                local chunkPath = diskInfo.path .. "/" .. path .. "." .. idx
                if not fs.exists(chunkPath) then break end
                fs.delete(chunkPath)
                idx = idx + 1
            end
        end
    end
end

function VFS:splitAndWrite(path, data)
    local _, partitionName, partition = self:parsePath(path)
    local remaining = data
    local chunks = {}
    local idx = 0
    for _, d in ipairs(partition) do
        if #remaining == 0 then break end
        local diskInfo = self.diskManager:getDisk(d.disk)
        local avail = self:getCapacity(partitionName, d.disk) - fs.getSize(diskInfo.path .. "/" .. partitionName)
        if avail > 0 then
            local chunkData = remaining:sub(1, avail)
            remaining = remaining:sub(avail + 1)
            local chunkPath = path .. "." .. idx
            fileUtils.newFile(diskInfo.path .. "/" .. chunkPath)
            fileUtils.write(diskInfo.path .. "/" .. chunkPath, chunkData)
            table.insert(chunks, {disk = d.disk, path = chunkPath})
            idx = idx + 1
        end
    end
    if #remaining > 0 then
        for _, chunk in ipairs(chunks) do
            fileUtils.delete(self.diskManager:getDisk(chunk.disk).path .. "/" .. chunk.path)
        end
        return {2, errors[2]}
    end
    local m = self:getManifest()
    if not m[partitionName] then m[partitionName] = {} end
    m[partitionName][path] = chunks
    self:flushManifest()
    return {0}
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

function VFS:reloadConfig()
    self.config = self.diskManager:getConfig()
    self.degraded = {}
    if self.config then
        for partitionName, entries in pairs(self.config) do
            for _, entry in ipairs(entries) do
                if not self.diskManager:getDisk(entry.disk) then
                    self.degraded[partitionName] = entry.disk
                    break
                end
            end
        end
    end
end

function VFS:isPartition(partition)
    return self.config[partition] ~= nil
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
    if self:isChunked(path) then return true end
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

function VFS:getTotalCapacity(name)
    local capacity = 0
    if self.config[name] then
        for _, v in ipairs(self.config[name]) do
            capacity = capacity + v.bytes
        end
        return capacity
    end
    return nil
end

function VFS:writeFile(path, data)
    local _, partitionName, partition = self:parsePath(path)
    if self:isChunked(path) then
        self:deleteChunks(path)
        local bestDisk, maxAvail = nil, 0
        for _, d in ipairs(partition) do
            local diskInfo = self.diskManager:getDisk(d.disk)
            local avail = self:getCapacity(partitionName, d.disk) - fs.getSize(diskInfo.path .. "/" .. partitionName)
            if avail > maxAvail then maxAvail = avail; bestDisk = diskInfo end
        end
        if bestDisk and maxAvail >= #data then
            fileUtils.newFile(bestDisk.path .. "/" .. path)
            fileUtils.write(bestDisk.path .. "/" .. path, data)
            return {0}
        end
        return self:splitAndWrite(path, data)
    end
    local disk = self:existsFile(path)
    if not disk then return {1, errors[1]} end
    local usedBytes = fs.getSize(disk.path .. "/" .. partitionName)
    local fileSize = fs.getSize(disk.path .. "/" .. path)
    local capacity = self:getCapacity(partitionName, disk.label)
    if (usedBytes - fileSize) + #data <= capacity then
        fileUtils.write(disk.path .. "/" .. path, data)
        return {0}
    end
    fileUtils.delete(disk.path .. "/" .. path)
    return self:splitAndWrite(path, data)
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
    self:deleteChunks(path)
    local disk = self:existsFile(path)
    if disk and disk ~= true then return fileUtils.delete(disk.path .. "/" .. path) end
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
    if self:isChunked(path) then
        local _, partitionName = self:parsePath(path)
        local m = self:getManifest()
        local result = ""
        for _, chunk in ipairs(m[partitionName][path]) do
            result = result .. (fileUtils.read(self.diskManager:getDisk(chunk.disk).path .. "/" .. chunk.path) or "")
        end
        return result
    end
    local disk = self:existsFile(path)
    if not disk then return nil end
    return fileUtils.read(disk.path .. "/" .. path)
end

function VFS:appendFile(path, data)
    if self:isChunked(path) then
        local existing = self:readFile(path)
        self:deleteChunks(path)
        return self:splitAndWrite(path, existing .. data)
    end
    local disk = self:existsFile(path)
    if not disk then return {1, errors[1]} end
    local usedBytes = fs.getSize(disk.path .. "/" .. path)
    local _, partitionName, _ = self:parsePath(path)
    local capacity = self:getCapacity(partitionName, disk.label)
    if usedBytes + #data > capacity then
        local existing = fileUtils.read(disk.path .. "/" .. path)
        fileUtils.delete(disk.path .. "/" .. path)
        return self:splitAndWrite(path, existing .. data)
    end
    fileUtils.append(disk.path .. "/" .. path, data)
    return {0}
end

function VFS:listDir(path)
    local parts, partitionName, partition = self:parsePath(path)
    local results = {}
    local seen = {}
    local chunkNames = {}
    local m = self:getManifest()
    if m[partitionName] then
        for _, chunks in pairs(m[partitionName]) do
            for _, chunk in ipairs(chunks) do
                chunkNames[chunk.path:match("[^/]+$")] = true
            end
        end
    end
    for _, disk in ipairs(partition) do
        local diskInfo = self.diskManager:getDisk(disk.disk)
        local fullPath = diskInfo.path .. "/" .. path
        if fs.exists(fullPath) then
            for _, name in ipairs(fs.list(fullPath)) do
                if not seen[name] and not chunkNames[name] then
                    table.insert(results, name)
                    seen[name] = true
                end
            end
        end
    end
    return #results > 0 and results or nil
end

function VFS:getUsedBytes(name)
    local parts, partitionName, partition = self:parsePath(name)
    if not partition then return false end
    local total = 0
    for _, disk in ipairs(partition) do
        local diskInfo = self.diskManager:getDisk(disk.disk)
        local fullPath = diskInfo.path .. "/" .. name
        total = total + self:getCapacity(name, diskInfo.label) - fs.getFreeSpace(fullPath)
    end
    return total
end

function VFS:getFileSize(path)
    if self:isChunked(path) then
        local _, partitionName = self:parsePath(path)
        local m = self:getManifest()
        local total = 0
        for _, chunk in ipairs(m[partitionName][path]) do
            total = total + fs.getSize(self.diskManager:getDisk(chunk.disk).path .. "/" .. chunk.path)
        end
        return total
    end
    local disk = self:existsFile(path)
    if not disk then return nil end
    return fs.getSize(disk.path .. "/" .. path)
end

function VFS:healthCheck(ctx)
    if not log then
        log = ctx.services["logger"]:createInstance("vfs", {timestamp = true, level = "INFO", clear = false})
    end

    local health = ctx.configs["settings"].health
    local warn = health and health.warnThreshold or 0.8
    local crit = health and health.critThreshold or 0.95
    local issues = {}

    for partitionName, missingDisk in pairs(self.degraded) do
        local msg = "DEGRADED: partition '" .. partitionName .. "' missing disk '" .. missingDisk .. "'"
        log:error(msg)
        table.insert(issues, {partition = partitionName, level = "degraded"})
        ctx:execute("ui.popup", {title = "Disk Degraded", message = msg, type = "error", canClose = true})
    end

    for partitionName, _ in pairs(self.config) do
        local capacity = self:getTotalCapacity(partitionName)
        local used = self:getUsedBytes(partitionName)
        if capacity and capacity > 0 then
            local ratio = used / capacity
            if ratio >= crit then
                local msg = "CRITICAL: partition '" .. partitionName .. "' is " .. math.floor(ratio * 100) .. "% full"
                log:error(msg)
                table.insert(issues, {partition = partitionName, ratio = ratio, level = "critical"})
                if not self.criticalWarningShown then
                    ctx:execute("ui.popup", {title = "Disk Critical", message = msg, type = "error", canClose = true})
                    self.criticalWarningShown = true
                end
            elseif ratio >= warn then
                local msg = "WARNING: partition '" .. partitionName .. "' is " .. math.floor(ratio * 100) .. "% full"
                log:info(msg)
                table.insert(issues, {partition = partitionName, ratio = ratio, level = "warning"})
            end
        end
    end
    return issues
end

local service = {
    name = "vfs",
    deps = {"disk_manager"},
    init = function(ctx)
        local instance = VFS.new(ctx.services["disk_manager"])
        instance.ctx = ctx
        return instance
    end,
    runtime = nil,
    tasks = function(self)
        local interval = self.ctx.configs["settings"].health and self.ctx.configs["settings"].health.interval or 60
        return {
            vfs_health_check = {function(self) self:healthCheck(self.ctx) end, interval}
        }
    end,
    shutdown = nil,
    api = {
        ["vfs"] = {
            read = function(self, args) return self:readFile(args) end,
            write = function(self, args) return self:writeFile(args.path, args.data) end,
            append = function(self, args) return self:appendFile(args.path, args.data) end,
            new = function(self, args) return self:newFile(args) end,
            delete = function(self, args) return self:deleteFile(args) end,
            delete_dir = function(self, args) return self:deleteDir(args) end,
            mkdir = function(self, args) return self:makeDir(args) end,
            list = function(self, args) return self:listDir(args) end,
            exists_file = function(self, args) return self:existsFile(args) ~= false end,
            exists_dir = function(self, args) return self:existsDir(args) end,
            is_partition = function(self, args) return self:isPartition(args) end,
            get_config = function(self, args) return self.config end,
            get_capacity = function(self, args) return self:getTotalCapacity(args) end,
            get_size = function(self, args) return self:getUsedBytes(args) end,
            get_file_size = function(self, args) return self:getFileSize(args) end,
            health_check = function(self) return self:healthCheck(self.ctx) end,
            reload_config = function(self) return self:reloadConfig() end,
        }
    }
}

return service
