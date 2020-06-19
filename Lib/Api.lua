-- Api.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/8/2020, 2:09:59 PM

---@type ns
local ns = select(2, ...)

local _G = _G
local ipairs = ipairs
local unpack = table.unpack or unpack
local tinsert = table.insert
local format = string.format

local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

function ns.rgb(r, g, b)
    if b then
        return r, g, b
    elseif r.r then
        return r.r, r.g, r.b
    else
        return unpack(r)
    end
end

local Reg = LibStub('AceConfigRegistry-3.0')
local R = setmetatable({}, {
    __index = function(t, k)
        local options = LibStub('AceConfigRegistry-3.0'):GetOptionsTable(k, 'dialog', 'Inject-1.0')
        -- t[k] = options
        return options
    end,
})

function ns.RemoveAceConfig(registry, ...)
    local options = type(registry) == 'table' and registry or R[registry]
    local n = select('#', ...)
    for i = 1, n do
        local key = select(i, ...)

        if not options.args then
            break
        end
        if i < n then
            options = options.args[key]
        else
            options.args[key] = nil
        end
    end
end

function ns.GetButtons(nameTemplate, count, ...)
    local buttons = {}
    local keys = {...}

    for i = 1, count do
        local buttonName = format(nameTemplate, i)
        local button = _G[buttonName]

        for _, key in ipairs(keys) do
            button[key] = _G[buttonName .. key]
        end

        tinsert(buttons, button)
    end
    return buttons
end

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

function ns.SetTextColor(label, r, g, b)
    r, g, b = ns.rgb(r, g, b)
    if r then
        label:SetTextColor(r, g, b)
    end
end
