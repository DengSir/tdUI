-- Minimap.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/14/2020, 4:46:30 PM

MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MinimapToggleButton:Hide()
MiniMapWorldMapButton:Hide()
MinimapBorderTop:Hide()
GameTimeFrame:Hide()

---@type Texture
local MinimapBorder = MinimapBorder
local MinimapZoneText = MinimapZoneText
local MinimapZoomIn = MinimapZoomIn
local MinimapZoomOut = MinimapZoomOut
local Minimap = Minimap

MinimapBorder:ClearAllPoints()
MinimapBorder:SetSize(210, 210)
MinimapBorder:SetPoint('CENTER', Minimap, 'CENTER', 0, 14)
MinimapBorder:SetTexture([[Interface\AddOns\tdUI\Media\minimap.tga]])
MinimapBorder:SetTexCoord(0, 1, 0, 1)
MinimapBorder:SetDrawLayer('ARTWORK')
-- MinimapBorder:SetVertexColor(0.7, 0.7, 0.7, 1)

MinimapZoneText:SetSize(155, 11)
MinimapZoneText:SetPoint('CENTER', Minimap, 'TOP', 0, 20)
MinimapZoneText:SetDrawLayer('OVERLAY')
MinimapZoneText:SetFont(MinimapZoneText:GetFont(), 15, 'OUTLINE')

Minimap:ClearAllPoints()
Minimap:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -10, -30)
Minimap:EnableMouseWheel(true)
Minimap:SetScript('OnMouseWheel', function(self, direction)
    if direction > 0 then
        MinimapZoomIn:Click()
    elseif direction < 0 then
        MinimapZoomOut:Click()
    end
end)
