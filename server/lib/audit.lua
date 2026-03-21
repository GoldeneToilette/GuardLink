local audit = {}

function audit.log(service_name, name, tbl, vfs)
    local path = "logs/" .. service_name .. "_audit"
    local filePath = path .. "/" .. name .. ".log"
    if not vfs:existsDir(path) then
        vfs:makeDir(path)
    end
    if not vfs:existsFile(filePath) then
        vfs:newFile(filePath)
    end
    if tbl then
        local entry = "{" .. math.floor(os.epoch("utc") / 1000) .. "," .. table.concat(tbl, ",") .. "}\n"
        vfs:appendFile(filePath, entry)
    end
    return 0
end

function audit.get(service_name, name, vfs)
    local content = vfs:readFile("logs/" .. service_name .. "_audit/" .. name .. ".log")
    if not content or content == "" then return {} end
    local entries = {}
    for line in content:gmatch("[^\n]+") do
        local entry = textutils.unserialize(line)
        if entry then table.insert(entries, entry) end
    end
    return entries
end

return audit