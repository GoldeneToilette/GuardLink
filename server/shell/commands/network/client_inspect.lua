local function inspectClient(cmd, clientManager)
    _G.logger:debug("[shell] Command 'network client inspect' executed")
        local client = clientManager.inspect(tonumber(cmd[4]))
        if client then
            return {
                "ID: " .. client.id,
                "Connected At: " .. client.connectedAt,
                "Last Activity: " .. client.lastActivityType
            }
        else
            return {"Failed to inspect client " .. cmd[4]}
        end
end

return inspectClient