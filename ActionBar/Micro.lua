-- Micro.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/15/2020, 3:49:17 PM

---@type ns
local ns = select(2, ...)

ns.addon('MeetingHorn', function()
    local Addon = LibStub('AceAddon-3.0'):GetAddon('MeetingHorn')
    local L = LibStub('AceLocale-3.0'):GetLocale('MeetingHorn')

    local button = ns.CreateMicroButton(SocialsMicroButton, L.ADDON_NAME or 'MeetingHorn', 'MEETINGHORN_TOGGLE',
                                        MeetingHornMainPanel)

    LoadMicroButtonTextures(button, 'LFG')

    button:SetScript('OnClick', function()
        return Addon:Toggle()
    end)
end)

ns.addon('AtlasLootClassic', function()
    local L = AtlasLoot.Locales
    local SlashCommands = AtlasLoot.SlashCommands

    local button = ns.CreateMicroButton(SocialsMicroButton, L['AtlasLoot'] or 'AtlasLoot', 'ATLASLOOT_TOGGLE',
                                        _G['AtlasLoot_GUI-Frame'])
    LoadMicroButtonTextures(button, 'EJ')

    button:SetScript('OnClick', function()
        return SlashCommands:Run('')
    end)
end)
