os.loadAPI("/GuardLink/server/lib/cryptoNet")

local clientManager = require("/GuardLink/server/network/clientManager")
local requestQueue = require("/GuardLink/server/network/requestQueue")
local requestHandler = require("/GuardLink/server/network/requestHandler")

local inspectClient = require("/GuardLink/server/shell/commands/network/client_inspect")
local listClient = require("/GuardLink/server/shell/commands/network/client_list")
local removeClient = require("/GuardLink/server/shell/commands/network/client_remove")

local queueAdd = require("/GuardLink/server/shell/commands/network/queue_add")
local queueClear = require("/GuardLink/server/shell/commands/network/queue_clear")
local queuePrioritize = require("/GuardLink/server/shell/commands/network/queue_prioritize")
local queueRemove = require("/GuardLink/server/shell/commands/network/queue_remove")
local queueSize = require("/GuardLink/server/shell/commands/network/queue_size")
local queuePostpone = require("/GuardLink/server/shell/commands/network/queue_postpone")
local queuePause = require("/GuardLink/server/shell/commands/network/queue_pause")
local queueResume = require("/GuardLink/server/shell/commands/network/queue_resume")
local queuePopulation = require("/GuardLink/server/shell/commands/network/queue_population")
local queueAverage = require("/GuardLink/server/shell/commands/network/queue_average")
local queueInspect = require("/GuardLink/server/shell/commands/network/queue_inspect")
local queueList = require("/GuardLink/server/shell/commands/network/queue_list")
local queueThrottle = require("/GuardLink/server/shell/commands/network/queue_throttle")
local queueStats = require("/GuardLink/server/shell/commands/network/queue_stats")


local clientCommands = {
    inspect = inspectClient,
    list = listClient,
    remove = removeClient
}

local queueCommands = {
    size = queueSize,
    clear = queueClear,
    add = queueAdd,
    remove = queueRemove,
    prioritize = queuePrioritize,
    postpone = queuePostpone,
    pause = queuePause,
    resume = queueResume,
    population = queuePopulation,
    average = queueAverage,
    inspect = queueInspect,
    list = queueList,
    throttle = queueThrottle,
    stats = queueStats
}

local function handle(cmd)
    local mainCommand = cmd[2]
    local subCommand = cmd[3]

    local clientCmd = clientCommands[subCommand]
    local queueCmd = queueCommands[subCommand]

    if mainCommand == "client" then
        if clientCmd then
            return clientCmd(cmd, clientManager)
        else
            return {"Command not found. Use 'help client'"}
        end
    end

    if mainCommand == "queue" then
        if queueCmd then
            return queueCmd(cmd, requestQueue, requestHandler)
        else
            return {"Command not found. Use 'help queue'"}
        end

    end

    return {"Command not found. Use 'help network'"}
end

return {
    handle = handle
}
