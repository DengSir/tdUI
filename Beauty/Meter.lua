-- Meter.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/14/2026, 4:51:19 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_DamageMeter', function()
    ns.securehook(DamageMeterEntryMixin, 'UpdateStyle', function(self)
        local statusBar = self:GetStatusBar()
        statusBar:GetStatusBarTexture():SetTexture([[Interface\AddOns\tdUI\Media\TargetingFrame\UI-StatusBar.blp]])

        for _, v in ipairs(self:GetBackgroundRegions()) do
            ns.hide(v)
        end
    end)
end)
