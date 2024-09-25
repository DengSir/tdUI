-- PlayerMenu.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/18/2024, 11:21:26 AM
--
---@type ns
local ns = select(2, ...)

ns.securehook('ToggleDropDownMenu', function(level, _, dropdown)
    if not dropdown or dropdown ~= SecureTemplatesDropdown or not dropdown.openedFor then
        return
    end
    if level and level ~= 1 then
        return
    end
    if not DropDownList1:IsVisible() then
        return
    end

    local unitButton = dropdown.openedFor
    if unitButton:GetBottom() - DropDownList1:GetHeight() < 0 then
        DropDownList1:SetPoint('BOTTOMLEFT', unitButton, 'TOPLEFT')
    else
        DropDownList1:SetPoint('TOPLEFT', unitButton, 'BOTTOMLEFT')
    end
end)
