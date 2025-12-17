-- Logger utility file for... well logging. As of right now it does not support verbosity levels (maybe in the future)

local settingsManager = require("utils.settingsManager")

local Logger = {}
Logger.__index = Logger

-- creates the log directory if it doesnt exist
function Logger.initializeLogDirectory()
    local logDir = "/GuardLink/client/logs"
    if not fs.exists(logDir) then
        fs.makeDir(logDir)
    end
end

-- creates a new logger instance
function Logger.new(logFileName)
    Logger.initializeLogDirectory()
    local dateStr = os.date("%Y-%m-%d")

    -- if logFileName is provided, appends ".log" otherwise, use the date as the filename
    logFileName = (logFileName and logFileName .. ".log") or ("/GuardLink/client/logs/" .. dateStr .. ".log")
  
    local self = setmetatable({
        logFile = logFileName,
    }, Logger)
    
    return self
end


-- logs a message to file
function Logger:log(message, type)
    type = type or "info" -- default type is info
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logMessage = string.format("[%s] [%s] %s\n", timestamp, type, message)
    
    local file = fs.open(self.logFile, "a")
    if file then
        file.write(logMessage)
        file.close()
    else
        print("Error: Unable to open log file.")
    end
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
    if settingsManager.getSetting("debug") == true then
    self:log(message, "debug")
    end
end

-- clear the log file
function Logger:clearLog()
    local file = fs.open(self.logFile, "w")
    if file then
        file.write("")
        file.close()
    else
        print("Error: Unable to open log file for clearing.")
    end
end

return Logger