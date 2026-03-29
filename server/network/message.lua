local rsa = requireC("/GuardLink/server/lib/rsa-keygen.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")
local aes = requireC("/GuardLink/server/lib/aes.lua")

local message = {}
-- Types: response, request, notification
function message.create(header, payload, key, rsaFlag, id)
    if not header then return nil end
    local msg = {
        message = {
            header = header,
            payload = payload
        },
        timestamp = os.epoch("utc"),
        id = id or utils.randomString(16, "generic"),
        isPlaintext = false
    }
    if key then 
        if rsaFlag then
            msg.message = {cipher = rsa.rsaEncrypt(textutils.serialize(msg.message), key)}
        else
            local iv = {math.random(0, 0xffffffff), math.random(0, 0xffffffff), math.random(0, 0xffffffff), math.random(0, 0xffffffff)}
            local cipher = aes.Cipher:new(nil, key, iv)
            msg.message = {cipher = cipher:encrypt(textutils.serialize(msg.message)), iv = iv}
        end
    else
        msg.isPlaintext = true
    end
    msg.sender = "server"
    return textutils.serialize(msg), msg.id
end

return message