-- CVars.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 4/9/2020, 12:42:47 AM
--
---@type ns
local ns = select(2, ...)

-- @debug@
ns.onceevent('VARIABLES_LOADED', function()
    if GetCurrentRegion() == 5 or GetLocale() == 'zhCN' then
        ConsoleExec('SET portal TW')
        SetCVar('profanityFilter', false)
    end
end)
-- @end-debug@

ns.addon('AdvancedInterfaceOptions', function()
    if AIOSlidercameraDistanceMaxZoomFactor then
        AIOSlidercameraDistanceMaxZoomFactor:SetMinMaxValues(1, 4)
        AIOSlidercameraDistanceMaxZoomFactor.maxText:SetText('4')
    end
end)

ns.addon('Blizzard_MovePad', function()

    local function ClosePad()
        C_CVar.SetCVar('enableMovePad', nil)
    end

    Menu.ModifyMenu('MOVE_PAD_SETTINGS_MENU', function(_, root)
        if InCombatLockdown() then
            return
        end
        root:CreateButton(CLOSE, ClosePad)
    end)
end)

-- ns.addon('Blizzard_CompactRaidFrames', function()
--     ns.securehook('CompactRaidFrameReservation_RegisterReservation', function(o, f, _)
--         print(o)
--         f.healthBar:GetStatusBarTexture():SetTexture([[Interface\AddOns\!!!tdUI\Media\Statusbar_Clean.blp]])
--     end)
-- end)
