-- Baganator.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/7/2026, 8:07:36 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Baganator', function()
    -- BAGANATOR_CONFIG.Profiles.DEFAULT.bank_view_type = 'single'

    -- SlashCmdList['Baganator']('切换')

    local addonTable = C_AddOns.GetAddOnLocalTable('Baganator')
    print(addonTable)
    if not addonTable then
        return
    end

    ns.securehook(addonTable.Utilities, 'AddBagSortManager', function(frame)
        local button = frame.CustomiseButton
        if not button then
            return
        end

        button:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

        local OnClick = button:GetScript('OnClick')

        button:SetScript('OnClick', function(f, btn)
            if btn == 'LeftButton' then
                OnClick(f)
            else
                local v = addonTable.Config.Get(addonTable.Config.Options.BAG_VIEW_TYPE)
                addonTable.Config.Set(addonTable.Config.Options.BAG_VIEW_TYPE,
                                      v == 'category' and 'single' or 'category')
            end
        end)
    end)
end)
