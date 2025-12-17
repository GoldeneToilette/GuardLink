local fileUtils = {}

-- Returns the content of a file
function fileUtils.read(path)
    if fs.exists(path) then
        local file = fs.open(path, "r")
        local contents = file.readAll()
        file.close()
        return contents
    end

    return false
end

-- Writes into the file
function fileUtils.write(path, data)
    if fs.exists(path) then
        local file = fs.open(path, "w")
        file.write(data)
        file.close() 
        return true
    end

    return false
end

-- clears a file (basically just a wrapper for readability)
function fileUtils.clear(path)
    fileUtils.write(path, "")
end

-- creates new file
function fileUtils.newFile(path)
    if not fs.exists(path) then
        local file = fs.open(path, "w")
        file.write("")
        file.close()
        return true
    end

    return false
end

-- deletes a file
function fileUtils.delete(path)
    if fs.exists(path) then
        fs.delete(path)
        return true
    end

    return false
end

-- Appends to a file
function fileUtils.append(path, data)
    if fs.exists(path) then
        local file = fs.open(path, "a")
        file.write(data)
        file.close()
        return true
    end

    return false
end

-- Creates a directory
function fileUtils.makeDir(dir)
    if not fs.exists(dir) then
        fs.makeDir(dir)
    end
end

return fileUtils