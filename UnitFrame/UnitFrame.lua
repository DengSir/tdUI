-- Addon.lua
-- @Author  : DengSir (tdaddon@163.com)
-- @Link    : https://dengsir.github.io
--
---@type ns
local ns = select(2, ...)

local OPTIONS_FONT_ALPHA = 0.6

local function MoveUp(widget, delta)
    local p, r, rp, x, y = widget:GetPoint(1)
    widget:ClearAllPoints()
    widget:SetPoint(p, r, rp, x, y + delta)
end

---- TargetFrame
do
    local function CreateText(parent, ...)
        local text = parent:CreateFontString(nil, 'OVERLAY', 'TextStatusBarText')
        text:SetPoint(...)
        text:SetAlpha(OPTIONS_FONT_ALPHA)
        return text
    end

    if not TargetFrame.healthbar.TextString then
        TargetFrame.healthbar.TextString = CreateText(TargetFrame.textureFrame, 'CENTER', -50, 3)
        TargetFrame.healthbar.LeftText = CreateText(TargetFrame.textureFrame, 'LEFT', 8, 3)
        TargetFrame.healthbar.RightText = CreateText(TargetFrame.textureFrame, 'RIGHT', -110, 3)
    end

    if not TargetFrame.manabar.TextString then
        TargetFrame.manabar.TextString = CreateText(TargetFrame.textureFrame, 'CENTER', -50, -8)
        TargetFrame.manabar.LeftText = CreateText(TargetFrame.textureFrame, 'LEFT', 8, -8)
        TargetFrame.manabar.RightText = CreateText(TargetFrame.textureFrame, 'RIGHT', -110, -8)
    end

    PlayerName:Hide()
    PlayerName.Show = nop

    PlayerFrame.healthbar:EnableMouse(false)
    PlayerFrame.manabar:EnableMouse(false)

    MoveUp(PlayerFrame.healthbar.LeftText, 8)
    MoveUp(PlayerFrame.healthbar.RightText, 8)

    ns.securehook('LocalizeFrames', function()
        MoveUp(PlayerFrame.healthbar.TextString, 8)
    end)
end

local function InitAlpha(widget)
    if widget then
        widget:SetAlpha(OPTIONS_FONT_ALPHA)
    end
end

local function InitFrameFonts(frame)
    if frame.deadText then
        frame.deadText:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE')
        frame.deadText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
        frame.deadText:SetAlpha(OPTIONS_FONT_ALPHA)
    end

    local hb = frame.healthbar
    local mb = frame.manabar

    hb:SetStatusBarTexture([[Interface\AddOns\tdUI\Media\TargetingFrame\UI-StatusBar]])

    InitAlpha(hb.TextString)
    InitAlpha(hb.LeftText)
    InitAlpha(hb.RightText)

    InitAlpha(mb.TextString)
    InitAlpha(mb.LeftText)
    InitAlpha(mb.RightText)
end

local function CheckHealthBar(bar)
    if bar.showPercentage then
        local maxValue = UnitHealthMax(bar.unit)
        if maxValue ~= 100 then
            bar.showPercentage = nil
        end
    end
end

local function FrameOnHide(frame)
    frame.threatIndicator:Hide()
end

for _, frame in ipairs({TargetFrame, FocusFrame}) do
    frame.nameBackground:Hide()
    frame.nameBackground.Show = nop

    frame.healthbar.lockColor = true
    frame.healthbar:ClearAllPoints()
    frame.healthbar:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT', -106, -53)

    frame.name:SetFont(frame.name:GetFont(), 14, 'OUTLINE')

    frame.threatIndicator = frame:CreateTexture(nil, 'BACKGROUND')
    frame.threatIndicator:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Flash]])
    frame.threatIndicator:SetSize(256, 128)
    frame.threatIndicator:SetPoint('TOPLEFT', -24, 0)
    frame.threatIndicator:Hide()
    frame.threatIndicator:SetAlpha(0.8)

    MoveUp(frame.name, 16)
    MoveUp(frame.deadText, 8)
    MoveUp(frame.healthbar.TextString, 8)
    MoveUp(frame.healthbar.LeftText, 8)
    MoveUp(frame.healthbar.RightText, 8)

    ns.securehook(frame.healthbar, 'SetMinMaxValues', CheckHealthBar)
    ns.hookscript(frame, 'OnHide', FrameOnHide)

    InitFrameFonts(frame)
end

InitFrameFonts(PlayerFrame)
InitFrameFonts(PetFrame)
InitFrameFonts(PartyMemberFrame1)
InitFrameFonts(PartyMemberFrame2)
InitFrameFonts(PartyMemberFrame3)
InitFrameFonts(PartyMemberFrame4)

