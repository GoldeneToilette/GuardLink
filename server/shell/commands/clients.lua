local cmds = {}
cmds.name = "clients"

cmds["list"] = {
    desc = "Show a list of all active clients",
    func = function(args, ctx)
        return {str = table.concat(ctx.kernel:execute("clients.list"), " "), type="success"}
    end
}

cmds["info"] = {
    desc = "Show detailed information about a client. Usage: clients info <ID>",
    func = function(args, ctx)
        local client = ctx.kernel:execute("clients.get", args[2] or "")
        if client then 
            local str = {}
            table.insert(str, "ID: " .. client.id)
            table.insert(str, "Connected At: " .. client.connectedAt)
            table.insert(str, "Last Activity: " .. os.date("%Y-%m-%d %H:%M:%S", client.lastActivityTime / 1000))
            table.insert(str, "Throttle: " .. client.throttle)
            table.insert(str, "Logged into: " .. client.account)
            table.insert(str, "Channel: " .. client.channel)
            table.insert(str, "Sleepy: " .. client.sleepy)
            return {str=str, type="success"}
        else
            return {str="Error: Client not found"} 
        end        
    end
}

cmds["count"] = {
    desc = "Show how many clients are currently connected",
    func = function(args, ctx)
        return {str="There are currently " .. ctx.kernel:execute("clients.count") .. " connected clients", type="success"}
    end
}

cmds["disconnect"] = {
    desc = "Disconnect a client by ID. Usage: clients disconnect <ID> <REASON>",
    func = function(args, ctx)
        local client, reason = args[2] or "", args[3]
        local success = ctx.kernel:execute("clients.disconnect", {id=client,reason=reason})
        if success ~= 0 then
            return {str="Error: " .. success.log, type="fail"}
        end
        return{str="Client " .. client .. " has been disconnected for '" .. reason .. "'", type="success"}
    end
}
cmds["dc"] = cmds.disconnect
cmds["dc"].desc = nil

cmds["disconnectall"] = {
    desc = "Disconnect all clients. Usage: disconnectall <REASON>",
    func = function(args, ctx)
        local count = ctx.kernel:execute("clients.disconnect_all", args[2])
        return{str="Disconnected " .. count .. " clients with reason '" .. (args[2] or "unknown_reason") .. "'", type="success"}
    end
}
cmds["dcall"] = cmds.disconnectall
cmds["dcall"].desc = nil

cmds["throttle"] = {
    desc = "Apply throttle to a client by ID. Usage: clients throttle <ID> <SECONDS>",
    func = function(args, ctx) 
        if not args[3] or args[3] < 1 then return {str="Duration must be 1 or bigger", type="fail"} end
        local success = ctx.kernel:execute("clients.throttle", {id=args[2], throttle=args[3]})
        if success ~= 0 then
            return {str="Error: " .. success.log, type="fail"}
        end
        return {str="Applied a " .. args[3] .. " seconds throttle to client " .. args[2], type="success"}
    end
}

cmds["wake"] = {
    desc = "Manually wake up an inactive client",
    func = function(args, ctx)
        if not ctx.kernel:execute("clients.exists", args[2] or " ") then 
            return {str="Client not found", type="fail"}
        end
        ctx.kernel:execute("clients.get", args[2]).sleepy = false
        return {str="Client " .. args[1] .. " woken up successfully", type="success"}
    end
}

cmds["stale"] = {
    desc = "Show clients that are considered stale",
    func = function(args, ctx)
        local stale = ctx.kernel:execute("clients.stale")
        if not stale or #stale == 0 then
            return {str="No stale clients", type="info"}
        end

        local out = {"Stale clients ----------------"}
        for _, v in ipairs(stale) do
            table.insert(out,
                v.id .. " | Last Activity: " ..
                os.date("%Y-%m-%d %H:%M:%S", v.lastActivityTime / 1000) ..
                " | Sleepy: " .. tostring(v.sleepy)
            )
        end
        table.insert(out, "--------------------------------")
        return {str=out, type="info"}
    end
}

cmds["heartbeat"] = {
    desc = "Manually trigger heartbeat cycle",
    func = function(args, ctx)
        ctx.kernel:execute("clients.heartbeats")
        return {str="Heartbeat cycle executed", type="success"}
    end
}

