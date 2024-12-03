local function queuePopulation(cmd, requestQueue)
    _G.logger:debug("[shell] Command 'network queue population' executed")
    local population = requestQueue.getPopulation()
    if population then
        return {"Current population: " .. tostring(population)}
    else
        return {"Queue is empty!"}
    end
end

return queuePopulation