local cmds = {}

cmds["cd"] = {
    desc = "Change directory. '-' goes up, '.' goes to root. Respects mount if active.",
    func = function(args, ctx)
        local kernel, cwd, mount = ctx.kernel, ctx.cwd, ctx.mount
        if not args[1] then return {str="No path provided", type="fail"} end
        local target = args[1]
        if target == "-" then
            local parts = {}
            for part in string.gmatch(cwd, "[^/]+") do
                table.insert(parts, part)
            end
            table.remove(parts)
            target = "/" .. table.concat(parts, "/")
            if target == "" then target = "/" end
        elseif target == "." then
            target = mount[1] and "/"..mount[2] or "/"
        else
            if target:sub(1,1) ~= "/" then
                target = (cwd .. "/" .. target):gsub("/+", "/"):gsub("/$", "")
            else
                target = target:gsub("/+", "/")
            end
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
            local success = kernel:execute("ui.set_theme", {theme=args[2] or ""})
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
        elseif args[1] == "print" then
            return {str="\16700AAA\16711AAA\16722AAA\16733AAA\16744AAA\16755AAA\16766AAA\16777AAA\16788AAA\16799AAA", type="success"}
        else
            return {str="Invalid command. Usage: theme <get>, theme <set> <name>", type="fail"}
        end
    end
}

cmds["setcolor"] = {
    desc = "Change the colors. Usage: setcolor <type> <hexcode>",
    func = function(args, ctx)
        local colorType = args[1]
        local hex = args[2]
        if not colorType or not hex then
            return {str="Usage: setcolor <type> <hexcode>", type="error"}
        end
        ctx.kernel:execute("ui.set_color", {type=colorType, hex=hex, current=term.current()})
        return {str="", type="success"}
    end
}
cmds["listcolor"] = {
    desc = "Lists all color codes",
    func = function(args, ctx)
        return {str=ctx.kernel:execute("ui.list_colors"), type="success"}
    end
}
cmds["sc"] = cmds["setcolor"]
cmds["sc"].desc = nil
cmds["lc"] = cmds["listcolor"]
cmds["lc"].desc = nil

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
        local keys = {}
        for k in pairs(desc) do
            table.insert(keys, k)
        end
        table.sort(keys)
        for _, k in ipairs(keys) do
            table.insert(output, string.format("[%s] %s", k, desc[k]))
        end
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
cmds["shutdown"].desc = nil
cmds["terminate"].desc = nil

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
cmds["umount"].desc = nil

cmds["lsblk"] = {
    desc = "Displays information about partitions",
    func = function(args, ctx)
        local kernel = ctx.kernel
        local str = {}
        for k,v in pairs(kernel:execute("vfs.get_config")) do
            local size = math.floor(((kernel:execute("vfs.get_size", k) / 1024) * 100 + 0.5) / 100)
            local cap = math.floor(((kernel:execute("vfs.get_capacity", k) / 1024) * 100 + 0.5) / 100)
            table.insert(str, "[" .. k .. "] = " .. (size or "nil") .. "KB of " .. (cap or "nil") .. "KB")
        end
        return {str = str, type = "success"}
    end
}

cmds["cat"] = {
    desc = "Display file contents",
    func = function(args, ctx)
        local kernel, cwd, mount = ctx.kernel, ctx.cwd, ctx.mount
        if not args[1] then return {str="No file provided", type="fail"} end
        local target = args[1]
        if target:sub(1,1) ~= "/" then
            target = (cwd .. "/" .. target):gsub("/+","/"):gsub("/$","")
        end
        if mount[1] then
            if not kernel:execute("vfs.exists_file", target) then
                return {str="File not found: "..target, type="fail"}
            end
            return {str=kernel:execute("vfs.read", target), type="info"}
        else
            if not fs.exists(target) or fs.isDir(target) then
                return {str="File not found: "..target, type="fail"}
            end
            local f = fs.open(target, "r")
            local data = f.readAll()
            f.close()
            return {str=data, type="info"}
        end
    end
}

cmds["touch"] = {
    desc = "Create an empty file",
    func = function(args, ctx)
        local kernel, cwd, mount = ctx.kernel, ctx.cwd, ctx.mount
        if not args[1] then return {str="No file provided", type="fail"} end

        local target = args[1]
        if target:sub(1,1) ~= "/" then
            target = (cwd .. "/" .. target):gsub("/+","/")
        end

        if mount[1] then
            local ok = kernel:execute("vfs.new", target)
            return ok and {str="", type="success"} or {str="Failed to create file", type="fail"}
        else
            local f = fs.open(target, "a")
            if not f then return {str="Failed to create file", type="fail"} end
            f.close()
            return {str="", type="success"}
        end
    end
}

