-- Exhibit A: comically messy installer
local dep = {
    basalt = "https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/basalt.lua",
    uiHelper = "https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/uiHelper.lua",
    pixelbox = "https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/pixelbox_lite.lua",
    settings = "https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/settings.lua",
    disk = "https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/modules/disk.lua",
    fileUtils = "https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/fileUtils.lua"
}

local env = {}
for k,v in pairs(_G) do env[k] = v end
env.requireC = function(path) return {} end 

local runbasalt = true

local response = http.get(
    "https://api.github.com/repos/GoldeneToilette/GuardLink/releases/latest",
    { ["User-Agent"] = "CCInstaller" }
)
if not response then
    error("Failed to fetch release info")
end
local release = textutils.unserializeJSON(response.readAll())
response.close()
local fileUrl = "https://raw.githubusercontent.com/GoldeneToilette/GuardLink/" .. release.tag_name .. "/releases/guardlink_server.lua"

local lib = {}
for k,v in pairs(dep) do
  lib[k] = load(http.get(v).readAll(), k, "t", env)()
end

local diskManager = lib.disk.init(nil, lib.fileUtils) 

-- MAINFRAME IS CREATED HERE -------------------------------------------------------------------------------------------
local mainframe = lib.basalt.createFrame():setVisible(true)
local timeline = lib.uiHelper.newLabel(mainframe, "  \26   \26  ", 1, 1, 51, 1, colors.lightGray, colors.gray, 1) 
local stepLabels = {}
local activeStep = 0
for i = 1, 9, 4 do
    table.insert(stepLabels, lib.uiHelper.newLabel(mainframe, "\186", i, 1, 1, 1, colors.lightGray, colors.gray, 1))
end
local function createFrame(scrollable)
    local f = scrollable and mainframe:addScrollableFrame() or mainframe:addFrame()
    return f:setSize("parent.w", "parent.h - 1"):setPosition(1, 2):setBackground(colors.white):setVisible(false)
end

local panels = {}

local function next()
    if activeStep >= #panels then
        error("Tried to load panel that doesn't exist!")
    end
    if activeStep > 0 then
        panels[activeStep].frame:setVisible(false)

        if activeStep > 1 and stepLabels and stepLabels[activeStep-1] then
            stepLabels[activeStep-1]:setForeground(colors.green)
        end
    end
    activeStep = activeStep + 1
    panels[activeStep].frame:setVisible(true)
end

local function previous()
    if activeStep <= 2 then 
        error("Tried to load invalid panel!")
    end

    panels[activeStep].frame:setVisible(false)
    if stepLabels[activeStep-2] then
        stepLabels[activeStep-2]:setForeground(colors.gray)
    end
    activeStep = activeStep - 1
    panels[activeStep].frame:setVisible(true)
end

local function popUp(frame, message, type)
    local title = type == "error" and "Error" or "Info"
    local color = type == "error" and colors.red or colors.green

    local frame = frame:addMovableFrame()
    :setVisible(true):setSize(35, 7):setPosition(6, 4):setBackground(colors.white)
    :setBorder(colors.lightGray, "right", "bottom")

    frame:addLabel():setText(title):setSize(34, 1):setPosition(1,1)
    :setBackground(colors.blue):setForeground(colors.white)

    frame:addLabel():setText(message):setPosition(2, 3):setSize(30, 4)
    :setBackground(colors.white):setForeground(color)

    lib.uiHelper.newButton(frame, "X", 35, 1, 1, 1, colors.blue, colors.red,
    function(s, event, button, x, y)
        frame:setVisible(false)
        frame:remove()
    end)
end

-- MAINFRAME IS CREATED HERE -------------------------------------------------------------------------------------------





