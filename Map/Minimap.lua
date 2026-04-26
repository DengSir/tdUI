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
-- GameTimeFrame:Hide()

MinimapBorder:SetTexture([[Interface\AddOns\tdUI\Media\UI-MINIMAP-BORDER]])

-- MinimapZoneText:SetDrawLayer('OVERLAY')
-- MinimapZoneText:SetFont(MinimapZoneText:GetFont(), 15, 'OUTLINE')
-- MinimapZoneText:ClearAllPoints()
-- MinimapZoneText:SetPoint('CENTER')

if MinimapBorderTop then
    MinimapCluster:SetPoint('TOPRIGHT', 0, -10)
    MinimapBorderTop:SetTexture([[Interface\AddOns\tdUI\Media\Minimap.tga]])
    MinimapBorderTop:SetSize(210, 39.78515625)
    MinimapBorderTop:SetTexCoord(0, 1, 0, 0.189453125)
    MinimapBorderTop:ClearAllPoints()
    MinimapBorderTop:SetPoint('CENTER', MinimapZoneTextButton, 'CENTER', 0, 10)

    MinimapZoneTextButton:ClearAllPoints()
    MinimapZoneTextButton:SetSize(155, 20)
    MinimapZoneTextButton:SetPoint('CENTER', Minimap, 'TOP', 0, 20)

elseif MinimapCluster.BorderTop then

    local BorderTop = MinimapCluster.BorderTop

    BorderTop:SetAlpha(0)

    local Texture = MinimapCluster:CreateTexture(nil, 'OVERLAY')
    Texture:SetSize(BorderTop:GetWidth(), 20)
    Texture:SetTexture([[Interface\AddOns\tdUI\Media\Minimap.tga]])
    Texture:SetTexCoord(0, 1, 0.095238, 0.189453125)
    Texture:SetPoint('TOP', BorderTop, 'TOP', 0, 0)

    MinimapZoneTextButton:SetSize(155, 20)
    MinimapZoneTextButton:ClearAllPoints()
    MinimapZoneTextButton:SetPoint('CENTER', Texture, 'CENTER')

    ns.securehook(MinimapCluster, 'SetHeaderUnderneath', function(self, underneath)
        if not underneath then
            Texture:ClearAllPoints()
            Texture:SetPoint('TOP', BorderTop, 'TOP', 0, 0)
            BorderTop:SetHeight(37)
        else
            Texture:ClearAllPoints()
            Texture:SetPoint('BOTTOM', BorderTop, 'BOTTOM', 0, 0)
            BorderTop:SetHeight(31)
        end
    end)
end

MinimapCompassTexture:SetScale(0.7)

-- @classic@
-- MiniMapTrackingFrame:SetFrameLevel(Minimap:GetFrameLevel() + 10)
-- @end-classic@

Minimap:EnableMouseWheel(true)
Minimap:SetScript('OnMouseWheel', function(self, direction)
    if direction > 0 then
        MinimapZoomIn:Click()
    elseif direction < 0 then
        MinimapZoomOut:Click()
    end
end)

ns.hide(MinimapNorthTag)

-- ns.securehook('Minimap_UpdateRotationSetting', function()
--     MinimapNorthTag:Hide()
-- end)

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

-- if MiniMapInstanceDifficulty then
--     print(MiniMapInstanceDifficulty)
--     MiniMapInstanceDifficulty:ClearAllPoints()
--     MiniMapInstanceDifficulty:SetPoint('TOP', Minimap, 'TOP', 0, 18)
--     MiniMapInstanceDifficulty:SetScale(0.8)
-- end
