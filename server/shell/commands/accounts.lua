local accountManager = require("/GuardLink/server/economy/accountManager")
local mathUtils = require("/GuardLink/server/utils/mathUtils")

-- accounts create [name] [password]
local function createAccount(words)
    if accountManager.createAccount(words[3], words[4]) then
        return { "Account " .. words[3] .. " created successfully!"}
    else
        return { "Failed to create Account " .. words[3]}
    end
end

-- accounts view [name]
local function viewAccount(words)
    local values = accountManager.getAccountValues(words[3])
    if values then
        return {
            "Name: " .. values.name,
            "UUID: " .. values.uuid,
            "Created: " .. values.creationDate,
            "Balance: " .. mathUtils.formatNumber(values.balance) .. " GC",
            "Ban Status: " .. tostring(values.banned),
            "Session Token: " .. values.sessionToken
        }
    else
        return {
            "Failed to retrieve Account values for " .. words[3]
        }
    end
end

-- accounts delete [name]
local function deleteAccount(words)
    if accountManager.deleteAccount(words[3]) then
        return { "Account " .. words[3] .. "deleted successfully!"}        
    else
        return { "Failed to delete Account " .. words[3]}
    end
end

-- accounts ban [name]
local function banAccount(words)
    accountManager.setAccountValue(words[3], "banned", "true")
    return { "Account " .. words[3] .. " banned successfully!"}
end

-- accounts ban [name]
local function unbanAccount(words)
    accountManager.setAccountValue(words[3], "banned", "false")
    return { "Account " .. words[3] .. " unbanned successfully!"}
end

-- accounts set [name] [key] [value]
local function setAccountKey(words)
    accountManager.setAccountValue(words[3], words[4], words[5])
    return { words[4] .. " set to " .. words[5] .. " for " .. words[3]}
end

-- accounts balance [name] [set/add/subtract] [value] 
local function changeAccountBalance(words)
    if accountManager.changeAccountBalance(words[4], words[3], words[5]) then
        return { "Balance changed successfully for " .. words[3]}        
    else
        return { "Failed to change balance for "  .. words[3]}    
    end
end

local accountCommands = {
    create = createAccount,
    view = viewAccount,
    delete = deleteAccount,
    ban = banAccount,
    unban = unbanAccount,
    set = setAccountKey,
    balance = changeAccountBalance,
}

local function handle(words)
    local action = words[2]
    local handler = accountCommands[action]

    -- if the function exists, execute it
    if handler then
        return handler(words)
    else
        if action then
            return { action .. " command not found. Use 'help accounts'" }
        else
            return {"Missing arguments! Use 'help accounts'"}
        end
    end
end

return {
    handle = handle
}