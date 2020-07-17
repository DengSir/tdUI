-- Micro.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/18/2020, 9:46:28 AM
--
---@type ns
local ns = select(2, ...)

local tinsert = table.insert
local unpack = table.unpack or unpack

local GetCVarBool = GetCVarBool
local GetNetStats = GetNetStats

local MicroButtonTooltipText = MicroButtonTooltipText

local GameTooltip = GameTooltip
local MainMenuMicroButton = MainMenuMicroButton
local MainMenuBarPerformanceBar = MainMenuBarPerformanceBar

local MAINMENUBAR_LATENCY_LABEL = MAINMENUBAR_LATENCY_LABEL
local MILLISECONDS_ABBR = MILLISECONDS_ABBR
local NEWBIE_TOOLTIP_LATENCY = NEWBIE_TOOLTIP_LATENCY

local MicroButtonAndBagsBar = CreateFrame('Frame', 'MicroButtonAndBagsBar', MainMenuBarArtFrame)
MicroButtonAndBagsBar:SetSize(26 * 8 + 12, 87)

local MICRO_LEFT_COORDS = {309 / 1024, 339 / 1024, 212 / 256, 255 / 256}
local MICRO_RIGHT_COORDS = {577 / 1024, 607 / 1024, 212 / 256, 255 / 256}
local MICRO_MIDDLE_COORDS = {339 / 1024, 577 / 1024, 212 / 256, 255 / 256}
local BAG_BG_COORDS = {423 / 1024, 607 / 1024, 167 / 256, 212 / 256}
local KEYRING_BG_COORDS = {423 / 1024, (423 + 24) / 1024, 167 / 256, 212 / 256}

local function GetCoords(coords, style)
    local left, right, top, bottom = unpack(coords)
    if style == 'LEFT' then
        return right, left, top, bottom
    end
    return left, right, top, bottom
end

local function point(frame, ...)
    frame:ClearAllPoints()
    frame:SetPoint(...)
end

local MicroLeft = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
MicroLeft:SetPoint('BOTTOMLEFT')
MicroLeft:SetTexture(1721259)
MicroLeft:SetSize(30, 43)

local MicroRight = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
MicroRight:SetPoint('BOTTOMRIGHT')
MicroRight:SetTexture(1721259)
MicroRight:SetSize(30, 43)

local MicroMiddle = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
MicroMiddle:SetPoint('TOPLEFT', MicroLeft, 'TOPRIGHT')
MicroMiddle:SetPoint('BOTTOMRIGHT', MicroRight, 'BOTTOMLEFT')
MicroMiddle:SetTexture(1721259)

local BagBg = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
BagBg:SetTexture(1721259)
BagBg:SetSize(607 - 423, 212 - 167)
BagBg:SetPoint('TOPRIGHT')

local KeyringBg = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND', nil, -1)
KeyringBg:SetTexture(1721259)
KeyringBg:SetSize(24, 212 - 167)

for i = 0, 3 do
    local frame = _G['CharacterBag' .. i .. 'Slot']
    frame:SetSize(30, 30)
    frame.IconBorder:SetSize(30, 30)
    frame:GetNormalTexture():SetSize(50, 50)
    frame:ClearAllPoints()
    if i == 0 then
        frame:SetPoint('RIGHT', MainMenuBarBackpackButton, 'LEFT', -4, -5)
    else
        frame:SetPoint('RIGHT', _G['CharacterBag' .. (i - 1) .. 'Slot'], 'LEFT', -2.5, 0)
    end
end

KeyRingButton:SetSize(14, 30)

CharacterMicroButton:SetParent(MicroButtonAndBagsBar)
SpellbookMicroButton:SetParent(MicroButtonAndBagsBar)
TalentMicroButton:SetParent(MicroButtonAndBagsBar)
QuestLogMicroButton:SetParent(MicroButtonAndBagsBar)
SocialsMicroButton:SetParent(MicroButtonAndBagsBar)
WorldMapMicroButton:SetParent(MicroButtonAndBagsBar)
MainMenuMicroButton:SetParent(MicroButtonAndBagsBar)
HelpMicroButton:SetParent(MicroButtonAndBagsBar)
MainMenuBarBackpackButton:SetParent(MicroButtonAndBagsBar)
CharacterBag0Slot:SetParent(MicroButtonAndBagsBar)
CharacterBag1Slot:SetParent(MicroButtonAndBagsBar)
CharacterBag2Slot:SetParent(MicroButtonAndBagsBar)
CharacterBag3Slot:SetParent(MicroButtonAndBagsBar)
KeyRingButton:SetParent(MicroButtonAndBagsBar)

MainMenuBarPerformanceBar:ClearAllPoints()
MainMenuBarPerformanceBar:SetParent(MainMenuMicroButton)
MainMenuBarPerformanceBar:SetSize(9.0625, 4.5)
MainMenuBarPerformanceBar:SetDrawLayer('OVERLAY')
MainMenuBarPerformanceBar:SetTexture([[Interface\BUTTONS\white8x8]])
MainMenuBarPerformanceBar:SetAlpha(0.6)
MainMenuBarPerformanceBarFrame:EnableMouse(false)

