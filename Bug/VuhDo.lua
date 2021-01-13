-- VuhDo.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/12/2021, 1:03:58 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('VuhDo', function()
    local origs = {}

    local function SetAttribute(frame, key, value)
        if frame and value == 'VUHDO_contextMenu' then
            origs[frame](frame, key, 'togglemenu')
            frame.VUHDO_contextMenu = nil
        end
    end

    ns.hook('VUHDO_getOrCreateHealButton', function(orig, ...)
        local frame = orig(...)
        if not origs[frame] then
            origs[frame] = frame.SetAttribute
            ns.securehook(frame, 'SetAttribute', SetAttribute)
        end
        return frame
    end)

    ns.securehook('ToggleDropDownMenu', function(level, _, dropdown)
        if dropdown == SecureTemplatesDropdown and dropdown.openedFor and level == 1 and DropDownList1:IsVisible() then
            DropDownList1:ClearAllPoints()
            DropDownList1:SetPoint('TOPLEFT', dropdown.openedFor, 'BOTTOMLEFT')
        end
    end)
end)
