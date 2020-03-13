-- RemoveOptions.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 3/12/2020, 11:44:59 AM

C_Timer.After(1, function()
    local SET = tInvert{ --
        'MonkeyQuest', --
        'Leatrix Maps', --
        'Details', --
    }

    local TBL = INTERFACEOPTIONS_ADDONCATEGORIES

    for i = #TBL, 1, -1 do
        local v = TBL[i]
        if SET[v.name] then
            tremove(TBL, i)
        end
    end
end)
