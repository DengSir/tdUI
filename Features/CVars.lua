-- CVars.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 4/9/2020, 12:42:47 AM
--
---@type ns
local ns = select(2, ...)

ns.login(function()
    -- @debug@
    ConsoleExec('SET portal TW')
    SetCVar('profanityFilter', false)
    -- @end-debug@

    SetCVar('alwaysCompareItems', false)
    SetCVar('chatClassColorOverride', false)
    SetCVar('xpBarText', true)

    SetCVar('nameplateLargerScale', 1.2)
    SetCVar('nameplateLargeTopInset', 0.1)
    SetCVar('nameplateMinAlpha', 1.0)
    SetCVar('nameplateMinAlphaDistance', 10)
    SetCVar('nameplateMotionSpeed', 0.025)
    SetCVar('nameplateNotSelectedAlpha', 0.5)
    SetCVar('nameplateOtherTopInset', 0.08)
    SetCVar('nameplatePersonalHideDelaySeconds', 3.0)
    SetCVar('nameplateSelectedScale', 1)
end)
