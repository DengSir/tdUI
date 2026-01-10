-- AddonMicro.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/15/2020, 3:49:17 PM
---@type ns
local ns = select(2, ...)

local function AtlasLootMicro(key)
    local AtlasLoot = _G[key]
    local L = AtlasLoot.Locales
    local SlashCommands = AtlasLoot.SlashCommands

    local Minimap = LibStub('LibDataBroker-1.1'):GetDataObjectByName(key)

    ns.CreateMicroButton {
        text = 'AtlasLoot',
        keybinding = 'ATLASLOOT_TOGGLE',
        template = 'EJ',
        frame = _G['AtlasLoot_GUI-Frame'],
        after = 'LFGMicroButton',
        onClick = Minimap.OnClick,
    }
end

ns.addon('AtlasLootClassic', function()
    AtlasLootMicro('AtlasLootClassic')
end)
ns.addon('AtlasLootMY', function()
    AtlasLootMicro('AtlasLootMY')
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

-- if not WorldMapMicroButton then
--     ns.CreateMicroButton {
--         text = WORLDMAP_BUTTON,
--         keybinding = 'TOGGLEWORLDMAP',
--         template = 'World',
--         frame = WorldMapFrame,
--         after = 'SocialsMicroButton',
--         onClick = ToggleWorldMap,
--         hideInOverrideBar = true,
--     }
-- end