-- START FRAME ---------------------------------------------------------------------------------------------------------
panels[1] = {
    data = {},
    ui = {},
    frame = createFrame(),
    build = function(self) 
        local ui, frame = self.ui, self.frame
        ui.title = lib.uiHelper.newLabel(frame, "Welcome to GuardLink Setup!", 1, 2, 28, 1, colors.white, colors.blue, 1)
        ui.pane = lib.uiHelper.newPane(frame, 32, 2, 19, 15, colors.lightGray)
        :setBorder(colors.gray, "left")

        ui.table = lib.uiHelper.newLabel(frame, 
        "1.Nation          2.Core Settings   3.Final", 
        33, 3, 18, 9, colors.lightGray, colors.gray)

        ui.button = lib.uiHelper.newButton(frame, "Start", 43, 13, 7, 3, colors.gray, colors.white, 
        function() 
            panels[2]:build()
            next() 
        end)

        local function spinningCube(box)local cx,cy=box.width/2,box.height/2;local scale=math.min(box.width,box.height)/3.7;local baseSpeed=0.05;local verts={{-1,-1,-1},{1,-1,-1},{1,1,-1},{-1,1,-1},{-1,-1,1},{1,-1,1},{1,1,1},{-1,1,1}}local edges={{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}local rotX,rotY=0,0;while true do box:clear(colors.white)local projected={}for i,v in ipairs(verts)do local x,y,z=v[1],v[2],v[3]local y1=y*math.cos(rotX)-z*math.sin(rotX)local z1=y*math.sin(rotX)+z*math.cos(rotX)local x2=x*math.cos(rotY)-z1*math.sin(rotY)projected[i]={cx+x2*scale,cy+y1*scale}end;for _,e in ipairs(edges)do local v1,v2=projected[e[1]],projected[e[2]]local x1,y1=math.floor(v1[1]),math.floor(v1[2])local x2,y2=math.floor(v2[1]),math.floor(v2[2])local dx,dy=math.abs(x2-x1),math.abs(y2-y1)local sx,sy=x1<x2 and 1 or-1,y1<y2 and 1 or-1;local err=dx-dy;while true do if x1>=1 and x1<=box.width and y1>=1 and y1<=box.height then box.canvas[y1][x1]=colors.blue end;if x1==x2 and y1==y2 then break end;local e2=err*2;if e2>-dy then err=err-dy;x1=x1+sx end;if e2<dx then err=err+dx;y1=y1+sy end end end;box:render()local t=os.clock()local speed=baseSpeed*(0.85+0.15*math.sin(t*0.8))rotX=rotX+speed;rotY=rotY+speed*0.7;os.sleep(0.05)end end
        ui.animation = frame:addProgram():setSize(25, 14):setPosition(3, 5)
        :execute(function()
            local box = lib.pixelbox.new(term.current())
            spinningCube(box)
        end)
    end,
    validate = function(self) 
        popUp(self.frame, "NOTHING TO VALIDATE; IF YOU SEE THIS SOMETHING BROKE", "error")
    end
}
-- START FRAME ---------------------------------------------------------------------------------------------------------





-- NATION FRAME --------------------------------------------------------------------------------------------------------
panels[2] = {
    data = {
        roles = {}
    },
    ui = {},
    frame = createFrame(),
    build = function(self) 
        local ui, frame, data = self.ui, self.frame, self.data
        ui.pane = lib.uiHelper.newPane(frame, 2, 2, 21, 7, colors.lightGray)

        ui.nation_name = lib.uiHelper.newLabel(frame, "Name:", 3, 3, 5, 1, colors.lightGray, colors.gray, 1)
        ui.nation_field = lib.uiHelper.newTextfield(frame, 9, 3, 13, 1, colors.gray, colors.white)
        :editLine(1, data.nation_name or "")

        ui.tag_name = lib.uiHelper.newLabel(frame, "Tag (3 chars):", 3, 5, 14, 1, colors.lightGray, colors.gray, 1)
        ui.tag_field = lib.uiHelper.newTextfield(frame, 18, 5, 4, 1, colors.gray, colors.white)        
        :editLine(1, data.nation_tag or "")

        ui.ethic_label = lib.uiHelper.newLabel(frame, "Ethic:", 3, 7, 6, 1, colors.lightGray, colors.gray, 1)
        ui.ethic_dropdown = frame:addDropdown()
        :setForeground(colors.white)
        :setBackground(colors.gray)
        :setPosition(10, 7)

        local fi = ""
        for k,v in pairs(lib.settings.rules.ethics) do
            if fi == "" then fi = k end
            ui.ethic_dropdown:addItem(v.name, colors.gray, colors.white, k)
        end

        if not data.selectedEthic then 
            data.selectedEthic = fi
        end

        for i = 1, ui.ethic_dropdown:getItemCount() do
            if ui.ethic_dropdown:getItem(i).args.k == data.selectedEthic then
                ui.ethic_dropdown:selectItem(i)
            end
        end

        ui.ethic_pane = lib.uiHelper.newPane(frame, 2, 10, 1, 3, colors.white):setBorder(colors.blue, "left")
        ui.ethic_desc = lib.uiHelper.newLabel(frame, lib.settings.rules.ethics[data.selectedEthic].description, 
        3, 10, 21, 3, colors.white, colors.gray)

        ui.ethic_dropdown:onChange(function(s, event, item)
            ui.ethic_desc:setText(lib.settings.rules.ethics[item.args[1]].description)
            data.selectedEthic = item.args[1]
        end)

        -- ROLES ---------------------------------------------------------
        ui.roles_frame = frame:addMovableFrame():setVisible(false):setSize(45, 13):setPosition(4, 4):setBackground(colors.white)
        :setBorder(colors.lightGray, "right", "bottom")
        ui.roles_title = ui.roles_frame:addLabel():setText("Manage Roles"):setSize(44, 1):setPosition(1,1)
        :setBackground(colors.blue)
        :setForeground(colors.white)

        ui.roles_name = lib.uiHelper.newLabel(ui.roles_frame, "Title:", 2, 3, 6, 1, colors.white, colors.gray, 1)
        ui.roles_name_text = lib.uiHelper.newTextfield(ui.roles_frame, 10, 3, 20, 1, colors.lightGray, colors.gray)

        ui.roles_count = lib.uiHelper.newLabel(ui.roles_frame, "Count:", 32, 3, 6, 1, colors.white, colors.gray, 1)
        ui.roles_count_text = lib.uiHelper.newTextfield(ui.roles_frame, 40, 3, 4, 1, colors.lightGray, colors.gray)

        ui.roles_list = ui.roles_frame:addList()
        :setBackground(colors.lightGray)
        :setForeground(colors.white)
        :setPosition(2, 5)
        :setSize(28, 6)
        :setSelectionColor(nil, colors.black)
        :setScrollable(true)

        for i,v in ipairs(data.roles) do
            ui.roles_list:addItem(v[1], colors.lightGray, colors.gray, v[2])
        end

        local function getRoleCap()
            return lib.settings.server.formulas.roleLimit(lib.settings.rules.ethics[data.selectedEthic].values.stability) 
        end
        local function remainingRoleCap()
            return getRoleCap() - ui.roles_list:getItemCount()
        end

        ui.roles_capacity = lib.uiHelper.newLabel(ui.roles_frame, "Role Capacity: " .. remainingRoleCap(), 2, 12, 17, 1, colors.white, colors.gray, 1)

        ui.roles_new = lib.uiHelper.newButton(ui.roles_frame, "Add", 32, 5, 5, 3, colors.blue, colors.white)
        :setBorder(colors.white, "top")
        :onClick(function(s, event, button, x, y)
            local cap = getRoleCap()
            local count = ui.roles_list:getItemCount()
            local text = ui.roles_name_text:getLine(1)
            local seats = tonumber(ui.roles_count_text:getLine(1))
            if remainingRoleCap() > 0 and #text <= lib.settings.rules.maxRoleLength and #text >= 1 and (seats and seats >= 1) and type(seats) == "number" then
                ui.roles_list:addItem(text, colors.lightGray, colors.gray, math.min(seats, 500))
                if cap < 0 then
                    ui.roles_capacity:setForeground(colors.red)
                else
                    ui.roles_capacity:setForeground(colors.green)
                end
                ui.roles_capacity:setText("Role Capacity: " .. remainingRoleCap())
            end
        end)

        ui.roles_del = lib.uiHelper.newButton(ui.roles_frame, "Remove", 32, 8, 8, 3, colors.blue, colors.white)
        :setBorder(colors.white, "top")
        :onClick(function(s, event, button, x, y)
            local selected = ui.roles_list:getItemIndex()
            if selected and selected >= 1 then
                ui.roles_list:removeItem(selected)
                local cap = remainingRoleCap()
                if cap < 0 then
                    ui.roles_capacity:setForeground(colors.red)
                else
                    ui.roles_capacity:setForeground(colors.green)
                end
                ui.roles_capacity:setText("Role Capacity: " .. cap)                
            end
        end)

        ui.roles_exit = lib.uiHelper.newButton(ui.roles_frame, "X", 45, 1, 1, 1, colors.blue, colors.red,
        function(s, event, button, x, y)
            ui.roles_frame:setVisible(false)
        end)
        -- ROLES ---------------------------------------------------------

        ui.roles_button = lib.uiHelper.newButton(frame, "Manage Roles", 2, 15, 14, 3, colors.gray, colors.white, 
        function(s, event, button, x, y)
            local cap = remainingRoleCap()
            if cap < 0 then
                ui.roles_capacity:setForeground(colors.red)
            else
                ui.roles_capacity:setForeground(colors.green)
            end
            ui.roles_capacity:setText("Role Capacity: " .. cap)
            ui.roles_frame:setVisible(true)
        end)

        
        ui.paneEco = lib.uiHelper.newPane(frame, 25, 2, 26, 7, colors.lightGray)

        ui.ecoName = lib.uiHelper.newLabel(frame, "Currency Name:", 26, 3, 14, 1, colors.lightGray, colors.gray)
        ui.ecoField = lib.uiHelper.newTextfield(frame, 41, 3, 9, 1, colors.gray, colors.white)
        :editLine(1, data.currency_name or "")

        ui.balance = lib.uiHelper.newLabel(frame, "Starting Balance:", 26, 5, 17, 1, colors.lightGray, colors.gray)
        ui.balanceField = lib.uiHelper.newTextfield(frame, 44, 5, 6, 1, colors.gray, colors.white)
        ui.balanceField:editLine(1, data.balance or "0")

        ui.trade = lib.uiHelper.newLabel(frame, "Inter-Nation Trade:", 26, 7, 19, 1, colors.lightGray, colors.gray)
        ui.tradeCheck = frame:addCheckbox():setPosition(46, 7):setBackground(colors.gray):setForeground(colors.white)
        :setValue(data.tradeCheck)
        :onChange(function(s, event, value)
            data.tradeCheck = value
        end)

        ui.next_button = lib.uiHelper.newButton(frame, "Next", 45, 15, 6, 3, colors.blue, colors.white,
        function(s, event, button, x, y)
            local status = self:validate()
            if status ~= 0 then 
                popUp(frame, status, "error")
            else
                data.nation_name = ui.nation_field:getLine(1)
                data.nation_tag = ui.tag_field:getLine(1)
                data.currency_name = ui.ecoField:getLine(1)
                data.balance = ui.balanceField:getLine(1)

                -- Store roles
                for i = 1, ui.roles_list:getItemCount() do
                    local item = ui.roles_list:getItem(i)
                    data.roles[i] = {item.text, item.args[1]}
                end

                panels[3]:build()
                next() 
            end
        end)
    end,
    validate = function(self)
        local ui = self.ui
        if #ui.nation_field:getLine(1) == 0 or #ui.nation_field:getLine(1) > lib.settings.rules.maxNationLength then 
            return "Nation name must be 1-" .. lib.settings.rules.maxNationLength .. " characters!"
        end
        if #ui.tag_field:getLine(1) ~= 3 then 
            return "Tag must be 3 characters!"
        end
        local n = lib.settings.server.formulas.roleLimit(lib.settings.rules.ethics[self.data.selectedEthic].values.stability) 
        - ui.roles_list:getItemCount()
        if n < 0 then 
            return "Exceeding role capacity! " .. n
        end
        if #ui.ecoField:getLine(1) == 0 or #ui.ecoField:getLine(1) > lib.settings.rules.maxCurrencyLength then 
            return "Currency name must be 1-" .. lib.settings.rules.maxCurrencyLength .. " characters!"
        end
        local bal = tonumber(ui.balanceField:getLine(1))
        if not bal or bal < 0 then
            return "Invalid starting balance: " .. ui.balanceField:getLine(1)
        end

        return 0 
    end
}
-- NATION FRAME --------------------------------------------------------------------------------------------------------





-- SETTINGS FRAME --------------------------------------------------------------------------------------------------------
local themes_table = textutils.unserializeJSON(http.get("https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/config/themes.json").readAll())
panels[3] = {
    data = {},
    ui = {},
    frame = createFrame(),
    build = function(self)
        local function paletteSwap(theme)
            local t = themes_table[theme]
            if t then
                local colorsMap = {}
                for _, pair in ipairs(t) do
                    colorsMap[pair[1]] = pair[2]
                end
                term.setPaletteColor(colors.orange, tonumber(colorsMap.background))
                term.setPaletteColor(colors.magenta, tonumber(colorsMap.surface))
                term.setPaletteColor(colors.lightBlue, tonumber(colorsMap.border))
                term.setPaletteColor(colors.yellow, tonumber(colorsMap.primary))
                term.setPaletteColor(colors.lime, tonumber(colorsMap.secondary))
                term.setPaletteColor(colors.cyan, tonumber(colorsMap.textprimary))
                term.setPaletteColor(colors.purple, tonumber(colorsMap.textsecondary))
                term.setPaletteColor(colors.brown, tonumber(colorsMap.highlight))
            end
        end

        local data, ui, frame = self.data, self.ui, self.frame

        ui.title_label = lib.uiHelper.newLabel(frame, "Server Settings", 3, 3, 17, 1, colors.lightGray, colors.gray)        
        ui.pane = lib.uiHelper.newPane(frame, 2, 2, 21, 13, colors.lightGray)

        
        ui.theme_label = lib.uiHelper.newLabel(frame, "Theme:", 3, 5, 6, 1, colors.lightGray, colors.gray)
        ui.theme_dropdown = frame:addDropdown()
        :setForeground(colors.white)
        :setBackground(colors.gray)
        :setPosition(10, 5)

        ui.background = lib.uiHelper.newPane(frame, 3, 7, 2, 1, colors.orange)
        ui.surface = lib.uiHelper.newPane(frame, 5, 7, 2, 1, colors.magenta)
        ui.border = lib.uiHelper.newPane(frame, 7, 7, 2, 1, colors.lightBlue)
        ui.primary = lib.uiHelper.newPane(frame, 9, 7, 2, 1, colors.yellow)
        ui.secondary = lib.uiHelper.newPane(frame, 11, 7, 2, 1, colors.lime)
        ui.textprimary = lib.uiHelper.newPane(frame, 13, 7, 2, 1, colors.cyan)
        ui.textsecondary = lib.uiHelper.newPane(frame, 15, 7, 2, 1, colors.purple)
        ui.highlight = lib.uiHelper.newPane(frame, 17, 7, 2, 1, colors.brown)

        local fi = ""
        for k,v in pairs(themes_table) do
            if fi == "" then fi = k end
            if k == "default" then fi = k end
            ui.theme_dropdown:addItem(k, colors.gray, colors.white)
        end
        if not data.theme then 
            data.theme = fi
        end
        for i = 1, ui.theme_dropdown:getItemCount() do
            if ui.theme_dropdown:getItem(i).text == data.theme then
                ui.theme_dropdown:selectItem(i)
            end
        end
        paletteSwap(data.theme)

        ui.theme_dropdown:onChange(function(s, event, item)
            paletteSwap(item.text)
            data.theme = item.text
        end)

        ui.debug_label = lib.uiHelper.newLabel(frame, "Debug logs:", 3, 9, 11, 1, colors.lightGray, colors.gray)
        ui.debug_check = frame:addCheckbox():setPosition(15, 9):setBackground(colors.gray):setForeground(colors.white)
        :setValue(data.debug)
        :onChange(function(s, event, value)
            data.debug = value
        end)


        diskManager:scan()
        ui.pane2 = lib.uiHelper.newPane(frame, 24, 2, 27, 13, colors.lightGray)
        ui.disksTitle = lib.uiHelper.newLabel(frame, "Disks", 25, 3, 5, 1, colors.lightGray, colors.gray)
        ui.detected = lib.uiHelper.newLabel(frame, "Detected: " .. diskManager:diskCount(), 25, 5, 13, 1, colors.lightGray, colors.gray)
        ui.capacity = lib.uiHelper.newLabel(frame, "Space: " .. (diskManager.capacity / 1000000) .. "MB", 25, 6, 13, 1, colors.lightGray, colors.gray)

        ui.list = frame:addList()
        :setBackground(colors.white)
        :setForeground(colors.gray)
        :setPosition(39, 3)
        :setSize(10, 11)
        :setSelectionColor(nil, colors.black)
        :setScrollable(true)
        local labels = diskManager:getDiskLabels()
        for i,v in ipairs(labels) do
            ui.list:addItem(v)
        end
 
        ui.detect = lib.uiHelper.newButton(frame, "Detect", 25, 11, 8, 3, colors.blue, colors.white,
        function(s, event, button, x, y)
            diskManager:scan()
            ui.detected:setText("Detected: " .. diskManager:diskCount())
            ui.capacity:setText("Space: " .. (diskManager.capacity / 1000000) .. "MB")

            for i = ui.list:getItemCount(), 1, -1 do
                ui.list:removeItem(i)
            end
            local labels = diskManager:getDiskLabels()
            for i,v in ipairs(labels) do
                ui.list:addItem(v)
            end
        end)

        ui.back_button = lib.uiHelper.newButton(frame, "Back", 38, 16, 6, 3, colors.blue, colors.white, 
        function(s, event, button, x, y)
            panels[2]:build()
            previous() 
        end)
        ui.back_button:setBorder(colors.white, "bottom")

        ui.next_button = lib.uiHelper.newButton(frame, "Next", 45, 16, 6, 3, colors.blue, colors.white,
        function(s, event, button, x, y)
            local status = self:validate()
            if status ~= 0 then
                popUp(frame, status, "error")
            else
                panels[4]:build()
                next()
            end
        end)
        ui.next_button:setBorder(colors.white, "bottom")
    end,
    validate = function(self)
        diskManager:scan()
        if diskManager.capacity < 1250000 then
            return "Not enough space! Minimum: 1.25MB, Recommended: 2,5MB (~20 disks)"
        end
        return 0
    end
}
-- SETTINGS FRAME --------------------------------------------------------------------------------------------------------





-- FINAL FRAME -----------------------------------------------------------------------------------------------------------
panels[4] = {
    data = {},
    ui = {},
    frame = createFrame(),
    build = function(self)
        local data, ui, frame = self.data, self.ui, self.frame
        ui.str1 = lib.uiHelper.newLabel(frame, "Thanks for using", 3, 2, 4, 45, colors.white, colors.blue, 2)
        ui.str2 = lib.uiHelper.newLabel(frame, "GuardLink \3", 3, 7, 4, 45, colors.white, colors.blue, 2)

        ui.back_button = lib.uiHelper.newButton(frame, "Back", 36, 16, 6, 3, colors.blue, colors.white, 
        function(s, event, button, x, y)
            panels[3]:build()
            previous() 
        end)
        ui.back_button:setBorder(colors.white, "bottom")

        ui.next_button = lib.uiHelper.newButton(frame, "Finish", 43, 16, 8, 3, colors.blue, colors.white,
        function(s, event, button, x, y)
            runbasalt = false
        end)
        ui.next_button:setBorder(colors.white, "bottom")
    end,
    validate = function(self)

    end
}
-- FINAL FRAME -----------------------------------------------------------------------------------------------------------

local function wipePC()
    term.setTextColor(colors.red)
    local x,y = term.getSize()
    if x ~= 51 then error("You cannot install GuardLink server on a pocket computer!") end
    print("Computer will be wiped. Proceed with install? Y/N:")
    local input = read()
    if input ~= "Y" and input ~= "y" then return end
    local files = fs.list("/")
    for i = 1, #files do
        if files[i] ~= "rom" and files[i]:sub(1,4) ~= "disk" then fs.delete(files[i]) end
    end
    term.setTextColor(colors.white)
    print("Done! Creating config folder...")
    fs.makeDir("/GuardLink/server/config")
end

local function finishInstall()
    term.clear()
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1,1)
    wipePC()
    print("Getting latest release...")
    local raw = load(http.get(fileUrl).readAll(), "guardlink_server", "t", _G)()
    local marker = "%-%-%[%[__BLOB_START__%]%]%-%-"
    local splitStart, splitEnd = raw:find(marker)
    assert(splitStart, "Blob marker not found!")    
    local luaPart = raw:sub(1, splitStart - 1)
    local blob = raw:sub(splitEnd + 1)
    local package = load(luaPart)()
    local indexed = {}
    for k,v in pairs(package.files) do
        indexed[v.index + 1] = {info = v, path = k}
    end
    local pos = 1
    for i = 1, #indexed do
        local entry = indexed[i]
        if entry then
            local v, k = entry.info, entry.path
            local filePath = "GuardLink/" .. k
            local dir = filePath:match("(.*/)")
            if dir then fs.makeDir(dir) end

            local f = fs.open(filePath, "wb")
            if v.compression == false then
                f.write(v.str)
            else
                local startPos = pos
                local endPos = pos + v.length - 1
                f.write(blob:sub(startPos, endPos))
                pos = endPos + 1
            end
            f.close()
            print("Created file: " .. k)
        end
    end    

    diskManager:scan()
    print("Found " .. diskManager:diskCount() .. " disks")
    print("Creating partitions...")

    local partitions = {
        whitelist = diskManager:getDiskLabels(),
        layout = lib.settings.server.partitions
    }
    diskManager:partition(partitions)
    print("Partition config saved under " .. diskManager.configPath)

    local settings = {
        session = lib.settings.server.session,
        clients = lib.settings.server.clients,
        queue = lib.settings.server.queue,
        theme = panels[3].data.theme,
        debug = panels[3].data.debug
    }
    lib.fileUtils.newFile(lib.settings.server.settingsPath)
    lib.fileUtils.write(lib.settings.server.settingsPath, textutils.serialize(settings))
    print("Settings saved under " .. lib.settings.server.settingsPath)

    local manifest = {}
    for k,v in pairs(package) do
        if k ~= "files" then
            manifest[k] = v
        end
    end
    lib.fileUtils.newFile(lib.settings.server.manifestPath)
    lib.fileUtils.write(lib.settings.server.manifestPath, textutils.serializeJSON(manifest))
    print("Manifest saved under " .. lib.settings.server.manifestPath)

    print("Generating nation identity...")
    local nation = {
        nation_name = panels[2].data.nation_name,
        nation_tag = panels[2].data.nation_tag,
        selectedEthic = panels[2].data.selectedEthic,
        currency_name = panels[2].data.currency_name,
        starting_balance = panels[2].data.balance,
        nation_trade = panels[2].data.tradeCheck,
        roles = panels[2].data.roles
    }
    lib.fileUtils.newFile(lib.settings.server.identityPath)
    lib.fileUtils.write(lib.settings.server.identityPath, textutils.serialize(nation))

    lib.fileUtils.newFile(lib.settings.server.rulesPath)
    lib.fileUtils.write(lib.settings.server.rulesPath, textutils.serialize(lib.settings))
    term.setTextColor(colors.green)
    print("Done! Reboot required")
