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

local function spinningDodecahedron(box)
    local cx, cy = box.width / 2, box.height / 2
    local scale = math.min(box.width, box.height) / 6
    local speed = 0.03

    -- Dodecahedron vertices
    local phi = (1 + math.sqrt(5)) / 2
    local a, b = 1, 1/phi
    local verts = {
        {-a, -a, -a}, {-a, -a, a}, {-a, a, -a}, {-a, a, a},
        {a, -a, -a}, {a, -a, a}, {a, a, -a}, {a, a, a},
        {0, -b, -phi}, {0, -b, phi}, {0, b, -phi}, {0, b, phi},
        {-b, -phi, 0}, {-b, phi, 0}, {b, -phi, 0}, {b, phi, 0},
        {-phi, 0, -b}, {phi, 0, -b}, {-phi, 0, b}, {phi, 0, b}
    }

    -- Edges (vertex indices)
    local edges = {
        {1,3},{1,5},{1,13},{1,17},{1,9},
        {2,4},{2,6},{2,14},{2,19},{2,10},
        {3,7},{3,11},{3,17},
        {4,8},{4,12},{4,19},
        {5,7},{5,15},{5,9},
        {6,8},{6,16},{6,10},
        {7,11},{7,15},
        {8,12},{8,16},
        {9,15},{9,13},
        {10,16},{10,14},
        {11,17},{11,12},
        {12,18},
        {13,19},{13,14},
        {14,20},
        {15,20},
        {16,20},
        {17,18},
        {18,19},
        {19,20}
    }

    local rotX, rotY = 0, 0

    while true do
        box:clear(0xFFFFFF) -- white background
        local projected = {}

        for i, v in ipairs(verts) do
            local x1, y1, z1 = v[1], v[2]*math.cos(rotX)-v[3]*math.sin(rotX), v[2]*math.sin(rotX)+v[3]*math.cos(rotX)
            local x2, y2, z2 = x1*math.cos(rotY)-z1*math.sin(rotY), y1, x1*math.sin(rotY)+z1*math.cos(rotY)
            projected[i] = {cx + x2*scale, cy + y2*scale}
        end

        for _, e in ipairs(edges) do
            local v1, v2 = projected[e[1]], projected[e[2]]
            local x1, y1, x2, y2 = math.floor(v1[1]), math.floor(v1[2]), math.floor(v2[1]), math.floor(v2[2])
            local dx, dy = math.abs(x2-x1), math.abs(y2-y1)
            local sx, sy = x1<x2 and 1 or -1, y1<y2 and 1 or -1
            local err = dx - dy
            while true do
                if x1>=1 and x1<=box.width and y1>=1 and y1<=box.height then
                    box.canvas[y1][x1] = colors.blue
                end
                if x1==x2 and y1==y2 then break end
                local e2 = 2*err
                if e2 > -dy then err = err - dy; x1 = x1 + sx end
                if e2 < dx then err = err + dx; y1 = y1 + sy end
            end
        end

        box:render()
        rotX = rotX + speed
        rotY = rotY + speed*0.5
        os.sleep(0.05)
    end
end


-- START FRAME ---------------------------------------------------------------------------------------------------------
local start_label = uiHelper.newLabel(steps["start"].frame, "Welcome to GuardLink Setup!", 2, 2, 27, 1, colors.white, colors.blue, 1)
-- START FRAME ---------------------------------------------------------------------------------------------------------

setActive("start")

term.setPaletteColor(colors.blue, 0x2563EB)
term.setPaletteColor(colors.pink, 0xF7F8F8)
term.setPaletteColor(colors.white, 0xf6f7f8)
term.setPaletteColor(colors.gray, 0x979e9c)
term.setPaletteColor(colors.lightGray, 0xd6d9d8)

basalt.autoUpdate()