local select = select

local UnitClassBase = UnitClassBase
local UnitClassification = UnitClassification
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapDenied = UnitIsTapDenied
local UnitPlayerControlled = UnitPlayerControlled
local UnitSelectionColor = UnitSelectionColor
local HealthBar_OnValueChanged = HealthBar_OnValueChanged
local GetClassColor = GetClassColor

local PlayerFrameHealthBar = PlayerFrameHealthBar
local PlayerLevelText = PlayerLevelText
local PlayerFrameTexture = PlayerFrameTexture

local function UnitClassColor(unit)
    return GetClassColor(UnitClassBase(unit))
end

ns.securehook('TargetFrame_CheckClassification', function(self)
    local classification = UnitClassification(self.unit)
    if classification == 'rareelite' then
        self.borderTexture:SetTexture([[Interface\AddOns\tdUI\Media\TargetingFrame\UI-TargetingFrame-Rare-Elite]])
    elseif classification == 'rare' then
        self.borderTexture:SetTexture([[Interface\AddOns\tdUI\Media\TargetingFrame\UI-TargetingFrame-Rare]])
    elseif classification == 'elite' or classification == 'worldboss' then
        self.borderTexture:SetTexture([[Interface\AddOns\tdUI\Media\TargetingFrame\UI-TargetingFrame-Elite]])
    else
        self.borderTexture:SetTexture([[Interface\AddOns\tdUI\Media\TargetingFrame\UI-TargetingFrame]])
    end

    if classification == 'minus' then
        self.healthbar:SetHeight(12)
    else
        self.healthbar:SetHeight(31)
        self.Background:SetHeight(self.Background:GetHeight() + 19)
    end
end)

ns.securehook('TargetFrame_CheckFaction', function(self)
    if UnitIsPlayer(self.unit) then
        if not self.healthbar.disconnected then
            self.healthbar:SetStatusBarColor(UnitClassColor(self.unit))
        else
            self.healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
        end
    else
        if not UnitPlayerControlled(self.unit) and UnitIsTapDenied(self.unit) then
            self.healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
        else
            self.healthbar:SetStatusBarColor(UnitSelectionColor(self.unit))
        end
    end
end)

ns.securehook('PlayerFrame_ToPlayerArt', function()
    PlayerFrameHealthBar:SetPoint('TOPLEFT', 106, -22)
    PlayerFrameHealthBar:SetHeight(31)
    PlayerFrameHealthBar.lockColor = true
    PlayerFrameHealthBar:SetStatusBarColor(UnitClassColor('player'))
end)

ns.securehook('PlayerFrame_ToVehicleArt', function()
    PlayerFrameHealthBar:SetHeight(12)
    PlayerFrameHealthBar.lockColor = nil
    HealthBar_OnValueChanged(PlayerFrameHealthBar, PlayerFrameHealthBar:GetValue())
end)

ns.securehook('PlayerFrame_UpdateLevelTextAnchor', function()
    PlayerLevelText:SetPoint('CENTER', PlayerFrameTexture, 'CENTER', -63, -16)
end)

ns.securehook('TargetFrame_UpdateLevelTextAnchor', function(self)
    self.levelText:SetPoint('CENTER', 63, -16)
end)

ns.securehook('TargetofTarget_CheckDead', function(self)
    if UnitExists(self.unit) then
        if UnitIsPlayer(self.unit) then
            self.name:SetTextColor(UnitClassColor(self.unit))
        else
            self.name:SetTextColor(1, 0.81, 0)
        end
    end
end)

local function GetThreatStatusColor(status)
    if status == 0 then
        return 0.69, 0.69, 0.69
    elseif status == 1 then
        return 1, 1, 0.47
    elseif status == 2 then
        return 1, 0.6, 0
    elseif status == 3 then
        return 1, 0, 0
    end
end

ns.securehook('TargetFrame_OnUpdate', function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed;
    if (self.elapsed > 0.5) then
        self.elapsed = 0;
        local unit = self.unit
        local status = UnitThreatSituation('player', unit)

        if status and status > 0 then
            self.threatIndicator:SetVertexColor(GetThreatStatusColor(status))
            self.threatIndicator:Show()
        else
            self.threatIndicator:Hide()
        end
    end
end)

PlayerStatusTexture:SetTexture([[Interface\AddOns\tdUI\Media\TargetingFrame\UI-Player-Status]])
PlayerFrameTexture:SetTexture([[Interface\AddOns\tdUI\Media\TargetingFrame\UI-TargetingFrame]])
TargetFrame:SetFrameLevel(PlayerFrame:GetFrameLevel() + 10)

-- @bcc@
TargetFrame:SetAttribute('type1', 'focus')
-- @end-bcc@
