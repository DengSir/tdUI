-- RaidUnit.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/4/2026, 4:47:18 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_CompactRaidFrames', function()
    ---@param frame Frame
    ns.securehook('CompactUnitFrame_SetUpFrame', function(frame)
        if not frame.groupType then
            return
        end

        frame.healthBar:GetStatusBarTexture():SetTexture([[Interface\AddOns\!!!tdUI\Media\Statusbar_Clean.blp]])
    end)
end)
