local fileUtils = {}

function isValidPath(path)
    return fs.exists(path)
end

-- Returns the content of a file as is
function fileUtils.readFile(path)
    if isValidPath(path) then
        local file = fs.open(path, "r")
        if file then
            local contents = file.readAll()
            file.close()
            return contents
        else
            _G.logger:error("[fileUtils] Couldn't read file!")
            return nil
        end
    end
end

-- Writes "data" into the file
function fileUtils.writeFile(path, data)
        local file = fs.open(path, "w")
        file.write(data)
        file.close()
end

-- deletes a file
function fileUtils.deleteFile(path)
    if isValidPath(path) then
        fs.delete(path)
    end
end

-- Appends data to the end of the file
function fileUtils.appendToFile(path, data)
    if isValidPath(path) then
        local file = fs.open(path, "a")
        file.write(data)
        file.close()
    end
end

-- Returns a table of all account values
function fileUtils.readAccountFile(name)
    local path = "/GuardLink/server/economy/accounts/" .. name .. ".json"
    if isValidPath(path) then
        return textutils.unserialize(fileUtils.readFile(path))
    else
        return nil
    end
end

-- Writes to an account file
function fileUtils.writeAccountFile(name, data)
    local path = "/GuardLink/server/economy/accounts/" .. name .. ".json"
        fileUtils.writeFile(path, data)
end

return fileUtils