cmds["rotate"] = {
    desc = "Force channel rotation for all clients",
    func = function(args, ctx)
        local result = ctx.kernel:execute("clients.update_channels")
        if result ~= 0 then
            return {str="No clients to rotate", type="info"}
        end
        return {str="Channels rotated successfully", type="success"}
    end
}

cmds["limits"] = {
    desc = "Show client configuration limits",
    func = function(args, ctx)
        local manager = ctx.kernel:getService("client_manager")
        local out = {
            "Clients Cap: " .. manager.maxClients,
            "Max Idle (ms): " .. manager.max_idle,
            "Throttle Limit (ms): " .. manager.throttleLimit,
            "Heartbeat Interval (s): " .. manager.heartbeat_interval,
            "Channel Rotation (s): " .. manager.channelRotation
        }
        return {str=out, type="info"}
    end
}

cmds["stats"] = {
    desc = "Show runtime statistics about connected clients",
    func = function(args, ctx)
        local list = ctx.kernel:execute("clients.list")
        local stale = ctx.kernel:execute("clients.stale") or {}
        local now = os.epoch("utc")
        local total = #list
        local sleepy = 0
        local throttled = 0
        local totalThrottle = 0
        local mostRecent = 0
        local oldestActivity = math.huge
        for _, id in ipairs(list) do
            local c = ctx.kernel:execute("clients.get", id)
            if c then
                if c.sleepy then sleepy = sleepy + 1 end
                if (c.throttle or 0) > 0 then
                    throttled = throttled + 1
                    totalThrottle = totalThrottle + c.throttle
                end
                mostRecent = math.max(mostRecent, c.lastActivityTime)
                oldestActivity = math.min(oldestActivity, c.lastActivityTime)
            end
        end
        local avgThrottle = throttled > 0 and math.floor((totalThrottle / throttled) / 1000) or 0
        local newestAgo = mostRecent > 0 and math.floor((now - mostRecent) / 1000) or 0
        local oldestAgo = oldestActivity < math.huge and math.floor((now - oldestActivity) / 1000) or 0
        local output = {
            "\16705Clients Statistics -------------------------",
            "\16706Active Clients: \167rr" .. total,
            "\16706Stale Clients: \167rr" .. #stale,
            "\16706Sleepy Clients: \167rr" .. sleepy,
            "\16706Throttled Clients: \167rr" .. throttled,
            "\16706Average Throttle (s): \167rr" .. avgThrottle,
            "\16706Most Recent Activity (s ago): \167rr" .. newestAgo,
            "\16706Oldest Activity (s ago): \167rr" .. oldestAgo,
            "\16705--------------------------------------------"
        }
        return {str = output, type = "info"}
    end
}
cmds["statistics"] = cmds["stats"]
cmds["statistics"].desc = nil


cmds["throttlerequests"] = {
    desc = "Throttle the global request queue. Usage: clients throttlerequests <SECONDS>",
    func = function(args, ctx)
        local seconds = tonumber(args[2])
        if not seconds or seconds < 0 then
            return {str = "Throttle must be 0 or greater", type = "fail"}
        end
        ctx.kernel:execute("queue.throttle", seconds)
        if seconds == 0 then
            return {str = "Request queue throttle disabled", type = "success"}
        end
        return {str = "Request queue throttled to one execution every " .. seconds .. " seconds", type = "success"}
    end
}
cmds["thrq"] = cmds["throttlerequests"]
cmds["thrq"].desc = nil

cmds["help"] = {
    func = function(args, ctx)
        local output = {"Clients commands -------------------------"}
        for k,v in pairs(cmds) do
            if type(v) == "table" and v.desc then
                table.insert(output, k .. ": " .. v.desc)             
            end
        end
        table.insert(output, "Clients commands -------------------------")
        return {str=output, type="info"}
    end
}

function cmds.run(args, ctx)
    if not args[1] or args[1] == "" then return {str="Unknown command: accounts ", type="fail"} end
    if not cmds[args[1]] then return {str=("Unknown command: account " .. args[1]), type="fail"} end
    return cmds[args[1]].func(args, ctx)
end

return cmds