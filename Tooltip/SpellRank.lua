-- SpellRank.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/26/2020, 3:18:10 PM
--
---@type ns
local ns = select(2, ...)

local GetSpellSubtext = GetSpellSubtext

local r, g, b = GRAY_FONT_COLOR:GetRGB()

local function OnSet(tip, ...)
    local subtext = GetSpellSubtext(...)
    if subtext then
        local textRight = tip:GetFontStringRight(1)
        textRight:SetText(subtext)
        textRight:SetTextColor(r, g, b)
        textRight:Show()
        tip:Show()
    end
end

ns.securehook(GameTooltip, 'SetSpellByID', OnSet)
ns.securehook(GameTooltip, 'SetSpellBookItem', OnSet)
