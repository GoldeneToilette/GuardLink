local rsa = requireC("/GuardLink/server/lib/rsa.keygen.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")

local message = {}
-- Types: response, request, notification
function message.create(action, payload, key, rsaFlag, id)
    if not action then return nil end
    local msg = {
        message = {
            action = action,
            payload = payload
        },
        timestamp = os.epoch("utc"),
        id = id or utils.randomString(16, "generic"),
        isPlaintext = false
    }
    if key then 
        if rsaFlag then
            msg.message = rsa.rsaEncrypt(textutils.serialize(msg.message), key)
        end
        msg.message = key:encrypt(textutils.serialize(msg.message))
    else
        msg.isPlaintext = true
    end
    return textutils.serialize(msg), msg.id
end

return message