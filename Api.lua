-- Api.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/8/2020, 2:09:59 PM

---@type ns
local ns = select(2, ...)

function ns.CropClassCoords(classFileName)
    local coords = CLASS_ICON_TCOORDS[classFileName]
    if not coords then
        return
    end

    local left, right, top, bottom = unpack(coords)
    local x = (right - left) * 0.06
    local y = (bottom - top) * 0.06
    return left + x, right - x, top + y, bottom - y
end
