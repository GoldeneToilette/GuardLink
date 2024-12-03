local accountManager = require("/GuardLink/server/economy/accountManager")

local createAccount = require("/GuardLink/server/shell/commands/accounts/create")
local viewAccount = require("/GuardLink/server/shell/commands/accounts/view")
local deleteAccount = require("/GuardLink/server/shell/commands/accounts/delete")
local banAccount = require("/GuardLink/server/shell/commands/accounts/ban")
local unbanAccount = require("/GuardLink/server/shell/commands/accounts/unban")
local setAccountKey = require("/GuardLink/server/shell/commands/accounts/set")
local changeAccountBalance = require("/GuardLink/server/shell/commands/accounts/balance")

local accountCommands = {
    create = createAccount,
    view = viewAccount,
    delete = deleteAccount,
    ban = banAccount,
    unban = unbanAccount,
    set = setAccountKey,
    balance = changeAccountBalance,
}

local function handle(cmd)
    local action = cmd[2]
    local handler = accountCommands[action]

    -- if the function exists, execute it
    if handler then
        return handler(cmd, accountManager)
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
