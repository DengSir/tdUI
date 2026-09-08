-- Baganator.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/7/2026, 8:07:36 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Baganator', function()
    local addonTable = C_AddOns.GetAddOnLocalTable('Baganator')
    if not addonTable then
        return
    end

    local buttonEnv = {}

    local function SwapViewType(viewType)
        local current = addonTable.Config.Get(viewType)
        addonTable.Config.Set(viewType, current == 'category' and 'single' or 'category')
    end

    local function OnClick(button, clicked)
        local env = buttonEnv[button]
        if not env then
            return
        end
        if clicked == 'LeftButton' then
            env.OnClick(button, clicked)
        else
            SwapViewType(env.viewType)
        end
    end

    ns.securehook(addonTable.ItemViewCommon, 'GetAnchorSetter', function(frame, setting)
        local button = frame.CustomiseButton
        if not button then
            return
        end

        local Options = addonTable.Config.Options
        local viewType = setting == Options.BANK_ONLY_VIEW_POSITION and Options.BANK_VIEW_TYPE or setting ==
                             Options.MAIN_VIEW_POSITION and Options.BAG_VIEW_TYPE

        if not viewType then
            return
        end

        buttonEnv[button] = { --
            OnClick = button:GetScript('OnClick'),
            viewType = viewType,
        }

        button:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
        button:SetScript('OnClick', OnClick)
    end)
end)
