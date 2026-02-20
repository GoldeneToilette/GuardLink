local engine = {
    cwd = "/",
    cmds = {},
    history = {},
    cfg = {}
}
local kernel = require("kernel.kernel")
local log

function engine:loadCommands()
    for _, file in ipairs(fs.list("/GuardLink/server/shell/commands")) do
        local cmd = requireC("/GuardLink/server/shell/commands/" .. file)
        self.cmds[cmd.name] = cmd.run
    end
end

function engine:setup()
    self.cfg = kernel:execute("kernel.get_config", "shell_config")
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
        local output = fn(kernel, self.cwd, args, self.cmds)
        local msg = "Used command: " .. str .. "\nOutput: "
        if type(output.str) == "string" then
            log:info(msg .. output.str)
        else
            msg = msg .. table.concat(output.str, "\n")
            log:info(msg)
        end    
        if output.cwd then self.cwd = output.cwd end
        return output
    else
        log:info("Used unknown command: " .. cmd)
        return {str="Unknown command: "..cmd, type="fail"}
    end
end

return engine