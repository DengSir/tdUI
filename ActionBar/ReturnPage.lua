-- ReturnPage.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/9/2020, 12:31:59 PM

local ReturnPage = CreateFrame('Button', 'tdReturnPageButton', UIParent,
                               'SecureHandlerStateTemplate')

ReturnPage:SetAttribute('_onstate-usable', [[
    if newstate == 1 then
        self:SetBinding(true, 'Escape', 'ACTIONPAGE1')
    else
        self:ClearBindings()
    end
]])
RegisterStateDriver(ReturnPage, 'usable', '[noactionbar:1]1;0')
