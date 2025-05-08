local cords, xDestination, yDestination = os.pullEvent("cords")

local box = require("/GuardLink/client/lib/pixelbox_lite").new(term.current())

box:load_module{
    require("/GuardLink/client/lib/pb_nfprnd")
}

local compass_images = {
    north = box.nfprnd.load.file("/GuardLink/client/programs/compass_nfp/compass_NORTH.nfp"),
    northeast = box.nfprnd.load.file("/GuardLink/client/programs/compass_nfp/compass_NORTHEAST.nfp"),
    east = box.nfprnd.load.file("/GuardLink/client/programs/compass_nfp/compass_EAST.nfp"),
    southeast = box.nfprnd.load.file("/GuardLink/client/programs/compass_nfp/compass_SOUTHEAST.nfp"),
    south = box.nfprnd.load.file("/GuardLink/client/programs/compass_nfp/compass_SOUTH.nfp"),
    southwest = box.nfprnd.load.file("/GuardLink/client/programs/compass_nfp/compass_SOUTHWEST.nfp"),
    west = box.nfprnd.load.file("/GuardLink/client/programs/compass_nfp/compass_WEST.nfp"),
    northwest = box.nfprnd.load.file("/GuardLink/client/programs/compass_nfp/compass_NORTHWEST.nfp"),
}

local w, h = term.getSize()
box:resize(w, h)

while true do
    local x, y, z = gps.locate()
    if x and z then
        x = math.floor(x)
        z = math.floor(z)
    else
        print("couldnt find position")
        break
    end

    local dx = xDestination - x
    local dz = yDestination - z

    local angle = math.deg(math.atan2(dz, dx))
    if angle < 0 then
        angle = angle + 360
    end

    local direction
    if angle >= 337.5 or angle < 22.5 then
        direction = "east"
    elseif angle >= 22.5 and angle < 67.5 then
        direction = "northeast"
    elseif angle >= 67.5 and angle < 112.5 then
        direction = "north"
    elseif angle >= 112.5 and angle < 157.5 then
        direction = "northwest"
    elseif angle >= 157.5 and angle < 202.5 then
        direction = "west"
    elseif angle >= 202.5 and angle < 247.5 then
        direction = "southwest"
    elseif angle >= 247.5 and angle < 292.5 then
        direction = "south"
    elseif angle >= 292.5 and angle < 337.5 then
        direction = "southeast"
    end

    if direction then
        box.nfprnd.blit_at(1, 1, compass_images[direction], box.width, box.height)
    end

    box:render()
end
