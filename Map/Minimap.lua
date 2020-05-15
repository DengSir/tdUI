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
MinimapBorderTop:Hide()
GameTimeFrame:Hide()

MinimapBorder:ClearAllPoints()
MinimapBorder:SetSize(210, 210)
MinimapBorder:SetPoint('CENTER', Minimap, 'CENTER', 0, 14)
MinimapBorder:SetTexture([[Interface\AddOns\tdUI\Media\minimap.tga]])
MinimapBorder:SetTexCoord(0, 1, 0, 1)

MiniMapTrackingFrame:SetFrameLevel(Minimap:GetFrameLevel() + 10)

MinimapZoneTextButton:SetWidth(155)
MinimapZoneTextButton:SetPoint('CENTER', Minimap, 'TOP', 0, 20)
MinimapZoneText:SetDrawLayer('OVERLAY')
MinimapZoneText:SetFont(MinimapZoneText:GetFont(), 15, 'OUTLINE')

Minimap:SetPoint('CENTER', MinimapCluster, 'TOP', 9, -100)
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
    for i, region in ipairs{TimeManagerClockButton:GetRegions()} do
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
