local seed = os.time() * os.clock()

function randomNumber(min, max) 
        seed = seed + os.time() + os.clock() * 1000 + math.random(1000000)

        -- I am not gonna pretend i understand this part because i dont
        local multiplier = 1664525
        local increment = 1013904223
        local modulus = 2^32

        seed = (multiplier * seed + increment) % modulus
        local rand = (seed / modulus) * (max - min) + min
        return math.floor(rand)
end


function generateSessionToken(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local token = ""
    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        token = token .. charset:sub(randomIndex, randomIndex)
    end
    return token
end


-- generates a random UUID (used for the accounts)
function generateUUID()
    math.randomseed(os.time())
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end

-- checks if a number is whole
function isInteger(value)
    return math.floor(value) == value and value >= 0
end


-- generates salt for SHA256 hashes
function generateSalt(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local salt = ""
    math.randomseed(os.time())
    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        salt = salt .. charset:sub(randomIndex, randomIndex)
    end
    return salt
end


return {
    randomNumber = randomNumber,
    generateUUID = generateUUID,
    isInteger = isInteger,
    generateSalt = generateSalt,
    generateSessionToken = generateSessionToken
}