end

local function runInstaller()
    parallel.waitForAny(lib.basalt.autoUpdate, function() while runbasalt do os.sleep(0) end end)
    finishInstall()
end


panels[1]:build()
next()

term.setPaletteColor(colors.red, 0xff0000)
term.setPaletteColor(colors.blue, 0x2563EB)
term.setPaletteColor(colors.pink, 0xF7F8F8)
term.setPaletteColor(colors.white, 0xf2f8fb)
term.setPaletteColor(colors.gray, 0x767e7c)
term.setPaletteColor(colors.lightGray, 0xd1d2de)
term.setPaletteColor(colors.green, 0x4CAF50)
term.setPaletteColor(colors.black, 0x2B2F36)

-- COLORS FOR THEME
term.setPaletteColor(colors.orange, 0xFFFFFF)
term.setPaletteColor(colors.magenta, 0xFFFFFF)
term.setPaletteColor(colors.lightBlue, 0xFFFFFF)
term.setPaletteColor(colors.yellow, 0xFFFFFF)
term.setPaletteColor(colors.lime, 0xFFFFFF)
term.setPaletteColor(colors.cyan, 0xFFFFFF)
term.setPaletteColor(colors.purple, 0xffffff)
term.setPaletteColor(colors.brown, 0xffffff)

runInstaller()
