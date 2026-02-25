local configPath = "/GuardLink/server/config/"
local deflate = require("lib.LibDeflate")

local log

_G.requireC = function(path)
    if package.loaded[path] then return package.loaded[path] end
    if fs.exists(path) then
        local file = fs.open(path, "rb")
        local contents = file.readAll()
        file.close()
        if not contents then error("FAILED TO READ FILE: " .. path) end

        local decomp = deflate:DecompressDeflate(contents)
        if not decomp then error("Failed to decompress file: " .. path) end
        local env = {}
        for k,v in pairs(_G) do env[k] = v end
        env.require = require
        local module = load(decomp, "@"..path, "t", env)()
        
        package.loaded[path] = module
        return module
    end
    return false
end

local shutdown = requireC("/GuardLink/server/kernel/shutdown.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")
local taskmaster = requireC("/GuardLink/server/lib/TaskMaster.lua")()

local kernel = {}
kernel.modules = {}

kernel.processes = {}
kernel.tasks = {}

kernel.ctx = {
    services = {},
    configs = {}
}
kernel.cmds = {}

function kernel:addCommand(prefix, suffix, func)
    self.cmds[prefix .. "." .. suffix] = func
end

kernel:addCommand("kernel", "get_config", function(args) return kernel.ctx.configs[args] or nil end)
kernel:addCommand("kernel", "get_version", function() return kernel.ctx.configs["manifest"].version or nil end)
kernel:addCommand("kernel", "stop", function() taskmaster:stop() end)
kernel:addCommand("kernel", "pause_task", function(args) 
    if kernel.tasks[args or " "] then 
        kernel.tasks[args].active = false
        log:debug("Pausing task: ", args)
    end
end)
kernel:addCommand("kernel", "resume_task", function(args)
    if kernel.tasks[args] then
        kernel.tasks[args].active = true
        log:debug("Resuming task: ", args)
    end
end)
kernel:addCommand("kernel", "print_tasks", function()
    local str = {}
    for k,v in pairs(kernel.tasks) do
        table.insert(str, k)
    end
    return table.concat(str, " ")
end)
kernel:addCommand("kernel", "get_tasks", function() return kernel.tasks end)

function kernel:execute(cmd, args)
    return self.cmds[cmd](args)
end

function kernel:registerService(path)
    local module 
    utils.tryCatch(
        function()
            module = requireC(path)
        end, 
        function(err, stackTrace)
            log:fatal("Failed to load service: " .. err .. "\nStacktrace: " .. stackTrace)
            os.shutdown()
    end)
    if not module then error("Tried to load unknown service: " .. path) end
    if not module.name then error("Error: Missing service name!") end
    table.insert(self.modules, module)
end

function kernel:getModule(name)
    for i = 1, #self.modules do
        if self.modules[i].name == name then return self.modules[i] end
    end
    return nil
end

function kernel:getService(name)
    return self.ctx.services[name]
end

function kernel:initConfigs()
    local files = fs.list(configPath)
    for i = 1, #files do
        local key = files[i]:match("(.+)%..+")
        local ext = files[i]:match("%.([^%.]+)$")
        if self.ctx.configs[key] then error("Duplicate configs  found: " .. key ) end
        local file = fs.open(configPath .. files[i], "r")
        local contents = file.readAll()
        file.close()
        if ext == "lua" or ext == "conf" then
            self.ctx.configs[key] = textutils.unserialize(contents)
        elseif ext == "json" then
            self.ctx.configs[key] = textutils.unserializeJSON(contents)
        end
    end
end

function kernel:initServices()
     -- creates placeholders
    for _, v in ipairs(self.modules) do
        self.ctx.services[v.name] = {}
    end
    for _, v in ipairs(self.modules) do
        local instance = v.init(self.ctx)
        self.ctx.services[v.name] = instance

        if v.runtime then
            taskmaster:addTask(function() v.runtime(instance) end)
        end
        if v.tasks then
            local t = v.tasks(instance)
            for name,task in pairs(t) do
                self.tasks[name] = {interval = task[2], active=true, lastRun = 0}
                taskmaster:addTimer(task[2], function()
                    if self.tasks[name].active then
                        local ok, err = pcall(task[1], instance)
                        if not ok then log:error("Task "..name.." failed: "..tostring(err)) end
                        self.tasks[name].lastRun = os.epoch("utc")
                    end
                end)
            end
        end
        if v.shutdown then
            shutdown.register(function() v.shutdown(instance) end)
        end

        if v.api then
            for prefix,contents in pairs(v.api) do
                for suffix,func in pairs(contents) do
                    self:addCommand(prefix, suffix, function(args) return func(instance, args) end)
                end
            end
        end
    end
end

function kernel:run()
    log = self.ctx.services["logger"]:createInstance("kernel", {
        timestamp = true,
        level = self.ctx.configs["settings"].debug and "DEBUG" or "INFO",
        clear = true
    })
    log:debug("Starting processes and tasks...")
    utils.tryCatch(
    function()
        taskmaster:run()
        shutdown.executeCallbacks()
        term.clear()
        log:info("Kernel stopped cleanly")
    end, 
    function(err, stackTrace)
        log:debug("Process error: " .. err .. "\nStacktrace: " .. stackTrace)
        os.shutdown()
    end)
end

return kernel