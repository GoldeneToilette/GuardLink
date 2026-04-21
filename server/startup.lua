--[[
MIT License

Copyright (c) 2024-2026 glittershitter

Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
and associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
/or sell copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PURPOSE 
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

package.path = package.path .. ";" .. "GuardLink/server/?.lua"
local kernel = require("kernel.kernel")

local services = {
    "/GuardLink/server/modules/disk.lua",
    "/GuardLink/server/modules/virtualFilesystem.lua",
    "/GuardLink/server/modules/logger.lua",

    "/GuardLink/server/network/clientManager.lua",
    "/GuardLink/server/network/dispatcher.lua",
    "/GuardLink/server/network/networkSession.lua",    
    "/GuardLink/server/network/requestQueue.lua",

    "/GuardLink/server/modules/account.lua",
    "/GuardLink/server/modules/wallet.lua",
    "/GuardLink/server/modules/nation.lua",
    "/GuardLink/server/modules/debt.lua",
    "/GuardLink/server/modules/law.lua",
    "/GuardLink/server/modules/uiState.lua",
}

kernel:initConfigs()

for i = 1, #services do
    kernel:registerService(services[i])
end

kernel:initServices()
kernel:run()

