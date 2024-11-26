mathUtils = {}

-- checks if a number is whole
function mathUtils.isInteger(value)
    return math.floor(value) == value and value >= 0
end

-- returns a random number
function mathUtils.randomNumber(min, max) 
        local seed = os.time() * os.clock()
        seed = seed + os.time() + os.clock() * 1000 + math.random(1000000)

        -- I am not gonna pretend i understand this part because i dont
        local multiplier = 1664525
        local increment = 1013904223
        local modulus = 2^32

        seed = (multiplier * seed + increment) % modulus
        local rand = (seed / modulus) * (max - min) + min
        return math.floor(rand)
end

return mathUtils