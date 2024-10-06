-- RemoveMacros.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2022/7/25 12:59:40
--

local function IsMyMacro(name)
    if name:find('%-Dencer$') then
        return true
    end
    -- if name:find('^_M6%+s') then
    --     return true
    -- end
end

local function CheckMacro(id)
    local name = GetMacroInfo(id)
    if name then
        if not IsMyMacro(name) then
            DeleteMacro(id)
        end
    end
end

function RemoveMacros()
    local a1, a2 = GetNumMacros()

    for i = a1, 1, -1 do
        CheckMacro(i)
    end

    for i = 120 + a2, 121, -1 do
        CheckMacro(i)
    end
end
