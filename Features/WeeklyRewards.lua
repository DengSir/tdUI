-- WeeklyRewards.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/1/2026, 5:16:59 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_WeeklyRewards', function()
    local parent = WeeklyRewardsFrame
    local module = CreateFrame('Frame', nil, parent)

    local button

    local function refresh()
        if not parent.Overlay then
            return
        end

        local hasOverlay = parent:ShouldShowOverlay()
        if hasOverlay and not button then
            button = CreateFrame('Button', nil, parent.Overlay)
            button:SetFrameLevel(5510)
            button:SetAllPoints(parent.Overlay)
            button:SetScript('OnClick', function()
                parent.Overlay:Hide()
                if parent.Blackout then
                    parent.Blackout:Hide()
                end
            end)
        end

        if button then
            button:SetShown(hasOverlay)
        end
    end

    local function OnShow()
        refresh()
        ns.event('WEEKLY_REWARDS_UPDATE', refresh)
    end

    local function OnHide()
        ns.unevent('WEEKLY_REWARDS_UPDATE', refresh)
    end

    module:SetScript('OnShow', OnShow)
    module:SetScript('OnHide', OnHide)
end)
