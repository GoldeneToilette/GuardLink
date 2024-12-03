local accounts = require("/GuardLink/server/shell/commands/accounts")
local network = require("/GuardLink/server/shell/commands/network")

-- splits the string into the individual words
local function parse(input)
    local words = {}
    for word in input:gmatch("%S+") do
        table.insert(words, word)
    end
    return words
end

-- Interprets the command and gives it over to the appropriate handler
-- this function should always return a string
local function handleCommand(input)
    local words = parse(input)

    if words[1] == "accounts" then
        return accounts.handle(words)
    elseif words[1] == "network" then
        return network.handle(words)
    else
        if words[1] then
            return {"Unknown command '" .. words[1] .. "'. Type help"}
        end
    end
end

return {
    handleCommand = handleCommand
}