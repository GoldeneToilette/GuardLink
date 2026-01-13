term.setTextColor(colors.red)
print("Computer will be wiped. Proceed with install? Y/N:")
local input = read()
if input ~= "Y" and input ~= "y" then return end
local files = fs.list("/")
for i = 1, #files do
    if files[i] ~= "rom" and files[i]:sub(1,4) ~= "disk" then fs.delete(files[i]) end
end

fs.makeDir("/GuardLink/server/config")

local request = http.get("https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/basalt.lua")
local code = load(request.readAll(), "basalt", "t", _G)
local basalt = code()

request = http.get("https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/uiHelper.lua")
code = load(request.readAll(), "uiHelper", "t", _G)
local uiHelper = code()

request = http.get("https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/pixelbox_lite.lua")
code = load(request.readAll(), "pixelbox", "t", _G)
local pixelbox = code()

local frame = basalt.createFrame():setVisible(true)
local timeline = uiHelper.newLabel(frame, "  \45   \45   \45   \45   \45  ", 1, 1, 51, 1, colors.lightGray, colors.gray, 1) 

local function createFrame(scrollable)
    local f = scrollable and frame:addScrollableFrame() or frame:addFrame()
    return f:setSize("parent.w", "parent.h - 1"):setPosition(1, 2):setBackground(colors.white):setVisible(false)
end
local function createLabel(x)
    return uiHelper.newLabel(frame, "\186", x, 1, 1, 1, colors.lightGray, colors.gray, 1)
end

local steps = {
    start = {frame = createFrame()},
    nation = {frame = createFrame(true), finished = false, data = {}, label = createLabel(1)},
    economy = {frame = createFrame(), finished = false, data = {}, label = createLabel(5)},
    core = {frame = createFrame(), finished = false, data = {}, label = createLabel(9)},
    partitions = {frame = createFrame(), finished = false, data = {}, label = createLabel(13)},
    features = {frame = createFrame(), finished = false, data = {}, label = createLabel(17)},
    final = {frame = createFrame(), finished = false, data = {}, label = createLabel(21)}
}
local activeStep = ""

local function setActive(name)
    if activeStep ~= "" then 
        steps[activeStep].frame:setVisible(false)
        if steps[activeStep].label then
            steps[activeStep].label:setForeground(colors.gray)
        end
    end
    if steps[name].label then steps[name].label:setForeground(colors.green) end
    
    steps[name].frame:setVisible(true)
    activeStep = name
end

-- START FRAME ---------------------------------------------------------------------------------------------------------
local start_label = uiHelper.newLabel(steps["start"].frame, "Welcome to GuardLink Setup!", 2, 2, 27, 1, colors.white, colors.blue, 1)
local start_pane = uiHelper.newPane(steps["start"].frame, 32, 2, 19, 15, colors.lightGray)
:setBorder(colors.gray, "left")

local start_text = uiHelper.newLabel(steps["start"].frame, 
"1.Nation          2.Economy         3.Core Settings   4.Partitions      5.RP Features     6.Final", 33, 3, 18, 9, colors.lightGray, colors.gray)

local start_button = uiHelper.newButton(steps["start"].frame, "Start", 43, 13, 7, 3, colors.gray, colors.white, 
function(self, event, button, x, y)
    setActive("nation")
end)

-- i DONT know how the spinning cube works
local function spinningCube(box)local cx,cy=box.width/2,box.height/2;local scale=math.min(box.width,box.height)/3.7;local baseSpeed=0.05;local verts={{-1,-1,-1},{1,-1,-1},{1,1,-1},{-1,1,-1},{-1,-1,1},{1,-1,1},{1,1,1},{-1,1,1}}local edges={{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}local rotX,rotY=0,0;while true do box:clear(colors.white)local projected={}for i,v in ipairs(verts)do local x,y,z=v[1],v[2],v[3]local y1=y*math.cos(rotX)-z*math.sin(rotX)local z1=y*math.sin(rotX)+z*math.cos(rotX)local x2=x*math.cos(rotY)-z1*math.sin(rotY)projected[i]={cx+x2*scale,cy+y1*scale}end;for _,e in ipairs(edges)do local v1,v2=projected[e[1]],projected[e[2]]local x1,y1=math.floor(v1[1]),math.floor(v1[2])local x2,y2=math.floor(v2[1]),math.floor(v2[2])local dx,dy=math.abs(x2-x1),math.abs(y2-y1)local sx,sy=x1<x2 and 1 or-1,y1<y2 and 1 or-1;local err=dx-dy;while true do if x1>=1 and x1<=box.width and y1>=1 and y1<=box.height then box.canvas[y1][x1]=colors.blue end;if x1==x2 and y1==y2 then break end;local e2=err*2;if e2>-dy then err=err-dy;x1=x1+sx end;if e2<dx then err=err+dx;y1=y1+sy end end end;box:render()local t=os.clock()local speed=baseSpeed*(0.85+0.15*math.sin(t*0.8))rotX=rotX+speed;rotY=rotY+speed*0.7;os.sleep(0.05)end end
local start_animation = steps["start"].frame:addProgram():setSize(25, 14):setPosition(3, 5)
:execute(function()
    local box = pixelbox.new(term.current())
    spinningCube(box)
end)
-- START FRAME ---------------------------------------------------------------------------------------------------------





-- NATION FRAME --------------------------------------------------------------------------------------------------------
local nation_pane = uiHelper.newPane(steps["nation"].frame, 2, 2, 20, 16, colors.lightGray)
local nation_label = uiHelper.newLabel(steps["nation"].frame, "Name:", 3, 3, 5, 1, colors.lightGray, colors.black, 1)
local nation_name_label = uiHelper.newTextfield(steps["nation"].frame, 12, 3, 9, 1, colors.gray, colors.white)

-- NATION FRAME --------------------------------------------------------------------------------------------------------
setActive("start")

term.setPaletteColor(colors.blue, 0x2563EB)
term.setPaletteColor(colors.pink, 0xF7F8F8)
term.setPaletteColor(colors.white, 0xf2f8fb)
term.setPaletteColor(colors.gray, 0x767e7c)
term.setPaletteColor(colors.lightGray, 0xd1d2de)
term.setPaletteColor(colors.green, 0x4CAF50)
term.setPaletteColor(colors.black, 0x2B2F36)

basalt.autoUpdate()
