-- Micro.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/18/2020, 9:46:28 AM

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

local MicroButtonAndBagsBar = CreateFrame('Frame', 'MicroButtonAndBagsBar', MainMenuBar)
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

local MicroMiddle = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
MicroMiddle:SetPoint('LEFT', MicroLeft, 'RIGHT')
MicroMiddle:SetTexture(1721259)
MicroMiddle:SetSize(26 * 8 - 48, 43)

local MicroRight = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
MicroRight:SetPoint('LEFT', MicroMiddle, 'RIGHT')
MicroRight:SetTexture(1721259)
MicroRight:SetSize(30, 43)

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

MainMenuBarPerformanceBar:ClearAllPoints()
MainMenuBarPerformanceBar:SetParent(MainMenuMicroButton)
MainMenuBarPerformanceBar:SetSize((21 - 11) * 29 / 32, (42 - 37) * 58 / 64)
MainMenuBarPerformanceBar:SetDrawLayer('OVERLAY')
MainMenuBarPerformanceBar:SetTexture([[Interface\BUTTONS\white8x8]])
MainMenuBarPerformanceBar:SetAlpha(0.6)
MainMenuBarPerformanceBarFrame:EnableMouse(false)

local function UpdatePerformanceBarPushed(self)
    if self:GetButtonState() == 'PUSHED' then
        MainMenuBarPerformanceBar:SetPoint('TOPLEFT', 10 * 29 / 32, -39 * 58 / 64)
        MainMenuBarPerformanceBar:SetAlpha(0.4)
    else
        MainMenuBarPerformanceBar:SetPoint('TOPLEFT', 11 * 29 / 32, -37 * 58 / 64)
        MainMenuBarPerformanceBar:SetAlpha(0.6)
    end
end

MainMenuMicroButton:HookScript('OnMouseDown', UpdatePerformanceBarPushed)
MainMenuMicroButton:HookScript('OnMouseUp', UpdatePerformanceBarPushed)
ns.securehook(MainMenuMicroButton, 'SetButtonState', UpdatePerformanceBarPushed)
ns.securehook('MicroButton_OnEnter', function(self)
    if self == MainMenuMicroButton then
        local newbie = GetCVarBool('showNewbieTips')
        local bandwidthIn, bandwidthOut, latency = GetNetStats()

        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(MAINMENUBAR_LATENCY_LABEL .. ' ' .. latency .. MILLISECONDS_ABBR, 1, 1, 1)
        if newbie then
            GameTooltip:AddLine(NEWBIE_TOOLTIP_LATENCY, 1, 0.82, 0, true)
        end
    end
end)

local buttons = {
    CharacterMicroButton, SpellbookMicroButton, TalentMicroButton, QuestLogMicroButton, SocialsMicroButton,
    WorldMapMicroButton, MainMenuMicroButton, HelpMicroButton,
}

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
    else
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
    end
end

local function UpdateMicroWidth()
    local count = #buttons
    MicroButtonAndBagsBar:SetWidth(26 * count + 12)
    MicroMiddle:SetWidth(26 * count - 48)
end

local function OnEvent(self, event)
    if event == 'UPDATE_BINDINGS' then
        self.tooltipText = MicroButtonTooltipText(self.text, self.keybinding)
    end
end

ns.config('actionbar.micro.position', UpdateMicroBar)
ns.login(UpdateMicroBar)

function ns.CreateMicroButton(after, text, keybinding, frame)
    local button = CreateFrame('Button', nil, MainMenuBar, 'MainMenuBarMicroButton')

    local index = tIndexOf(buttons, after)
    local anchorTo = buttons[index]

    if keybinding then
        button.text = text
        button.keybinding = keybinding
        button.tooltipText = MicroButtonTooltipText(text, keybinding)
        button:RegisterEvent('UPDATE_BINDINGS')
        button:SetScript('OnEvent', OnEvent)
    else
        button.tooltipText = text
    end

    button:SetPoint('BOTTOMLEFT', anchorTo, 'BOTTOMRIGHT', -3, 0)
    if buttons[index + 1] then
        buttons[index + 1]:SetPoint('BOTTOMLEFT', button, 'BOTTOMRIGHT', -3, 0)
    end

    if frame then
        frame:HookScript('OnShow', function()
            button:SetButtonState('PUSHED', true)
        end)
        frame:HookScript('OnHide', function()
            button:SetButtonState('NORMAL')
        end)
    end

    tinsert(buttons, index + 1, button)
    UpdateMicroWidth()
    return button
end
