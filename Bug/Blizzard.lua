-- Blizzard.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 3/23/2025, 8:42:24 PM
--
---@type ns
local ns = select(2, ...)

if SettingsTooltip then
    SettingsTooltip:SetParent(UIParent)
    SettingsTooltip:SetFrameStrata('TOOLTIP')
end

QuestMapFrame:HookScript('OnShow', function(self)
    self:RegisterEvent('CVAR_UPDATE')
end)

QuestMapFrame:HookScript('OnHide', function(self)
    self:UnregisterEvent('CVAR_UPDATE')
end)

QuestMapFrame:UnregisterEvent('CVAR_UPDATE')
