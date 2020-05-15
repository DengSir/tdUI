-- TinyTooltip.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/15/2020, 1:38:59 PM

local ns = select(2, ...)

ns.addon('TinyTooltip', function()
    local function register(tooltip)
        print(tooltip)
        if tooltip then
            tinsert(TinyTooltip.tooltips, tooltip)
        end
    end

    register(LibDBIconTooltip)
    register(AceGUITooltip)
    register(AceConfigDialogTooltip)
end)