cmds["mkdir"] = {
    desc = "Create directory",
    func = function(args, ctx)
        local kernel, cwd, mount = ctx.kernel, ctx.cwd, ctx.mount
        if not args[1] then return {str="No directory provided", type="fail"} end
        local target = args[1]
        if target:sub(1,1) ~= "/" then
            target = (cwd .. "/" .. target):gsub("/+","/")
        end
        if mount[1] then
            kernel:execute("vfs.mkdir", target)
        else
            fs.makeDir(target)
        end
        return {str="", type="success"}
    end
}

cmds["rm"] = {
    desc = "Remove a file or directory",
    func = function(args, ctx)
        local kernel, cwd, mount = ctx.kernel, ctx.cwd, ctx.mount
        if not args[1] then return {str="No path provided", type="fail"} end
        local target = args[1]
        local force_root = args[2]
        if target:sub(1,1) ~= "/" then
            target = (cwd .. "/" .. target):gsub("/+","/")
        end
        if target == "/" and force_root ~= "true" then
            return {str="Refusing to delete root directory without force flag", type="fail"}
        end
        if mount[1] then
            if kernel:execute("vfs.exists_dir", target) then
                kernel:execute("vfs.delete_dir", target)
            else
                kernel:execute("vfs.delete", target)
            end
        else
            if fs.exists(target) then fs.delete(target) end
        end

        return {str="", type="success"}
    end
}

cmds["cp"] = {
    desc = "Copy file",
    func = function(args, ctx)
        local kernel, cwd, mount = ctx.kernel, ctx.cwd, ctx.mount
        if not args[1] or not args[2] then
            return {str="Usage: cp <src> <dst>", type="fail"}
        end
        local function resolve(p)
            if p:sub(1,1) ~= "/" then
                return (cwd .. "/" .. p):gsub("/+","/")
            end
            return p
        end
        local src = resolve(args[1])
        local dst = resolve(args[2])
        if mount[1] then
            local data = kernel:execute("vfs.read", src)
            if not data then return {str="Source not found", type="fail"} end
            kernel:execute("vfs.new", dst)
            kernel:execute("vfs.write", {path=dst, data=data})
        else
            if not fs.exists(src) then return {str="Source not found", type="fail"} end
            fs.copy(src, dst)
        end
        return {str="", type="success"}
    end
}

cmds["mv"] = {
    desc = "Move or rename a file",
    func = function(args, ctx)
        if not args[1] or not args[2] then
            return {str="Usage: mv <src> <dst>", type="fail"}
        end
        cmds["cp"].func(args, ctx)
        cmds["rm"].func({args[1]}, ctx)
        return {str="", type="success"}
    end
}

cmds["tree"] = {
    desc = "Recursive directory view",
    func = function(args, ctx)
        local kernel, cwd, mount = ctx.kernel, ctx.cwd, ctx.mount
        local base = args[1] or cwd
        local function resolve(p)
            if p:sub(1,1) ~= "/" then
                return (cwd .. "/" .. p):gsub("/+","/")
            end
            return p
        end
        base = resolve(base)
        local output = {}
        local function walk(path, prefix)
            local list = mount[1]
                and kernel:execute("vfs.list", path)
                or fs.list(path)

            if not list then return end
            table.sort(list)
            for _, name in ipairs(list) do
                local full = path .. "/" .. name
                table.insert(output, prefix .. name)
                local isDir = mount[1]
                    and kernel:execute("vfs.exists_dir", full)
                    or fs.isDir(full)
                if isDir then
                    walk(full, prefix .. "  ")
                end
            end
        end
        walk(base, "")
        return {str=output, type="info"}
    end
}

cmds["date"] = {
    desc = "Show current date and time",
    func = function()
        return {
            str = os.date("%Y-%m-%d %H:%M:%S", os.epoch("utc")/1000),
            type="info"
        }
    end
}

cmds["echo"] = {
    desc = "Print text",
    func = function(args)
        return {str=table.concat(args, " "), type="info"}
    end
}

return cmds