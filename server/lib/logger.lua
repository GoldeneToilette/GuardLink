local Logger = {}
Logger.__index = Logger

function Logger.new(name, path)
    local self = setmetatable({}, Logger)
    local date = os.date("%Y-%m-%d")
    self.name = name or date
    self.dir = path
    self.path = self.dir .. "/" .. (name or date) .. ".log"
    self.debugPath = self.dir .. "/" .. "debug" .. ".log"
    
    _G.vfs:makeDir(self.dir)
    _G.vfs:newFile(self.path)
    _G.vfs:newFile(self.debugPath)
    return self
end

function Logger:log(message, type)
    type = type or "info"
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logMessage = string.format("[%s] [%s] %s\n", timestamp, type, message)

    if type == "debug" then
        _G.vfs:appendFile(self.debugPath, logMessage)
    else
        _G.vfs:appendFile(self.path, logMessage)
    end
end

function Logger:info(message) self:log(message, "info") end
function Logger:error(message) self:log(message, "error") end
function Logger:debug(message) self:log(message, "debug") end

function Logger:fatal(message, stackTrace)
    stackTrace = stackTrace or debug.traceback()
    self:log(message .. "\n" .. stackTrace, "fatal")
end

function Logger:clearLog() 
    _G.vfs:writeFile(self.path, "")
    _G.vfs:writeFile(self.debugPath, "")
end

return Logger