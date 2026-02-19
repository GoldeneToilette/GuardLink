local kernel = require("kernel.kernel")

local services = {
    "/GuardLink/server/modules/disk.lua",
    "/GuardLink/server/modules/virtualFilesystem.lua",
    "/GuardLink/server/modules/logger.lua",
    "/GuardLink/server/modules/account.lua",
    "/GuardLink/server/modules/wallet.lua",
    "/GuardLink/server/modules/uiState.lua",

    "/GuardLink/server/network/clientManager.lua",
    "/GuardLink/server/network/dispatcher.lua",
    "/GuardLink/server/network/requestQueue.lua",
    "/GuardLink/server/network/networkSession.lua",
}

kernel:initConfigs()

for i = 1, #services do
    kernel:registerService(services[i])
end

kernel:initServices()
kernel:run()

