-- Api.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/8/2020, 2:09:59 PM
--
---@class ns
local ns = select(2, ...)

ns.IS_CLASSIC = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
ns.IS_RETAIL = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

local _G = _G
local ipairs = ipairs
local unpack = table.unpack or unpack
local tinsert = table.insert
local format = string.format

local LibShowUIPanel = LibStub('LibShowUIPanel-1.0', true)
ns.ShowUIPanel = LibShowUIPanel and LibShowUIPanel.ShowUIPanel or ShowUIPanel
ns.HideUIPanel = LibShowUIPanel and LibShowUIPanel.HideUIPanel or HideUIPanel

local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

ns.debug = (function()
    local Log = LibStub('LibLog-1.0', true)
    if Log then
        local logger = Log:GetLogger()
        return function(...)
            return logger:Debug(...)
        end
    end
    return nop
end)()

function ns.rgb(r, g, b)
    if b then
        return r, g, b
    elseif r.r then
        return r.r, r.g, r.b
    else
        return unpack(r)
    end
end

function ns.point(frame, ...)
    if frame then
        frame:ClearAllPoints()
        frame:SetPoint(...)
    end
end

function ns.GetAceConfig(k)
    return LibStub('AceConfigRegistry-3.0'):GetOptionsTable(k, 'dialog', 'Inject-1.0')
end

function ns.RemoveAceConfig(registry, ...)
    local options = type(registry) == 'table' and registry or ns.GetAceConfig(registry)
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

function ns.GetFrames(nameTemplate, count, ...)
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

local function OnFinished(fade)
    fade:Stop()

    if not fade.fadeIn then
        fade:GetParent():Hide()
    end
end

local fades = setmetatable({}, {
    __index = function(t, frame)
        local fade = frame:CreateAnimationGroup()
        local alpha = fade:CreateAnimation('Alpha')
        alpha:SetOrder(1)
        fade:SetToFinalAlpha(true)
        fade:SetScript('OnFinished', OnFinished)
        fade.alpha = alpha
        t[frame] = fade
        return fade
    end,
})

function ns.FadeIn(frame, seconds)
    local fade = fades[frame]
    frame:Show()
    fade:Stop()
    fade.alpha:SetFromAlpha(0)
    fade.alpha:SetToAlpha(1)
    fade.alpha:SetDuration(seconds or 0.2)
    fade:Play()
    fade.fadeIn = true
end

function ns.FadeOut(frame, seconds)
    local fade = fades[frame]
    fade:Stop()
    fade.alpha:SetFromAlpha(1)
    fade.alpha:SetToAlpha(0)
    fade.alpha:SetDuration(seconds or 0.2)
    fade:Play()
    fade.fadeIn = nil
end

local hider
function ns.hide(obj)
    if not obj then
        print('hide nil object')
        return
    end
    if not hider then
        hider = CreateFrame('Frame')
        hider:Hide()
    end
    obj:Hide()
    obj:SetParent(hider)
end

function ns.teq(a, b)
    if not a or not b then
        return false
    end
    for k, v in pairs(a) do
        if v ~= b[k] then
            return false
        end
    end
    for k, v in pairs(b) do
        if v ~= a[k] then
            return false
        end
    end
    return true
end

local SOLO_UNITS = {'player'}
local PARTY_UNITS = {'player'}
local RAID_UNITS = {}

for i = 1, 4 do
    tinsert(PARTY_UNITS, 'party' .. i)
end

for i = 1, 40 do
    tinsert(RAID_UNITS, 'raid' .. i)
end

function ns.IterateGroup()
    if IsInRaid(1) then
        return ipairs(RAID_UNITS)
    elseif IsInGroup(1) then
        return ipairs(PARTY_UNITS)
    else
        return ipairs(SOLO_UNITS)
    end
end

local CUSTOM_ITEM_QUALITY_COLORS = {}
CUSTOM_ITEM_QUALITY_COLORS[0] = {r = 0.72, g = 0.72, b = 0.72}
CUSTOM_ITEM_QUALITY_COLORS[1] = {r = 1.0, g = 1.0, b = 1.0}
CUSTOM_ITEM_QUALITY_COLORS[2] = {r = 0.3, g = 1.0, b = 0.38}
CUSTOM_ITEM_QUALITY_COLORS[3] = {r = 0.4, g = 0.71, b = 1.0}
CUSTOM_ITEM_QUALITY_COLORS[4] = {r = 0.97, g = 0.63, b = 0.83}
CUSTOM_ITEM_QUALITY_COLORS[5] = {r = 1, g = 0.602, b = 0.2}
CUSTOM_ITEM_QUALITY_COLORS[6] = {r = 0.94, g = 0.87, b = 0.67}
CUSTOM_ITEM_QUALITY_COLORS[7] = {r = 0.2, g = 0.84, b = 1.0}
CUSTOM_ITEM_QUALITY_COLORS[8] = {r = 0.2, g = 0.84, b = 1.0}
ns.CUSTOM_ITEM_QUALITY_COLORS = CUSTOM_ITEM_QUALITY_COLORS
