-- AddonMicro.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/15/2020, 3:49:17 PM
---@type ns
local ns = select(2, ...)

ns.addon('AtlasLootClassic', function()
    local L = AtlasLoot.Locales
    local SlashCommands = AtlasLoot.SlashCommands

    ns.CreateMicroButton {
        text = L['AtlasLoot'] or 'AtlasLoot',
        keybinding = 'ATLASLOOT_TOGGLE',
        template = 'EJ',
        frame = _G['AtlasLoot_GUI-Frame'],
        after = 'LFGMicroButton',
        onClick = function()
            return SlashCommands:Run('')
        end,
    }
end)

ns.addon('MeetingHorn', function()
    local Addon = LibStub('AceAddon-3.0'):GetAddon('MeetingHorn')
    local L = LibStub('AceLocale-3.0'):GetLocale('MeetingHorn')

    ns.CreateMicroButton {
        text = L.ADDON_NAME or 'MeetingHorn',
        keybinding = 'MEETINGHORN_TOGGLE',
        icon = [[Interface\AddOns\MeetingHorn\Media\Logo]],
        -- template = 'LFG',
        frame = Addon.MainPanel,
        after = 'LFGMicroButton',
        onClick = function()
            return Addon:Toggle()
        end,
    }
end)
