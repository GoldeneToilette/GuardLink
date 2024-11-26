local sha256 = require("/GuardLink/server/lib/sha256")

securityUtils = {}

-- generates a session token
function securityUtils.generateSessionToken(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local token = ""
    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        token = token .. charset:sub(randomIndex, randomIndex)
    end
    return token
end

-- generates a random UUID (used for the accounts)
function securityUtils.generateUUID()
    math.randomseed(os.time())
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end

-- generates salt for SHA256 hashes
function securityUtils.generateSalt(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local salt = ""
    math.randomseed(os.time())
    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        salt = salt .. charset:sub(randomIndex, randomIndex)
    end
    return salt
end

return securityUtils