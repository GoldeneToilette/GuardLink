local utils = {}

local charsets = {
    generic = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
    base32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567",
    numbers = "0123456789"
}

function utils.randomString(length, charset)
    if charsets[charset] then charset = charsets[charset] end
    local str = ""
    for i = 1, length do
        local index = math.random(1, #charset)
        str = str .. charset:sub(index, index)
    end
    return str
end

function utils.generateUUID()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end

function utils.tryCatch(tryBlock, catchBlock)
    local function errorHandler(err)
        local stackTrace = debug.traceback(err)
        if catchBlock then
            catchBlock(err, stackTrace)
        else
            _G.logger:fatal("Caught error: " .. tostring(err) .. "\nStack Trace:\n" .. stackTrace)
        end
    end
    
    local success = xpcall(tryBlock, errorHandler)
    
    if not success then
        _G.logger:fatal("Error handling failed.")
    end
end

function utils.isInteger(value)
    return math.floor(value) == value
end

function utils.formatNumber(n)
    if n >= 1e15 then
        return string.format("%.1fQ", n / 1e15)
    elseif n >= 1e12 then
        return string.format("%.1fT", n / 1e12)
    elseif n >= 1e9 then
        return string.format("%.1fB", n / 1e9)
    elseif n >= 1e6 then
        return string.format("%.1fM", n / 1e6)
    else
        return string.format("%d", n)
    end
end

function utils.stringToNumber(str)
    local seed = 0
    for i = 1, #str do
        seed = (seed * 31 + string.byte(str, i)) % 2^42
    end
    return seed
end

function utils.deepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = utils.deepCopy(v)
    end
    return copy
end

function utils.cprint(text, color, w)
    term.setTextColor(color or colors.white)
    if w then
        write(text)
    else
        print(text)
    end
    term.setTextColor(colors.white)
end



return utils