-- MinimapRetail.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/21/2026, 11:15:31 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_Minimap', function()
    local  PlayerCoords = MinimapCluster.MinimapContainer.PlayerCoords
    PlayerCoords:ClearAllPoints()
    PlayerCoords:SetPoint('TOP', Minimap, 'TOP', 0, 20)
    -- PlayerCoords.CoordText:SetFontObject(GameFontHighlightSmallOutline)
end)
