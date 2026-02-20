local errors   = requireC("/GuardLink/server/lib/errors.lua")
local theme = requireC("/GuardLink/server/lib/themes.lua")
local utils = requireC("/GuardLink/server/lib/utils.lua")

local uiState = {}
uiState.__index = uiState
-- width: 51, height: 19

local log

function uiState.new(framepath, manifest, settings, logger)
    local self = setmetatable({}, uiState)
    theme = requireC("/GuardLink/server/lib/themes.lua")
    self.theme = theme
    theme.init()
    theme.setTheme(settings.theme)

    self.basalt = requireC("/GuardLink/server/lib/basalt.lua")
    self.uiHelper = requireC("/GuardLink/server/lib/uiHelper.lua")
    self.path = framepath or "/GuardLink/server/ui/" 
    self.x, self.y = term.getSize()
    self.mainframe = self.basalt.createFrame():setVisible(true):setZIndex(2)
    self.frames = {}
    self.activeFrame = nil

    log = logger:createInstance("uiState", {timestamp = true, level = "INFO", clear = true})

    self.titleBar = self.uiHelper.newLabel(self.mainframe, "", 1, 1, 51, 1, colors.blue, colors.white, 1)
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
        local m = requireC(self.path .. name .. ".lua")
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
    utils.tryCatch(
        function()
            self.basalt.autoUpdate()
        end,
        function(err, stackTrace)
            log:fatal("Basalt died.")
            log:error("Error:" .. err)
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

local service = {
    name = "ui_manager",
    deps = {},
    init = function(ctx)
        return uiState.new(nil, ctx.configs["manifest"], ctx.configs["settings"], ctx.services["logger"])
    end,
    runtime = function(self)
        self:run()
    end,
    tasks = nil,
    shutdown = nil,
    api = {
        ["ui"] = {
            frame_set = function(self, args) return self:setFrame(args) end,
            set_theme = function(self, args) return theme.setTheme(args) end,
            get_themes = function(self) return theme.getThemes() end,
            get_color = function(self, args) return theme.colors[args] end,
            get_theme = function(self, args) return theme.getTheme() end,
        }
    }
}

return service

