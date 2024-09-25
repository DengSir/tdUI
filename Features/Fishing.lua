-- Fishing.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2021, 12:33:30 AM
--
local Action = CreateFrame('Frame', 'tdFishingButton', UIParent, 'SecureHandlerStateTemplate')

Action:SetAttribute('_onstate-usable', [[
    if newstate == 1 then
        self:SetBindingSpell(true, '1', '钓鱼')
        self:SetBinding(true, '2', 'INTERACTTARGET')
    else
        self:ClearBindings()
    end
]])

RegisterStateDriver(Action, 'usable', '[equipped:鱼竿]1;0')
