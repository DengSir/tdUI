-- Minimap.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/14/2020, 4:46:30 PM
---@type ns
local ns = select(2, ...)

MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MinimapToggleButton:Hide()
MiniMapWorldMapButton:Hide()
-- MinimapBorderTop:Hide()
GameTimeFrame:Hide()

MinimapCluster:SetPoint('TOPRIGHT', 0, -10)

MinimapBorder:SetTexture([[Interface\AddOns\tdUI\Media\UI-MINIMAP-BORDER]])

MinimapBorderTop:SetTexture([[Interface\AddOns\tdUI\Media\Minimap.tga]])
MinimapBorderTop:SetSize(210, 39.78515625)
MinimapBorderTop:SetTexCoord(0, 1, 0, 0.189453125)
MinimapBorderTop:ClearAllPoints()
MinimapBorderTop:SetPoint('CENTER', MinimapZoneTextButton, 'CENTER', 0, 10)

MinimapCompassTexture:SetScale(0.7)

MiniMapTrackingFrame:SetFrameLevel(Minimap:GetFrameLevel() + 10)

MinimapZoneTextButton:SetSize(155, 20)
MinimapZoneTextButton:SetPoint('CENTER', Minimap, 'TOP', 0, 20)
MinimapZoneText:SetDrawLayer('OVERLAY')
MinimapZoneText:SetFont(MinimapZoneText:GetFont(), 15, 'OUTLINE')
MinimapZoneText:ClearAllPoints()
MinimapZoneText:SetPoint('CENTER')

Minimap:EnableMouseWheel(true)
Minimap:SetScript('OnMouseWheel', function(self, direction)
    if direction > 0 then
        MinimapZoomIn:Click()
    elseif direction < 0 then
        MinimapZoomOut:Click()
    end
end)

ns.securehook('Minimap_UpdateRotationSetting', function()
    MinimapNorthTag:Hide()
end)

ns.addon('Blizzard_TimeManager', function()
    for i, region in ipairs {TimeManagerClockButton:GetRegions()} do
        if region:IsObjectType('Texture') then
            region:Hide()
        end
    end

    TimeManagerClockTicker:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE')
    TimeManagerClockTicker:SetTextColor(1, 0.82, 0)

    TimeManagerClockButton:ClearAllPoints()
    TimeManagerClockButton:SetPoint('CENTER', Minimap, 'BOTTOM', 0, -8)
    TimeManagerClockButton:SetFrameLevel(Minimap:GetFrameLevel() + 10)
end)
