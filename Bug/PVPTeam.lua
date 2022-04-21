-- PVPTeam.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/17/2022, 11:00:11 PM
--
---@type ns
local ns = select(2, ...)

ns.securehook('PVPTeam_Update', function()
    for i = 1, MAX_ARENA_TEAMS do
        if not _G['PVPTeam' .. i .. 'Data']:IsShown() then
            _G['PVPTeam' .. i]:Disable()
        else
            _G['PVPTeam' .. i]:Enable()
        end
    end
end)

RaidInfoInstance10:SetPoint('TOPLEFT', RaidInfoInstance9, 'BOTTOMLEFT', 0, 5)
