-- RemoveOptions.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 3/12/2020, 11:44:59 AM

---@type ns
local ns = select(2, ...)

ns.login(function()
    local REMOVES = tInvert{ --
        'MonkeyQuest', --
        'Leatrix Maps', --
        'Details', --
        'MikScrollingBattleText', --
    }

    local TBL = INTERFACEOPTIONS_ADDONCATEGORIES

    for i = #TBL, 1, -1 do
        local v = TBL[i]
        if not v.parent and REMOVES[v.name] then
            tremove(TBL, i)
        end
    end
end)
