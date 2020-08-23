-- TinyTooltip.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/15/2020, 1:38:59 PM

---@type ns
local ns = select(2, ...)

local type, pairs = type, pairs
local tinsert = table.insert

ns.addon('TinyTooltip', function()
    local LibEvent = LibStub:GetLibrary('LibEvent.7000')
    local TinyTooltip = TinyTooltip

    local tooltips = { --
        LibDBIconTooltip, --
        AceGUITooltip, --
        AceConfigDialogTooltip, --
        tdUIBonusFrame,
        function()
            local tdDropMenu = LibStub('tdGUI-1.0.Class.DropMenu', true)
            return tdDropMenu and tdDropMenu.Public
        end,
    }

    for _, tip in pairs(tooltips) do
        if type(tip) == 'function' then
            tip = tip()
        end
        tinsert(TinyTooltip.tooltips, tip)
    end

    local function UpdateStatusBarPosition()
        local g = TinyTooltip.db.general
        LibEvent:trigger('tooltip.statusbar.position', g.statusbarPosition, g.statusbarOffsetX, g.statusbarOffsetY)
    end

    GameTooltipStatusBar:HookScript('OnShow', function(bar)
        bar:GetScript('OnValueChanged')(bar, bar:GetValue())
        UpdateStatusBarPosition()
    end)
    GameTooltipStatusBar:HookScript('OnHide', UpdateStatusBarPosition)

    pcall(function()
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
