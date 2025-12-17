local shutdown = {}
local callbacks = {}

function shutdown.register(fn)
    assert(type(fn) == "function", "register only expects functions")
    table.insert(callbacks, fn)
end

local function executeCallbacks()
    for i = 1, #callbacks do
        local ok, err = pcall(callbacks[i])
        if not ok then
            _G.logger:error(("[shutdown] Failed to execute callback %d: %s"):format(i, tostring(err)))
        end
    end
end

local original_shutdown = os.shutdown
local original_reboot = os.reboot

os.shutdown = function(...)
    _G.logger:debug("[shutdown] Server shutting down! Executing callbacks...")
    executeCallbacks()
    return original_shutdown(...)
end

os.reboot = function(...)
    _G.logger:debug("[shutdown] Server rebooting! Executing callbacks...")    
    executeCallbacks()
    return original_reboot(...)
end

return shutdown