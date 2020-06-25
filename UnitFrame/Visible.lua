-- Visible.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/23/2020, 2:45:43 PM

local Visible = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
Visible:SetAttribute('_onstate-showhide', [[
    local PlayerFrame = self:GetFrameRef('PlayerFrame')
    if newstate == 1 then
        PlayerFrame:Show()
    else
        PlayerFrame:Hide()
    end
]])
Visible:SetFrameRef('PlayerFrame', PlayerFrame)
RegisterStateDriver(Visible, 'showhide', '[combat]1;[@target,exists]1;0')
