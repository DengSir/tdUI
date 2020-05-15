-- Coords.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/15/2020, 9:56:08 AM

---@type ns
local ns = select(2, ...)

local format = string.format
local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition

local CoordsLabelY = MinimapZoneTextButton:CreateFontString(nil, 'OVERLAY')
CoordsLabelY:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE')
CoordsLabelY:SetTextColor(1, 0.82, 0)
CoordsLabelY:SetJustifyH('LEFT')
CoordsLabelY:SetPoint('LEFT', Minimap, 'TOP', 2, 3)
CoordsLabelY:SetText('00.0')

---@type FontString
local CoordsLabelX = MinimapZoneTextButton:CreateFontString(nil, 'OVERLAY')
CoordsLabelX:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE')
CoordsLabelX:SetTextColor(1, 0.82, 0)
CoordsLabelX:SetJustifyH('LEFT')
CoordsLabelX:SetPoint('LEFT', Minimap, 'TOP', -CoordsLabelY:GetStringWidth() - 1, 3)

local function GetCoords()
    local uiMapID = GetBestMapForUnit('player')
    if uiMapID then
        local position = GetPlayerMapPosition(uiMapID, 'player')
        if position then
            return format('%.1f', position.x * 100), format('%.1f', position.y * 100)
        end
    end
end

local function UpdateCoords()
    local x, y = GetCoords()
    if x then
        CoordsLabelX:SetText(x)
        CoordsLabelY:SetText(y)
        CoordsLabelX:Show()
        CoordsLabelY:Show()
    else
        CoordsLabelX:Hide()
        CoordsLabelY:Hide()
    end
end

ns.event('ZONE_CHANGED', UpdateCoords)
ns.event('ZONE_CHANGED_INDOORS', UpdateCoords)
ns.event('ZONE_CHANGED_NEW_AREA', UpdateCoords)
ns.repeater(0.2, UpdateCoords)
