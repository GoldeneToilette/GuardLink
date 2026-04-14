local eventSystem = {
    events = {}
}

function eventSystem.registerEvent(name)
    if not eventSystem.events[name] then
        eventSystem.events[name] = {callbacks = {}}
    else
        error("Cant register event '" .. name .. "': Event already exists!")
    end
end

function eventSystem.subscribe(name, callback)
    if not eventSystem.events[name] then
        error("Cant subscribe to event '" .. name .. "': Doesnt exist!")
    end
    table.insert(eventSystem.events[name].callbacks, callback)
end

function eventSystem.unsubscribe(name, callback)
    local callbacks = eventSystem.events[name].callbacks
    for i = #callbacks, 1, -1 do
        if callbacks[i] == callback then
            table.remove(callbacks, i)
        end
    end
end

function eventSystem.emit(name, payload)
    local event = eventSystem.events[name]
    if not event then
        error("Cant emit event '" .. name .. "': Doesnt exist!")
    end
    for _, callback in ipairs(event.callbacks) do
        callback(payload)
    end
end

return eventSystem
