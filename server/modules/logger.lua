local Logger = {}
Logger.__index = Logger

local LEVELS = {
    DEBUG = 1,
    INFO = 2,
    ERROR = 3,
    FATAL = 4
}

function Logger.new(vfs)
    local self = setmetatable({}, Logger)
    self.baseDir = "logs"
    self.vfs = vfs
    self.vfs:makeDir(self.baseDir)
    self.cleared = {}
    return self
end

function Logger:createInstance(name, settings)
    settings = settings or {}
    local instance = {
        name = name,
        dir = settings.dir and (self.baseDir .. "/" .. settings.dir) or self.baseDir,
        fileName = settings.fileName or "latest",
        timestamp = settings.timestamp ~= false,
        level = (settings.level or "INFO"):upper(),
        vfs = self.vfs,
        clear = settings.clear or false -- if it should be cleared when created, ONLY HAPPENS ONCE
    }
    instance.path = instance.dir .. "/" .. instance.fileName .. ".log"
    self.vfs:makeDir(instance.dir)
    self.vfs:newFile(instance.path)
    if instance.clear then
        if not self.cleared[name] then
            self.vfs:writeFile(instance.path, "")     
            self.cleared[name] = true
        end
    end
    return setmetatable(instance, { __index = Logger.Instance })    
end

Logger.Instance = {}

function Logger.Instance:_write(level, message)
    if not LEVELS[level] or LEVELS[level] < LEVELS[self.level] then return end
    local line
    if self.timestamp then
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        line = string.format("[%s] [%s] [%s] %s\n", timestamp, self.name, level, message)
    else
        line = string.format("[%s] [%s] %s\n", self.name, level, message)
    end
    self.vfs:appendFile(self.path, line)
end

function Logger.Instance:info(msg)
    self:_write("INFO", msg)
end

function Logger.Instance:error(msg)
    self:_write("ERROR", msg)
end

function Logger.Instance:debug(msg)
    self:_write("DEBUG", msg)
end

function Logger.Instance:fatal(msg)
    local trace = debug.traceback()
    self:_write("FATAL", msg .. "\n" .. trace)
end

function Logger.Instance:clear()
    self.vfs:writeFile(self.path, "")
end

local service = {
    name = "logger",
    deps = {"vfs"},
    init = function(ctx)
        return Logger.new(ctx.services["vfs"])
    end,
    runtime = nil,
    tasks = nil,
    shutdown = nil,
    api = {
        ["log"] = {
            create = function(self, args) return self:createInstance(args.name, args.settings) end
        }
    }
}

return service