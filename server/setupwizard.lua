term.setTextColor(colors.red)
print("Computer will be wiped. Proceed with install? Y/N:")
local input = read()
if input ~= "Y" and input ~= "y" then return end
local files = fs.list("/")
for i = 1, #files do
    if files[i] ~= "rom" then fs.delete(files[i]) end
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

local function createFrame()
    return frame:addFrame():setSize("parent.w", "parent.h - 1"):setPosition(1,2):setBackground(colors.white):setVisible(false)
end
local function createLabel(x)
    return uiHelper.newLabel(frame, "\186", x, 1, 1, 1, colors.lightGray, colors.gray, 1)
end

local steps = {
    start = {frame = createFrame()},
    nation = {frame = createFrame(), finished = false, data = {}, label = createLabel(1)},
    core = {frame = createFrame(), finished = false, data = {}, label = createLabel(5)},
    gps = {frame = createFrame(), finished = false, data = {}, label = createLabel(9)},
    disk = {frame = createFrame(), finished = false, data = {}, label = createLabel(13)},
    features = {frame = createFrame(), finished = false, data = {}, label = createLabel(17)},
    final = {frame = createFrame(), finished = false, data = {}, label = createLabel(21)}
}
local activeStep = ""

local function setActive(name)
    if activeStep ~= "" then 
        steps[activeStep].label:setForeground(colors.gray)
        steps[activeStep].frame:setVisible(false)
    end
    if name ~= "start" then steps[name].label:setForeground(colors.blue) end
    steps[name].frame:setVisible(true)
    activeStep = name
end

-- START FRAME ---------------------------------------------------------------------------------------------------------
local start_label = uiHelper.newLabel(steps["start"].frame, "Welcome to GuardLink Setup!", 2, 2, 27, 1, colors.white, colors.blue, 1)

-- i DONT know how the spinning cube works
local function spinningCube(box)local cx,cy=box.width/2,box.height/2;local scale=math.min(box.width,box.height)/3.7;local baseSpeed=0.05;local verts={{-1,-1,-1},{1,-1,-1},{1,1,-1},{-1,1,-1},{-1,-1,1},{1,-1,1},{1,1,1},{-1,1,1}}local edges={{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}local rotX,rotY=0,0;while true do box:clear(colors.white)local projected={}for i,v in ipairs(verts)do local x,y,z=v[1],v[2],v[3]local y1=y*math.cos(rotX)-z*math.sin(rotX)local z1=y*math.sin(rotX)+z*math.cos(rotX)local x2=x*math.cos(rotY)-z1*math.sin(rotY)projected[i]={cx+x2*scale,cy+y1*scale}end;for _,e in ipairs(edges)do local v1,v2=projected[e[1]],projected[e[2]]local x1,y1=math.floor(v1[1]),math.floor(v1[2])local x2,y2=math.floor(v2[1]),math.floor(v2[2])local dx,dy=math.abs(x2-x1),math.abs(y2-y1)local sx,sy=x1<x2 and 1 or-1,y1<y2 and 1 or-1;local err=dx-dy;while true do if x1>=1 and x1<=box.width and y1>=1 and y1<=box.height then box.canvas[y1][x1]=colors.blue end;if x1==x2 and y1==y2 then break end;local e2=err*2;if e2>-dy then err=err-dy;x1=x1+sx end;if e2<dx then err=err+dx;y1=y1+sy end end end;box:render()local t=os.clock()local speed=baseSpeed*(0.85+0.15*math.sin(t*0.8))rotX=rotX+speed;rotY=rotY+speed*0.7;os.sleep(0.05)end end
local start_animation = steps["start"].frame:addProgram():setSize(15, 8):setPosition(3, 5)
:execute(function()
    local box = pixelbox.new(term.current())
    spinningCube(box)
end)
-- START FRAME ---------------------------------------------------------------------------------------------------------

setActive("start")

term.setPaletteColor(colors.blue, 0x2563EB)
term.setPaletteColor(colors.pink, 0xF7F8F8)
term.setPaletteColor(colors.white, 0xf6f7f8)
term.setPaletteColor(colors.gray, 0x979e9c)
term.setPaletteColor(colors.lightGray, 0xd6d9d8)

basalt.autoUpdate()
