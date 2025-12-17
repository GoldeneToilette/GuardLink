local errors   = require "lib.errors"

local uiState = {}
uiState.__index = uiState
-- width: 51, height: 19

function uiState.new(framepath)
    local self = setmetatable({}, uiState)
    self.basalt = require("lib.basalt")
    self.uiHelper = require("lib.uiHelper")
    self.path = framepath or "/GuardLink/server/ui/" 
    self.x, self.y = term.getSize()
    self.mainframe = self.basalt.createFrame():setVisible(true):setZIndex(2)
    self.frames = {}
    self.activeFrame = nil

    self.titleBar = self.uiHelper.newLabel(self.mainframe, "GLB 1.0.1", 1, 1, 51, 1, colors.blue, colors.white, 1)
    self.dropdown = self.mainframe:addDropdown()
    :setForeground(colors.white)
    :setBackground(colors.blue)
    :setPosition(1, 1)
    :setSelectionColor(colors.blue, colors.orange)
    
    self.exitButton = self.uiHelper.newButton(self.mainframe, "X", 51, 1, 1, 1, colors.blue, colors.red)
    self.exitButton:onClick(function(_, event, button, x, y)
        os.shutdown()
    end)

    for _, v in ipairs(fs.list(self.path)) do
        local name = v:gsub("%.lua$", "")
        local m = require(self.path .. name)
        m.setContext(self)
        
        self.frames[name] = m
        self.dropdown:addItem(m.displayName, colors.blue, colors.white, name)
    end

    self.dropdown:onChange(function(_, event, item)
        local result = self:setFrame(item.args[1])
        if result ~= 0 then
            self.uiHelper.newPopup(self.mainframe, 25, 5, "Error", "error", "UI not found! :(", true)
        end
    end)

    local result = self:setFrame("shell")
    if result ~= 0 then self.uiHelper.newPopup(self.mainframe, 25, 5, "Error", "error", "UI not found! :(", true) end
    return self
end

function uiState:run()
    _G.utils.tryCatch(
        function()
            self.basalt.autoUpdate()
        end,
        function(err, stackTrace)
            _G.logger:fatal("[uiState] Basalt died.")
            _G.logger:error("[uiState] Error:" .. err)
            error(err)
        end        
    )
end

function uiState:setFrame(name)
    if not self.frames[name] then return errors.UNKNOWN_UI end
    if self.activeFrame then self.activeFrame.remove() end
    self.activeFrame = self.frames[name]
    self.frames[name].add(self)
    return 0
end

return uiState

