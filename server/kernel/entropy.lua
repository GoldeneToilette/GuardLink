local sha256 = requireC("/GuardLink/server/lib/sha256.lua")

local entropy = {}

local POOL_SIZE = 20
local pool = {}
local head = 1

local function hash(value)
    return sha256.digest(tostring(value)):toHex()
end

local function mix(a, b)
    return hash(a .. tostring(os.epoch("utc")) .. tostring(b))
end

function entropy.init()
    for i = 1, POOL_SIZE do
        pool[i] = hash(
            tostring(os.epoch("utc")) ..
            tostring(os.clock()) ..
            tostring(os.getComputerID()) ..
            tostring(i)
        )
    end
end

function entropy.add(value)
    pool[head] = mix(pool[head], value)
    head = (head % POOL_SIZE) + 1
end

function entropy.seed()
    local entry = mix(pool[head], pool[(head % POOL_SIZE) + 1])
    local seed = tonumber(entry:sub(1, 13))
    math.randomseed(seed)
    entropy.add(seed)
    return math.random()
end

function entropy.reset()
    head = 1
    entropy.init()
end

-- globals
_G.addEntropy = entropy.add
_G.seedRandom = entropy.seed

return entropy
