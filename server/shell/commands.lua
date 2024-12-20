local accounts = require("/GuardLink/server/shell/commands/accounts")
local network = require("/GuardLink/server/shell/commands/network")

-- splits the string into the individual words
local function parse(input)
    local cmd = {}
    for word in input:gmatch("%S+") do
        table.insert(cmd, word)
    end
    return cmd
end

-- Interprets the command and gives it over to the appropriate handler
-- this function should always return a string
local function handleCommand(input)
    local cmd = parse(input)

    if cmd[1] == "accounts" then
        return accounts.handle(cmd)
    elseif cmd[1] == "network" then
        return network.handle(cmd)
    else
        if cmd[1] then
            return {"Unknown command '" .. cmd[1] .. "'. Type help"}
        end
    end
end

return {
    handleCommand = handleCommand
}
