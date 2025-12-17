local accountManager = require("modules.account")
local cmds = {}

cmds["view"] = {
    desc = "View someones account information",
    func = function(args)
        local values = accountManager.getSanitizedAccountValues(tostring(args[2]))
        if values then
            term.setTextColor(colors.lightGray)
            print("Name: " .. values.name)
            print("UUID: " .. values.uuid)
            print("Created: " .. values.creationDate .. " " .. values.creationTime)
            print("Banned: " .. tostring(values.ban.active))
            if values.ban.active then
                print("Duration: " .. values.ban.duration)
                print("Reason: " .. values.ban.reason)
            end
            
            print("Role: " .. values.role)
            print("Wallets: " .. table.concat(values.wallets, ", "))
        else
            error("Failed to retrieve account information for " .. args[2])
        end
    end
}
cmds["unban"] = {
    desc = "Unban an account",
    func = function(args)
        if accountManager.exists(args[2]) then
            if not accountManager.isBanned(args[2]) then error("Failed to unban " .. args[2] .. ", account is not banned!") end
            accountManager.pardon(args[2])
            term.setTextColor(colors.green)
            print(args[2] .. " has been unbanned!")
            term.setTextColor(colors.lightGray)
        else
            error("Failed to unban " .. args[2] .. ", account not found!")
        end
    end
}
cmds["pardon"] = {
    desc = cmds["unban"].desc,
    func = cmds["unban"].func
}
cmds["delete"] = {
    desc = "Permanently delete an account",
    func = function(args)
        if accountManager.exists(args[2]) then
            accountManager.deleteAccount(args[2])
            term.setTextColor(colors.green)
            print(args[2] .. " has been deleted!")
            term.setTextColor(colors.lightGray)
        else
            error("Failed to delete " .. args[2] .. ", account not found!")
        end
    end
}
cmds["ban"] = {
    desc = "Ban an account. Usage: account ban <name> <duration> <time unit> <reason> \n Example: account ban player1 50 hours cheating",
    func = function(args)
        if accountManager.exists(args[2]) then
            local duration = {}
            duration[args[4]] = tonumber(args[3])
            local status = accountManager.banAccount(args[2], duration, args[5])
            if not status then error("Failed to ban " .. args[2] .. ", unknown error!") end
            term.setTextColor(colors.green)
            print(args[2] .. " has been banned successfully for: " .. args[5] .. "")
            term.setTextColor(colors.lightGray)
        else
            error("Failed to ban " .. args[2] .. ", account not found!")
        end
    end
}
cmds["create"] = {
    desc = "Create a new account. Usage: account create <name> <password>",
    func = function(args)
        local success = accountManager.createAccount(args[2], args[3])
        if success ~= 0 then
            error(success[1])
        else
            term.setTextColor(colors.green)
            print("Successfully created account " .. args[2] .. "!")
            term.setTextColor(colors.lightGray)
        end
    end
}
cmds["help"] = {
    func = function(args)
        print("Account commands -------------------------")
        for k,v in pairs(cmds) do
            if v.desc then print(k, ": " .. v.desc) end
        end
        print("Account commands -------------------------")
    end
}

local function run(args)
    if not cmds[args[1]] then error("Unknown argument: " .. args[1]) end
    cmds[args[1]].func(args)
end

return {
    name = "account",
    run = run
}