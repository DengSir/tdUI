-- LFG.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/28/2026, 8:59:47 PM
--
---@type ns
local ns = select(2, ...)

local point = ns.point

local MicroMenuContainer = MicroMenuContainer
local LFGMinimapFrame = LFGMinimapFrame

local LFGButtons = { --
    {button = LFGMinimapFrame, x = -1, y = 1},
    {button = MiniMapBattlefieldFrame, x = 0, y = 0},
}

for i, v in ipairs_reverse(LFGButtons) do
    if not v.button then
        tremove(LFGButtons, i)
    end
end

local function AtLeft()
    local left = MicroMenuContainer:GetLeft()
    local right = UIParent:GetWidth() - MicroMenuContainer:GetRight()
    return left < right
end

local function LayoutLFGButtons()
    local p, rp, x
    if AtLeft() then
        p = 'BOTTOMLEFT'
        rp = 'BOTTOMRIGHT'
        x = 1
    else
        p = 'BOTTOMRIGHT'
        rp = 'BOTTOMLEFT'
        x = -1
    end

    local index = 0
    for _, v in ipairs(LFGButtons) do
        if v.button:IsShown() then

            point(v.button, p, MicroMenuContainer, rp, 35 * index * x + v.x, v.y)
            index = index + 1
        end
    end
end

for _, v in ipairs(LFGButtons) do
    ns.hookscript(v.button, 'OnShow', LayoutLFGButtons)
    ns.hookscript(v.button, 'OnHide', LayoutLFGButtons)
end

ns.hookscript(QueueStatusFrame, 'OnShow', function(self)
    self:ClearAllPoints()
    self:SetPoint('BOTTOMLEFT', LFGMinimapFrame, 'TOPLEFT')
end)
