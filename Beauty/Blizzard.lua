-- Blizzard.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/23/2020, 2:14:31 PM

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

Button(RaidFrameConvertToRaidButton)
Button(RaidFrameRaidInfoButton)

-- CharacterNameText:SetFontObject('GameFontNormal')
-- CharacterNameText:SetTextColor(1, 0.82, 0)
