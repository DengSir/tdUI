-- Threat.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2022/2/15下午8:45:26
--
---@type ns
local ns = select(2, ...)

local Threat = CreateFrame('Frame', nil, TargetFrame)

function Threat:OnLoad()
    self:SetSize(49, 18)
    self:SetPoint('BOTTOM', PlayerFrame, 'TOP', 80, -22)

    local bg = self:CreateTexture(nil, 'BACKGROUND')
    bg:SetSize(37, 14)
    bg:SetPoint('TOP', 0, -3)
    bg:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])

    local value = self:CreateFontString(nil, 'BACKGROUND', 'GameFontHighlight')
    value:SetPoint('TOP', 0, -4)

    local border = self:CreateTexture('BORDER')
    border:SetAllPoints(true)
    border:SetTexture([[Interface\TargetingFrame\NumericThreatBorder]])
    border:SetTexCoord(0, 0.765625, 0, 0.5625)

    self.bg = bg
    self.value = value

    self:SetScript('OnHide', self.Hide)
    self:SetScript('OnEvent', self.OnEvent)
    self:SetScript('OnUpdate', self.OnEvent)
    self:RegisterUnitEvent('UNIT_THREAT_SITUATION_UPDATE', 'target', 'player')
end

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
function Threat:OnEvent()
    local unit = 'target'
    local feedbackUnit = 'player'
    local isTanking, status, percentage, rawPercentage = UnitDetailedThreatSituation(feedbackUnit, unit)
    local display = rawPercentage

    if isTanking then
        display = UnitThreatPercentageOfLead(feedbackUnit, unit);
    end

    -- print(display, isTanking, status, percentage, rawPercentage)

    if display and display ~= 0 then
        self.value:SetFormattedText('%1.0f%%', display)
        self.bg:SetVertexColor(GetThreatStatusColor(status))
        self:Show()
    else
        self:Hide()
    end
end

Threat:OnLoad()
