-- FollowAlways.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/28/2021, 6:02:27 PM
--
---@type ns
local ns = select(2, ...)

local FOLLOW_UNIT
local FOLLOWING = false

local function IsFollowing()
    return FOLLOWING
end

local CloseButton = CreateFrame('Button', nil, UIParent, 'UIPanelCloseButton')
CloseButton:Hide()
CloseButton:SetPoint('LEFT', AutoFollowStatusText, 'RIGHT', 5, 0)
CloseButton:SetScript('OnClick', function()
    -- FollowUnit(FOLLOW_UNIT)
    CloseButton:Hide()
end)
CloseButton:SetScript('OnUpdate', function(self, elapsed)
    self.timer = (self.timer or 0) - elapsed
    if self.timer > 0 then
        return
    end

    self.timer = 1
    if not IsFollowing() then
        FollowUnit(FOLLOW_UNIT)
        print(FOLLOW_UNIT)
    end
end)

ns.event('AUTOFOLLOW_BEGIN', function(name)
    FOLLOW_UNIT = name
    FOLLOWING = true
    CloseButton:Show()
end)

local function OnEnd()
    FOLLOWING = false
    print('End')
end

ns.event('AUTOFOLLOW_END', OnEnd)
ns.event('LOADING_SCREEN_DISABLED', OnEnd)
