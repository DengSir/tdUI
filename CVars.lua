-- CVars.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 4/9/2020, 12:42:47 AM

---@type ns
local ns = select(2, ...)

ns.login(function()
    ConsoleExec('SET portal TW')

    SetCVar('profanityFilter', false)
    SetCVar('alwaysCompareItems', false)
    SetCVar('nameplateLargerScale', 1.2)
    SetCVar('nameplateMotionSpeed', 0.025)
    SetCVar('nameplateNotSelectedAlpha', 0.5)
    SetCVar('xpBarText', true)
end)
