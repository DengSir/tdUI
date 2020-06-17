-- GameTooltip.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/17/2020, 1:07:09 PM

---@type ns
local ns = select(2, ...)

local _G = _G

local setmetatable = setmetatable
local getmetatable = getmetatable

GameTooltipText:SetSpacing(2)

---@type GameTooltip
local GameTooltip = getmetatable(GameTooltip).__index

local function genMeta(key)
    return {
        __index = function(t, num)
            local fontString = _G[t._name .. key .. num]
            t[num] = fontString
            return fontString
        end,
    }
end

local function genCache(key)
    local meta = genMeta(key)
    return setmetatable({}, {
        __index = function(t, tip)
            t[tip] = setmetatable({_name = tip:GetName()}, meta)
            return t[tip]
        end,
    })
end

local lcache = genCache('TextLeft')
local rcache = genCache('TextRight')

-- ns.securehook(GameTooltip, 'AddFontStrings', function(tip, fontLeft, fontRight)
--     local l = lcache[tip]
--     local r = rcache[tip]
--     l[#l + 1] = fontLeft
--     r[#r + 1] = fontRight
-- end)

function GameTooltip:GetFontStringLeft(n)
    return lcache[self][n]
end

function GameTooltip:GetFontStringRight(n)
    return rcache[self][n]
end

function GameTooltip:GetFontStrings(n)
    return lcache[self][n], rcache[self][n]
end

local function AddFront(object, text)
    if object and object:GetText() then
        text = text or ' '
        object:SetText(text .. '|n' .. object:GetText())
        object:Show()
    end
end

function GameTooltip:AppendLineFront(toLine, textLeft, textRight)
    if self:NumLines() >= toLine then
        local fontLeft, fontRight = self:GetFontStrings(toLine)
        AddFront(fontLeft, textLeft)
        AddFront(fontRight, textRight)
    elseif textRight then
        self:AddDoubleLine(textLeft, textRight)
    else
        self:AddLine(textLeft)
    end
end

function GameTooltip:AppendLineFrontLeft(toLine, text)
    return self:AppendLineFront(toLine, text)
end

function GameTooltip:AppendLineFrontRight(toLine, text)
    return self:AppendLineFront(toLine, nil, text)
end
