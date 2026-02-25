local cmds = {}
cmds.name = "tasks"

cmds["list"] = {
    desc = "Prints all registered tasks",
    func = function(args, ctx)
        return {str=ctx.kernel:execute("kernel.print_tasks"),type="info"}
    end
}

cmds["info"] = {
    desc = "Shows detailed information about a task",
    func = function(args, ctx)
        local tasks = ctx.kernel:execute("kernel.get_tasks")
        if not args[2] or type(args[2]) ~= "string" or not tasks[args[2]] then
            return {str="Unknown task", type="fail"}
        end
        local tbl = {}
        table.insert(tbl, "Task: " .. args[2])
        table.insert(tbl, "Interval: " .. tasks[args[2]].interval)
        local lastRun = tostring(tasks[args[2]].lastRun > 0 and math.floor((tasks[args[2]].lastRun - os.epoch("utc")) / 1000)) or " nil"
        table.insert(tbl, "Last run: " .. lastRun:sub(2, #lastRun) .. " seconds ago")
        table.insert(tbl, "Active: " .. tostring(tasks[args[2]].active))
        return {str=tbl, type="info"}
    end
}

cmds["help"] = {
    func = function(args, ctx)
        local output = {"Task commands -------------------------"}
        for k,v in pairs(cmds) do
            if type(v) == "table" and v.desc then
                table.insert(output, k .. ": \16706" .. v.desc)             
            end
        end
        table.insert(output, "Task commands -------------------------")
        return {str=output, type="info"}
    end
}

function cmds.run(args, ctx)
    if not args[1] or args[1] == "" then return {str=ctx.kernel:execute("kernel.print_tasks"),type="info"} end
    if not cmds[args[1]] then return {str="Unknown command: clients " .. args[1], type="fail"} end
    return cmds[args[1]].func(args, ctx)
end

return cmds