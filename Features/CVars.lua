-- CVars.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 4/9/2020, 12:42:47 AM
--
---@type ns
local ns = select(2, ...)

ns.onceevent('VARIABLES_LOADED', function()
    -- @debug@
    if GetCurrentRegion() == 5 or GetLocale() == 'zhCN' then
        ConsoleExec('SET portal TW')
        SetCVar('profanityFilter', false)
    end
    -- @end-debug@

    SetCVar('alwaysCompareItems', false)
    SetCVar('chatClassColorOverride', false)
    SetCVar('xpBarText', true)

    SetCVar('SoftTargetInteractArc', 0)
    SetCVar('SoftTargetInteractRange', 10)
end)

ns.addon('AdvancedInterfaceOptions', function()
    if AIOSlidercameraDistanceMaxZoomFactor then
        AIOSlidercameraDistanceMaxZoomFactor:SetMinMaxValues(1, 4)
        AIOSlidercameraDistanceMaxZoomFactor.maxText:SetText('4')
    end
end)
