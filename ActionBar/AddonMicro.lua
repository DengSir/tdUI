-- AddonMicro.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/15/2020, 3:49:17 PM

---@type ns
local ns = select(2, ...)

ns.addon('AtlasLootClassic', function()
    local L = AtlasLoot.Locales
    local SlashCommands = AtlasLoot.SlashCommands

    local button = ns.CreateMicroButton(WorldMapMicroButton, L['AtlasLoot'] or 'AtlasLoot', 'ATLASLOOT_TOGGLE',
                                        _G['AtlasLoot_GUI-Frame'])
    LoadMicroButtonTextures(button, 'EJ')

    button:SetScript('OnClick', function()
        return SlashCommands:Run('')
    end)
end)

local function OnMouseDown(button)
    button.icon:SetTexCoord(0.2666, 0.8666, 0, 0.8333)
    button.icon:SetAlpha(0.5)
end

local function OnMouseUp(button)
    button.icon:SetTexCoord(0.2, 0.8, 0.0666, 0.9)
    button.icon:SetAlpha(1.0)
end

local function SetButtonState(button, state)
    if state and state:upper() == 'PUSHED' then
        OnMouseDown(button)
    else
        OnMouseUp(button)
    end
end

ns.addon('MeetingHorn', function()
    local Addon = LibStub('AceAddon-3.0'):GetAddon('MeetingHorn')
    local L = LibStub('AceLocale-3.0'):GetLocale('MeetingHorn')

    local button = ns.CreateMicroButton(WorldMapMicroButton, L.ADDON_NAME or 'MeetingHorn', 'MEETINGHORN_TOGGLE',
                                        MeetingHornMainPanel)

    button:SetNormalTexture([[Interface\Buttons\UI-MicroButtonCharacter-Up]])
    button:SetPushedTexture([[Interface\Buttons\UI-MicroButtonCharacter-Down]])
    button:SetDisabledTexture([[Interface\Buttons\UI-MicroButtonCharacter-Disabled]])
    button:SetHighlightTexture([[Interface\Buttons\UI-MicroButton-Hilight]])

    local icon = button:CreateTexture(nil, 'OVERLAY')
    icon:SetTexture([[Interface\LFGFrame\BattleNetworking0]])
    icon:SetSize(18, 25)
    icon:SetPoint('TOP', 0, -28)
    button.icon = icon

    button:SetScript('OnMouseDown', OnMouseDown)
    button:SetScript('OnMouseUp', OnMouseUp)
    ns.securehook(button, 'SetButtonState', SetButtonState)
    OnMouseUp(button)

    button:SetScript('OnClick', function()
        return Addon:Toggle()
    end)
end)
