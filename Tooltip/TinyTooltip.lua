-- TinyTooltip.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/15/2020, 1:38:59 PM

---@type ns
local ns = select(2, ...)

ns.addon('TinyTooltip', function()
    local function register(tooltip)
        if tooltip then
            tinsert(TinyTooltip.tooltips, tooltip)
        end
    end

    register(LibDBIconTooltip)
    register(AceGUITooltip)
    register(AceConfigDialogTooltip)

    local tdDropMenu = LibStub('tdGUI-1.0.Class.DropMenu', true)
    if tdDropMenu then
        register(tdDropMenu.Public)
    end

    pcall(function()
        local LibEvent = LibStub:GetLibrary('LibEvent.7000')

        local emptyObject = setmetatable({}, {
            __index = function()
                return nop
            end,
        })

        local env = setmetatable({
            GameTooltipHeaderText = emptyObject,
            GameTooltipText = emptyObject,
            Tooltip_Small = emptyObject,
        }, {__index = _G})

        for i, v in ipairs(LibEvent.events.VARIABLES_LOADED) do
            setfenv(v, env)
        end
    end)
end)
