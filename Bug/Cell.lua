-- Cell.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/29/2024, 7:35:00 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Cell', function()
    local SetFont = Cell.iFuncs.SetFont

    Cell.iFuncs.SetFont = function(fs, anchorTo, font, size, outline, shadow, anchor, xOffset, yOffset, color)
        SetFont(fs, anchorTo, font, size, outline, shadow, anchor, xOffset, yOffset, color)
        if shadow then
            fs:SetShadowOffset(1, -1)
            fs:SetShadowColor(0, 0, 0, 1)
        else
            fs:SetShadowOffset(0, 0)
            fs:SetShadowColor(0, 0, 0, 0)
        end
    end
end)
