local rsa = require "lib.rsa-keygen"

local message = {}
-- Types: response, request, notification
function message.create(action, payload, key, rsaFlag)
    if not action then return nil end
    local msg = {
        message = {
            action = action,
            payload = payload
        },
        timestamp = os.epoch("utc"),
        id = _G.utils.randomString(16, "generic"),
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