-- Blizzard.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/23/2020, 2:14:31 PM
--
---@type ns
local ns = select(2, ...)

local function Button(button)
    button:SetNormalFontObject('GameFontNormal')
    button:SetHighlightFontObject('GameFontHighlight')
    button:SetDisabledFontObject('GameFontDisable')
end

Button(GuildFrameControlButton)
Button(GuildFrameAddMemberButton)
Button(GuildFrameGuildInformationButton)
Button(GuildInfoSaveButton)
Button(GuildInfoCancelButton)
Button(GuildMemberRemoveButton)
Button(GuildMemberGroupInviteButton)
Button(GuildInfoGuildEventButton)
Button(GuildEventLogCancelButton)

Button(RaidFrameConvertToRaidButton)
Button(RaidFrameRaidInfoButton)

ns.addon('Blizzard_RaidUI', function()
    Button(RaidFrameReadyCheckButton)
end)

UIPARENT_MANAGED_FRAME_POSITIONS['FramerateLabel'] = nil
ns.point(FramerateLabel, 'TOP', UIParent, 'TOP', 0, -10)
