local configPath = "/GuardLink/server/config/"
local deflate = require("lib.LibDeflate")

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

local taskManager = requireC("/GuardLink/server/kernel/taskManager.lua")
local shutdown = requireC("/GuardLink/server/kernel/shutdown.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")

local kernel = {}
kernel.modules = {}

kernel.ctx = {
    services = {},
    configs = {}
}
kernel.cmds = {}

function kernel:addCommand(prefix, suffix, func)
    self.cmds[prefix .. "." .. suffix] = func
end

kernel:addCommand("kernel", "get_config", function(args) return kernel.ctx.configs[args] or nil end)

function kernel:execute(cmd, args)
    return self.cmds[cmd](args)
end

function kernel:registerService(path)
    local module = requireC(path)
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

kernel.processes = {}
function kernel:initServices()
     -- creates placeholders
    for _, v in ipairs(self.modules) do
        self.ctx.services[v.name] = {}
    end
    for _, v in ipairs(self.modules) do
        local instance = v.init(self.ctx)
        self.ctx.services[v.name] = instance

        if v.runtime then
            table.insert(self.processes, function() v.runtime(instance) end)
        end
        if v.tasks then
            local tasks = v.tasks(instance)
            for name,task in pairs(tasks) do
                taskManager.add(task[1], task[2])
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
    table.insert(self.processes, taskManager.run)
    utils.tryCatch(
    function()
    parallel.waitForAll(table.unpack(self.processes))
    end, 
    function(err, stackTrace)
        os.shutdown()
    end)
end

return kernel