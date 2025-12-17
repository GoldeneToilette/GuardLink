local ctx
local frame 

local function add()
    local f = ctx.mainframe:addFrame()
    :setSize("parent.w", "parent.h - 1")
    :setPosition(1,2)
    :setVisible(true)
    :setZIndex(1)
    frame = f
    local label = ctx.uiHelper.newLabel(frame, "This works! :D", 3, 4, nil, 1, colors.black, colors.orange, 1)
end

local function remove()
    frame:setVisible(false)
    frame:remove()
end

local function setContext(ui)
    ctx = ui
end

return {
    displayName = "Some UI?",
    add = add,
    remove = remove,
    setContext = setContext
}