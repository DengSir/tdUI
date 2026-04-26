-- ActionBar.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2019, 3:15:18 PM
--
---@type ns
local ns = select(2, ...)

local ipairs, pairs = ipairs, pairs

local buttons = ActionBarButtonEventsFrame.frames

local function InitActionButton(button)
    button.HotKey:SetFontObject('NumberFontNormal')

    if button:GetWidth() < 40 then
        button.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
    end

    if button:GetWidth() < 35 then
        local s = button:GetWidth() / 36 * 15
        button.SlotBackground:ClearAllPoints()
        button.SlotBackground:SetPoint('TOPLEFT', button, 'TOPLEFT', -s, s)
        button.SlotBackground:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', s, -s)
        button.SlotBackground:Hide()

        button.NormalTexture:SetAlpha(1)
        button.NormalTexture:ClearAllPoints()
        button.NormalTexture:SetSize(54, 54)
        button.NormalTexture:SetPoint('CENTER', 0, -1)
        button.NormalTexture:SetTexture([[Interface\Buttons\UI-Quickslot2]])
        button.NormalTexture:SetTexCoord(0, 1, 0, 1)
        -- button:SetNormalTexture(button.NormalTexture)
    end

    if button.SlotBackground then
        button.SlotBackground:Hide()
    end
end

for _, v in ipairs(StanceBar.actionButtons) do
    InitActionButton(v)
    -- v.SlotBackground:Hide()
end

for _, button in ipairs(buttons) do
    InitActionButton(button)
end

for i = 1, NUM_PET_ACTION_SLOTS do
    InitActionButton(_G['PetActionButton' .. i])
end

local function ShowGrid()
    for _, button in pairs(buttons) do
        if button.Name then
            button.Name:Show()
        end
    end
end

local function HideGrid()
    for _, button in pairs(buttons) do
        if button.Name then
            button.Name:Hide()
        end
    end
end

local function CheckConfig()
    if ns.profile.actionbar.button.macroName then
        ShowGrid()
    else
        HideGrid()
    end
end

ns.event('ACTIONBAR_SHOWGRID', ShowGrid)
ns.event('ACTIONBAR_HIDEGRID', CheckConfig)

if ActionBarButtonEventsFrame_RegisterFrame then
    ns.securehook('ActionBarButtonEventsFrame_RegisterFrame', InitActionButton)
else
    ns.securehook(ActionBarButtonEventsFrame, 'RegisterFrame', InitActionButton)
end
ns.config('actionbar.button.macroName', CheckConfig)
ns.load(CheckConfig)
ns.login(CheckConfig)

EventRegistry:UnregisterCallback('MainActionBarMixin.UpdateEndCaps', BagsBar)

-- for _, button in ipairs {CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot} do
--     local name = button:GetName()

--     _G[name .. 'NormalTexture']:SetSize(64, 64)
--     button:SetSize(37, 37)
-- end

-- local ArtFrame = CreateFrame('Frame', nil, UIParent)
-- ArtFrame:SetPoint('BOTTOM')
-- ArtFrame:SetSize(512, 256)

-- local MainMenuBarArtLarge = ArtFrame:CreateTexture(nil, 'BACKGROUND')
-- MainMenuBarArtLarge:SetAtlas('hud-MainMenuBar-large', true)
-- MainMenuBarArtLarge:SetPoint('BOTTOM')
