local fileUtils = require("/GuardLink/server/utils/fileUtils")

local Logger = {}
Logger.__index = Logger

-- Creates the log directory if it doesnt exist
function Logger.initializeLogDirectory()
    local logDir = "/GuardLink/server/logs/"
    if not fs.exists(logDir) then
        fs.makeDir(logDir)
    end
end

-- Creates a new logger instance
function Logger.new(logFileName)
    Logger.initializeLogDirectory()
    local dateStr = os.date("%Y-%m-%d")

    logFileName = (logFileName and logFileName .. ".log") or ("/GuardLink/server/logs/" .. dateStr .. ".log")
  
    local self = setmetatable({
        logFile = logFileName,
    }, Logger)
    
    return self
end

-- Logs a message to the file
function Logger:log(message, type)
    type = type or "info" -- default type is info
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logMessage = string.format("[%s] [%s] %s\n", timestamp, type, message)

    fileUtils.appendToFile(self.logFile, logMessage)
end

-- Log info message
function Logger:info(message)
    self:log(message, "info")
end

-- Log error message
function Logger:error(message)
    self:log(message, "error")
end

-- Log fatal message
function Logger:fatal(message, stackTrace)
    stackTrace = stackTrace or debug.traceback()
    local fullMessage = message .. "\n" .. stackTrace
    self:log(fullMessage, "fatal")
end

-- Log debug message
function Logger:debug(message)
    self:log(message, "debug")
end

-- Clears the log file
function Logger:clearLog()
    fileUtils.writeFile(self.logFile, "")
end

return Logger
