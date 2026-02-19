local utils = requireC("/GuardLink/server/lib/utils.lua")

local taskManager = {}
taskManager.tasks = {}

function taskManager.add(callback, interval)
    local now = os.epoch("utc") / 1000
    table.insert(taskManager.tasks, {
        callback = callback,
        interval = interval,
        lastRun = now
    })
end

function taskManager.remove(callback)
    for i, task in ipairs(taskManager.tasks) do
        if task.callback == callback then
            table.remove(taskManager.tasks, i)
            break
        end
    end
end

function taskManager.clear()
    taskManager.tasks = {}
end

function taskManager.run()
    while true do
        if #taskManager.tasks > 0 then
            local now = os.epoch("utc") / 1000
            for _, task in ipairs(taskManager.tasks) do
                if now - task.lastRun >= task.interval then
                    local ok, err = pcall(task.callback)
                    if not ok then
                        -- idk do something i guess
                    end
                    task.lastRun = now
                end
            end
        end
        os.sleep(0.1)
    end
end

return taskManager