local function UpdatePerformanceBarPushed(self)
    if self:GetButtonState() == 'PUSHED' then
        MainMenuBarPerformanceBar:SetPoint('TOPLEFT', 9.0625, -35.34375 + 18)
        MainMenuBarPerformanceBar:SetAlpha(0.4)
    else
        MainMenuBarPerformanceBar:SetPoint('TOPLEFT', 9.96875, -33.53125 + 18)
        MainMenuBarPerformanceBar:SetAlpha(0.6)
    end
end

ns.securehook(MainMenuMicroButton, 'SetButtonState', UpdatePerformanceBarPushed)
ns.hookscript(MainMenuMicroButton, 'OnMouseDown', UpdatePerformanceBarPushed)
ns.hookscript(MainMenuMicroButton, 'OnMouseUp', UpdatePerformanceBarPushed)
ns.securehook('MicroButton_OnEnter', function(self)
    if self == MainMenuMicroButton and GameTooltip:IsOwned(self) then
        local newbie = GetCVarBool('showNewbieTips')
        local bandwidthIn, bandwidthOut, latency = GetNetStats()

        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(MAINMENUBAR_LATENCY_LABEL .. ' ' .. latency .. MILLISECONDS_ABBR, 1, 1, 1)
        if newbie then
            GameTooltip:AddLine(NEWBIE_TOOLTIP_LATENCY, 1, 0.82, 0, true)
        end
    end
end)

ns.securehook(MainMenuBarDownload, 'Show', function()
    MainMenuBarPerformanceBar:Hide()
end)
ns.securehook(MainMenuBarDownload, 'Hide', function()
    MainMenuBarPerformanceBar:Show()
end)

local function UpdateMicroBar(style)
    style = style or ns.profile.actionbar.micro.position
    if style == 'LEFT' then
        MicroLeft:SetTexCoord(GetCoords(MICRO_RIGHT_COORDS, style))
        MicroMiddle:SetTexCoord(GetCoords(MICRO_MIDDLE_COORDS, style))
        MicroRight:SetTexCoord(GetCoords(MICRO_LEFT_COORDS, style))
        BagBg:SetTexCoord(GetCoords(BAG_BG_COORDS, style))
        KeyringBg:SetTexCoord(GetCoords(KEYRING_BG_COORDS, style))
        point(BagBg, 'TOPLEFT')
        point(KeyringBg, 'BOTTOMLEFT', BagBg, 'BOTTOMRIGHT', -(24 - 16), 0)

        point(CharacterMicroButton, 'BOTTOMLEFT', MicroButtonAndBagsBar, 'BOTTOMLEFT', 4, 3)
        point(MainMenuBarBackpackButton, 'TOPLEFT', MicroButtonAndBagsBar, 'TOPLEFT', 6, -4)
        point(CharacterBag0Slot, 'LEFT', MainMenuBarBackpackButton, 'RIGHT', 4, -5)
        for i = 1, 3 do
            point(_G['CharacterBag' .. i .. 'Slot'], 'LEFT', _G['CharacterBag' .. (i - 1) .. 'Slot'], 'RIGHT', 2.5, 0)
        end
        point(KeyRingButton, 'LEFT', CharacterBag3Slot, 'RIGHT', 2.5, 0)

        point(MicroButtonAndBagsBar, 'BOTTOMLEFT', UIParent, 'BOTTOMLEFT')
        MicroButtonAndBagsBar:Show()
    elseif style == 'RIGHT' then
        MicroLeft:SetTexCoord(GetCoords(MICRO_LEFT_COORDS, style))
        MicroMiddle:SetTexCoord(GetCoords(MICRO_MIDDLE_COORDS, style))
        MicroRight:SetTexCoord(GetCoords(MICRO_RIGHT_COORDS, style))
        BagBg:SetTexCoord(GetCoords(BAG_BG_COORDS, style))
        KeyringBg:SetTexCoord(GetCoords(KEYRING_BG_COORDS, style))
        point(BagBg, 'TOPRIGHT')
        point(KeyringBg, 'BOTTOMRIGHT', BagBg, 'BOTTOMLEFT', 24 - 16, 0)

        point(CharacterMicroButton, 'BOTTOMLEFT', MicroButtonAndBagsBar, 'BOTTOMLEFT', 6, 3)
        point(MainMenuBarBackpackButton, 'TOPRIGHT', MicroButtonAndBagsBar, 'TOPRIGHT', -6, -4)
        point(CharacterBag0Slot, 'RIGHT', MainMenuBarBackpackButton, 'LEFT', -4, -5)
        for i = 1, 3 do
            point(_G['CharacterBag' .. i .. 'Slot'], 'RIGHT', _G['CharacterBag' .. (i - 1) .. 'Slot'], 'LEFT', -2.5, 0)
        end
        point(KeyRingButton, 'RIGHT', CharacterBag3Slot, 'LEFT', -2.5, 0)

        point(MicroButtonAndBagsBar, 'BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT')
        MicroButtonAndBagsBar:Show()
    elseif style == 'HIDE' then
        MicroButtonAndBagsBar:Hide()
    end
end

ns.config('actionbar.micro.position', UpdateMicroBar)
ns.login(UpdateMicroBar)
