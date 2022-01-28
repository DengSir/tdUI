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

    local function hacker(orig, m, n, ...)
        local f = orig(m, n, ...)
        local b = VUHDO_getBarIconFrame(m, n)
        if b then
            b:SetMouseClickEnabled(false)
        end
        return f
    end

    ns.hook('VUHDO_getOrCreateHotIcon', hacker)
    ns.hook('VUHDO_getOrCreateCuDeButton', hacker)

    local DropDownList1 = DropDownList1

    ns.securehook('ToggleDropDownMenu', function(level, _, dropdown)
        if (not level or level == 1) and dropdown and dropdown == SecureTemplatesDropdown and dropdown.openedFor and
            DropDownList1:IsVisible() then

            DropDownList1:ClearAllPoints()

            print(dropdown.openedFor:GetBottom(), DropDownList1:GetHeight())

            if dropdown.openedFor:GetBottom() - DropDownList1:GetHeight() < 0 then
                DropDownList1:SetPoint('BOTTOMLEFT', dropdown.openedFor, 'TOPLEFT')
            else
                DropDownList1:SetPoint('TOPLEFT', dropdown.openedFor, 'BOTTOMLEFT')
            end
        end
    end)
end)
