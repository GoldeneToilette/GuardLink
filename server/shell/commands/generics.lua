local cmds = {}

cmds["cd"] = {
    desc = "Change directory. Works normally, or in a mounted partition if mount is active.",
    func = function(args, ctx)
        local kernel, cwd, mount = ctx.kernel, ctx.cwd, ctx.mount
        if not args[1] then return {str="No path provided", type="fail"} end
        local target = args[1]
        if target:sub(1,1) ~= "/" then
            target = (cwd .. "/" .. target):gsub("/+", "/"):gsub("/$", "") -- relative
        else
            target = target:gsub("/+", "/") -- absolute
        end
        if mount[1] then
            if not kernel:execute("vfs.exists_dir", target) then
                return {str="Invalid VFS path: "..target, type="fail"}
            end
        else
            if not fs.exists(target) then return {str="No such file or directory: "..target, type="fail"} end
            if not fs.isDir(target) then return {str="Not a directory: "..target, type="fail"} end
        end

        ctx.cwd = target
        return {str="", type="success"}
    end
}

cmds["ls"] = {
    desc = "List directory contents. Operates on mount if active.",
    func = function(args, ctx)
        local kernel, cwd, mount = ctx.kernel, ctx.cwd, ctx.mount

        local target = args[1]
        if not args[1] then target = ctx.cwd end
        if target:sub(1,1) ~= "/" then
            target = (cwd .. "/" .. target):gsub("/+", "/"):gsub("/$", "") -- relative
        else
            target = target:gsub("/+", "/") -- absolute
        end
        local contents = {}
        if mount[1] then
            contents = kernel:execute("vfs.list", target)
        else
            if not fs.exists(target) then
                return {str="No such file or directory: "..target, type="fail"}
            end
            if not fs.isDir(target) then
                return {str="Not a directory: "..target, type="fail"}
            end
            contents = fs.list(target)
        end
        if not contents or #contents == 0 then
            return {str="Directory is empty", type="info"}
        end
        table.sort(contents)
        return {str=contents, type="info"}
    end
}

cmds["theme"] = {
    desc = "Usage: theme <get/list>, theme <set> <name>",
    func = function(args, ctx)
        local kernel = ctx.kernel
        if not args[1] then return {str="Invalid command. Usage: theme <get/list>, theme <set> <name>", type="fail"} end
        if args[1] == "get" then
            return {str=kernel:execute("ui.get_theme"), type="success"}
        elseif args[1] == "set" then
            local success = kernel:execute("ui.set_theme", args[2] or "")
            if success ~= 0 then
                return {str="Theme not found", type="fail"}
            else
                return {str="", type="success"}
            end
        elseif args[1] == "list" then
            local l = kernel:execute("ui.get_themes")
            local tbl = {}
            for k,v in pairs(l) do
                table.insert(tbl, k)
            end
            return {str=table.concat(tbl, " "), type="success"}
        else
            return {str="Invalid command. Usage: theme <get>, theme <set> <name>", type="fail"}
        end
    end
}

cmds["pwd"] = {
    desc = "Show the current working directory",
    func = function(args, ctx)
        return {str=ctx.cwd, type="info"}
    end
}

cmds["history"] = {
    desc = "Show command history",
    func = function(args, ctx)
        return {str=ctx.history, type="info"}
    end
}

cmds["clear"] = {
    desc = "Clear the terminal output",
    func = function(args, ctx)
        term.clear()
        return {str="", type="success"}
    end
}

cmds["help"] = {
    func = function(args, ctx)
        local kernel, desc = ctx.kernel, ctx.descriptions
        local output = {}
        table.insert(output, "GuardLink " .. kernel:execute("kernel.get_version"))
        table.insert(output, "------------------------------------")
        for k,v in pairs(desc) do
            table.insert(output, string.format("[%s] %s", k, v))
        end
        table.insert(output, "------------------------------------")
        return {str=output, type="info"}
    end
}

cmds["exit"] = {
    desc = "Shuts the computer down",
    func = function(args, ctx)
        os.shutdown()
    end
}
cmds["shutdown"] = cmds["exit"]
cmds["terminate"] = cmds["exit"]

cmds["credits"] = {
    desc = "Lists everything that contributed to this project",
    func = function(args, ctx)
        local str = {}
        table.insert(str, "Contributors:")
        table.insert(str, "- glittershitter")
        table.insert(str, "Libraries:")
        table.insert(str, "- [RSA Key generator]")
        table.insert(str, "- [SHA256-Algorithm]")
        table.insert(str, "- [Basalt (UI Library)]")
        table.insert(str, "- [Simple XML-Parser for lua]")
        table.insert(str, "- [pixelbox]")
        table.insert(str, "- [AES Encrypt library]")
        table.insert(str, "- [LibDeflate]")
        table.insert(str, "For more information visit the Github repository")
        return {str=str, type="info"}
    end
}

cmds["mount"] = {
    desc = "Mount a specific partition. 'mount <name>'",
    func = function(args, ctx)
        local kernel, cwd = ctx.kernel, ctx.cwd
        if not args[1] then
            return ctx.mount[1] and {str=ctx.mount[2], type="info"} or {str="No mount", type="info"}
        end
        if kernel:execute("vfs.is_partition", args[1]) then
            ctx.cwd="/"..args[1] 
            ctx.mount={true, args[1]}
            return {str="Mounted /"..args[1], type="success"}
        else
            return {str="Partition not found", type="fail"}
        end
    end
}

cmds["unmount"] = {
    desc = "Unmount a partition",
    func = function(args, ctx)
        ctx.mount = {false, ""}
        ctx.cwd = "/"        
        return {str="", type="success"}
    end    
}
cmds["umount"] = cmds["unmount"]
return cmds