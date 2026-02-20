local engine = {
    cwd = "/",
    cmds = {},
    history = {},
    cfg = {},
    mount = {false, ""},
    descriptions = {}
}
local kernel = require("kernel.kernel")
engine.kernel = kernel
local log

function engine:loadCommands()
    for _, file in ipairs(fs.list("/GuardLink/server/shell/commands")) do
        local cmd = requireC("/GuardLink/server/shell/commands/" .. file)
        if file ~= "generics.lua" then
            self.cmds[cmd.name] = cmd.run
            for k,v in pairs(cmd) do
                if type(v) == "table" and v.desc then
                    self.descriptions[cmd.name .. " " .. k] = v.desc
                end
            end
        else
            for k,v in pairs(cmd) do
                self.cmds[k] = v.func
                if v.desc then
                    self.descriptions[k] = v.desc
                end
            end
        end
        
    end
end

function engine:setup()
    self.cfg = kernel:execute("kernel.get_config", "shell_config")
    self.mount = {false, ""}
    if self.cfg.default_dir then self.cwd = self.cfg.default_dir end
    if self.cfg.history_length then self.history_length = self.cfg.history_length
    else self.history_length = 20 end

    log = kernel:execute("log.create", {
        name = "shell",
        settings = {
            fileName = "shell",
            timestamp = true,
            level = self.cfg.logging or "FATAL",
            clear = true
        }
    })
    self:loadCommands()
end

function engine:run(str)
    local args = {}
    for token in str:gmatch("%S+") do
        table.insert(args, token)
    end
    local cmd = table.remove(args,1)
    if not cmd or cmd == "" then return {str="", type="empty"} end
    local fn = self.cmds[cmd]
    table.insert(self.history, str)
    if #self.history > self.history_length then table.remove(self.history, 1) end

    if fn then
        local ok, output = pcall(fn, args, self)
        if not ok then
            log:debug("Command error: " .. tostring(output))
            return {str="Command failed: " .. tostring(output), type="fail"}
        end
        local msg = "Used command: " .. str .. "\nOutput: "
        if type(output.str) == "string" then
            log:debug(msg .. output.str)
        else
            msg = msg .. table.concat(output.str, "\n")
            log:debug(msg)
        end    
        return output
    else
        log:debug("Used unknown command: " .. cmd)
        return {str="Unknown command: "..cmd, type="fail"}
    end
end

return engine