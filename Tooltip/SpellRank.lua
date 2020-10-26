-- SpellRank.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/26/2020, 3:18:10 PM
--
---@type ns
local ns = select(2, ...)

local GetSpellBookItemInfo = GetSpellBookItemInfo
local GetSpellBookItemName = GetSpellBookItemName

local r, g, b = GRAY_FONT_COLOR:GetRGB()

local GetSpellRank = ns.memorize(function(spellId)
    local i = 1
    while true do
        local _, id = GetSpellBookItemInfo(i, 1)
        if not id then
            break
        end
        if id == spellId then
            local name, subName = GetSpellBookItemName(i, 1)
            if subName and subName ~= '' then
                return subName
            end
            break
        end
        i = i + 1
    end
    return false
end)

ns.securehook(GameTooltip, 'SetSpellByID', function(tip, spellId)
    local rank = GetSpellRank(spellId)
    if rank then
        local textRight = tip:GetFontStringRight(1)
        textRight:SetText(rank)
        textRight:SetTextColor(r, g, b)
        textRight:Show()
        tip:Show()
    end
end)
