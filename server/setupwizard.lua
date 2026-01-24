local dep = {
    basalt = "https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/basalt.lua",
    uiHelper = "https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/uiHelper.lua",
    pixelbox = "https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/pixelbox_lite.lua",
    settings = "https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/settings.lua",
}

local lib = {}
for k,v in pairs(dep) do
  lib[k] = load(http.get(v).readAll(), k, "t", _G)()
end

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
    print("Done! Creating folders...")
    os.sleep(1)
    fs.makeDir("/GuardLink/server/config")
end

-- MAINFRAME IS CREATED HERE -------------------------------------------------------------------------------------------
local mainframe = lib.basalt.createFrame():setVisible(true)
local timeline = lib.uiHelper.newLabel(mainframe, "  \26   \26   \26   \26   \26  ", 1, 1, 51, 1, colors.lightGray, colors.gray, 1) 
local stepLabels = {}
local activeStep = 0
for i = 1, 21, 4 do
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
    if stepLabels and stepLabels[activeStep-1] then
        stepLabels[activeStep-1]:setForeground(colors.gray)
    end
    activeStep = activeStep - 1
    panels[activeStep].frame:setVisible(true)
end
-- MAINFRAME IS CREATED HERE -------------------------------------------------------------------------------------------





-- START FRAME ---------------------------------------------------------------------------------------------------------
panels[1] = {
    frame = createFrame(),
    build = function(self) 
        self.ui.title = lib.uiHelper.newLabel(self.frame, "Welcome to GuardLink Setup!", 1, 2, 28, 1, colors.white, colors.blue, 1)
        self.ui.pane = lib.uiHelper.newPane(self.frame, 32, 2, 19, 15, colors.lightGray)
        :setBorder(colors.gray, "left")

        self.ui.table = lib.uiHelper.newLabel(self.frame, 
        "1.Nation          2.Economy         3.Core Settings   4.Partitions      5.RP Features     6.Final", 
        33, 3, 18, 9, colors.lightGray, colors.gray)

        self.ui.button = lib.uiHelper.newButton(self.frame, "Start", 43, 13, 7, 3, colors.gray, colors.white, 
        function() 
            panels[2]:build()
            next() 
        end)

        local function spinningCube(box)local cx,cy=box.width/2,box.height/2;local scale=math.min(box.width,box.height)/3.7;local baseSpeed=0.05;local verts={{-1,-1,-1},{1,-1,-1},{1,1,-1},{-1,1,-1},{-1,-1,1},{1,-1,1},{1,1,1},{-1,1,1}}local edges={{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}local rotX,rotY=0,0;while true do box:clear(colors.white)local projected={}for i,v in ipairs(verts)do local x,y,z=v[1],v[2],v[3]local y1=y*math.cos(rotX)-z*math.sin(rotX)local z1=y*math.sin(rotX)+z*math.cos(rotX)local x2=x*math.cos(rotY)-z1*math.sin(rotY)projected[i]={cx+x2*scale,cy+y1*scale}end;for _,e in ipairs(edges)do local v1,v2=projected[e[1]],projected[e[2]]local x1,y1=math.floor(v1[1]),math.floor(v1[2])local x2,y2=math.floor(v2[1]),math.floor(v2[2])local dx,dy=math.abs(x2-x1),math.abs(y2-y1)local sx,sy=x1<x2 and 1 or-1,y1<y2 and 1 or-1;local err=dx-dy;while true do if x1>=1 and x1<=box.width and y1>=1 and y1<=box.height then box.canvas[y1][x1]=colors.blue end;if x1==x2 and y1==y2 then break end;local e2=err*2;if e2>-dy then err=err-dy;x1=x1+sx end;if e2<dx then err=err+dx;y1=y1+sy end end end;box:render()local t=os.clock()local speed=baseSpeed*(0.85+0.15*math.sin(t*0.8))rotX=rotX+speed;rotY=rotY+speed*0.7;os.sleep(0.05)end end
        self.ui.animation = self.frame:addProgram():setSize(25, 14):setPosition(3, 5)
        :execute(function()
            local box = lib.pixelbox.new(term.current())
            spinningCube(box)
        end)
    end,
    validate = function(self) 
        error("NOTHING TO VALIDATE; IF YOU SEE THIS SOMETHING BROKE")
    end,
    data = {},
    ui = {}
}
-- START FRAME ---------------------------------------------------------------------------------------------------------





-- NATION FRAME --------------------------------------------------------------------------------------------------------
panels[2] = {
    frame = createFrame(),
    build = function(self) 
        self.ui.pane = lib.uiHelper.newPane(self.frame, 2, 2, 21, 7, colors.lightGray)

        self.ui.nation_name = lib.uiHelper.newLabel(self.frame, "Name:", 3, 3, 5, 1, colors.lightGray, colors.gray, 1)
        self.ui.nation_field = lib.uiHelper.newTextfield(self.frame, 9, 3, 13, 1, colors.gray, colors.white)

        self.ui.tag_name = lib.uiHelper.newLabel(self.frame, "Tag (3 chars):", 3, 5, 14, 1, colors.lightGray, colors.gray, 1)
        self.ui.tag_field = lib.uiHelper.newTextfield(self.frame, 18, 5, 4, 1, colors.gray, colors.white)        

        self.ui.ethic_label = lib.uiHelper.newLabel(self.frame, "Ethic:", 3, 7, 6, 1, colors.lightGray, colors.gray, 1)
        self.ui.ethic_dropdown = self.frame:addDropdown()
        :setForeground(colors.white)
        :setBackground(colors.gray)
        :setPosition(10, 7)

        local fi = ""
        for k,v in pairs(lib.settings.rules.ethics) do
            if fi == "" then fi = k end
            self.ui.ethic_dropdown:addItem(v.name, colors.gray, colors.white, k)
        end

        if not self.data.selectedEthic then 
            self.data.selectedEthic = fi
        end

        for i = 1, self.ui.ethic_dropdown:getItemCount() do
            if self.ui.ethic_dropdown:getItem(i).args.k == self.data.selectedEthic then
                self.ui.ethic_dropdown:selectItem(i)
            end
        end

        self.ui.ethic_pane = lib.uiHelper.newPane(self.frame, 2, 10, 1, 3, colors.white):setBorder(colors.blue, "left")
        self.ui.ethic_desc = lib.uiHelper.newLabel(self.frame, lib.settings.rules.ethics[self.data.selectedEthic].description, 
        3, 10, 21, 3, colors.white, colors.gray)

        self.ui.ethic_dropdown:onChange(function(self, event, item)
            self.ui.ethic_desc:setText(lib.settings.rules.ethics[item.args[1]].description)
        end)

        self.ui.roles_button = lib.uiHelper.newButton(self.frame, "Manage Roles", 2, 15, 14, 3, colors.gray, colors.white, 
        function(self, event, button, x, y)
            basalt.debug("BUTTON GOT CLICKED;")
        end)
    end,
    validate = function(self)

    end,
    data = {},
    ui = {}
}
-- NATION FRAME --------------------------------------------------------------------------------------------------------

wipePC()
panels[1]:build()
next()

term.setPaletteColor(colors.blue, 0x2563EB)
term.setPaletteColor(colors.pink, 0xF7F8F8)
term.setPaletteColor(colors.white, 0xf2f8fb)
term.setPaletteColor(colors.gray, 0x767e7c)
term.setPaletteColor(colors.lightGray, 0xd1d2de)
term.setPaletteColor(colors.green, 0x4CAF50)
term.setPaletteColor(colors.black, 0x2B2F36)

lib.basalt.autoUpdate()
