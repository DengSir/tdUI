-- Range.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/5/2019, 1:26:24 PM
--
---@type ns
local ns = select(2, ...)

local RangeCheck = LibStub('LibRangeCheck-3.0')

local format = format

local UnitIsUnit = UnitIsUnit
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitClassification = UnitClassification

local Range = ns.class('Frame')

function Range:Constructor(parent, event, isNameplate)
    self.parent = parent
    self.event = event
    self.isNameplate = isNameplate
    self.elapsed = 0
    self.text = self:CreateFontString(nil, 'BORDER')
    self.text:SetFont(STANDARD_TEXT_FONT, 14, 'OUTLINE')

    self:SetScript('OnUpdate', self.OnUpdate)
    self:SetScript('OnEvent', self.OnEvent)
    self:SetScript('OnShow', self.Update)
    self:SetScript('OnHide', self.Update)

    self:RegisterEvent('RAID_TARGET_UPDATE')
    if event then
        self:RegisterEvent(event)
    end
end

function Range:GetUnit()
    if self.isNameplate then
        if self.parent.UnitFrame then
            return self.parent.UnitFrame.unit
        end
    else
        return self.parent.unit
    end
end

function Range:Update()
    local unit = self:GetUnit()
    if not unit then
        return
    end
    local min, max = RangeCheck:GetRange(unit)
    if not max then
        self.text:SetText('')
    else
        self.text:SetText(format('%d-%d', min, max))

        if max == 5 then
            self.text:SetTextColor(0, 1, 0)
        elseif max <= 20 then
            self.text:SetTextColor(0.5, 1, 0)
        elseif max <= 30 then
            self.text:SetTextColor(0.75, 1, 0)
        elseif max <= 35 then
            self.text:SetTextColor(1, 1, 0)
        end
    end
end

function Range:OnUpdate(elapsed)
    self.elapsed = self.elapsed - elapsed
    if self.elapsed < 0 then
        self.elapsed = 0.1
        self:Update()
    end
end

function Range:UpdatePosition()
    if self.isNameplate then
        self.text:SetPoint('RIGHT', self.parent, 'LEFT', -2, 0)
    else
        local unit = self:GetUnit()
        local relativeTo = self.parent.portrait
        if GetRaidTargetIndex(unit) then
            self.text:SetPoint('BOTTOM', relativeTo, 'TOP', 2, 7)
        elseif UnitClassification(unit) == 'normal' then
            self.text:SetPoint('BOTTOM', relativeTo, 'TOP', 0, 0)
        else
            self.text:SetPoint('BOTTOM', relativeTo, 'TOP', 0, 5)
        end
    end
end

function Range:OnEvent(event)
    if event == self.event then
        if UnitIsUnit('player', self.parent.unit) then
            self:Hide()
        else
            self:Show()
            self:UpdatePosition()
        end
    else
        self:UpdatePosition()
    end
end

Range:New(TargetFrame, 'PLAYER_TARGET_CHANGED')

if FocusFrame then
    Range:New(FocusFrame, 'PLAYER_FOCUS_CHANGED')
end

local frames = {}
local function Alloc(unitFrame)
    local f = frames[unitFrame]
    if not f then
        f = Range:New(unitFrame, nil, true)
        frames[unitFrame] = f
    end
    return f
end

ns.securehook(NamePlateDriverFrame, 'OnNamePlateAdded', function(_, unit)
    local frame = C_NamePlate.GetNamePlateForUnit(unit)
    if frame and frame.UnitFrame then
        local f = Alloc(frame)
        f:Show()
        f:UpdatePosition()
    end
end)
