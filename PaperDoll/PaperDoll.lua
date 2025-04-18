-- Glow.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/8/2020, 11:38:04 PM
---@type ns
local ns = select(2, ...)

local _G = _G

local ipairs = ipairs
local format = string.format
local select = select
local tonumber = tonumber

local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemQualityColor = GetItemQualityColor
local GetInventoryItemDurability = GetInventoryItemDurability
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = GetItemInfo

local SLOTS = {
    'Back',
    'Chest',
    'Feet',
    'Finger0',
    'Finger1',
    'Hands',
    'Head',
    'Legs',
    'MainHand',
    'Neck',
    'Ranged',
    'SecondaryHand',
    'Shirt',
    'Shoulder',
    'Tabard',
    'Trinket0',
    'Trinket1',
    'Waist',
    'Wrist',
}

local BUTTONS = {}

local function IsOurButton(button)
    return BUTTONS[button]
end

local function InitButton(button, unit)
    -- button.IconBorder:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
    -- button.IconBorder:SetBlendMode('ADD')
    -- button.IconBorder:ClearAllPoints()
    -- button.IconBorder:SetPoint('CENTER')
    -- button.IconBorder:SetSize(67, 67)

    button.Durability = _G[button:GetName() .. 'Stock']
    -- button.Durability:ClearAllPoints()
    -- button.Durability:SetPoint('BOTTOM', 0, 3)

    button.Count = button.Count or _G[button:GetName() .. 'Count']

    -- button.LevelText = button:CreateFontString(nil, 'OVERLAY', 'TextStatusBarText')
    -- button.LevelText:SetPoint('BOTTOMLEFT', 1, 0)
    -- button.LevelText:Hide()

    BUTTONS[button] = unit
end

local function InitButtons(formatter, unit)
    for i, slot in ipairs(SLOTS) do
        InitButton(_G[format(formatter, slot)], unit)
    end
end

local function GetPrecColor(value)
    local r, g, b
    if value > 0.5 then
        r = (1.0 - value) * 2
        g = 1.0
    else
        r = 1.0
        g = value * 2
    end
    b = 0.0
    return r, g, b
end

local function GetQuality(button)
    local unit = BUTTONS[button]
    if unit == 'inspect' then
        unit = InspectFrame.unit
    end
    return GetInventoryItemQuality(unit, button:GetID())
end

local function GetItemSlotLevel(unit, index)
    local level
    local itemLink = GetInventoryItemLink(unit, index)
    if itemLink then
        level = select(4, GetItemInfo(itemLink))
    end
    return tonumber(level) or 0
end

local function GetLevel(button)
    local unit = BUTTONS[button]
    if unit == 'inspect' then
        unit = InspectFrame.unit
    end
    return GetItemSlotLevel(unit, button:GetID())
end

local function UpdateQuality(button)
    local quality = GetQuality(button)
    if quality and quality > 1 then
        local r, g, b = GetItemQualityColor(quality)
        button.IconBorder:SetVertexColor(r, g, b)
        button.IconBorder:Show()
        local level = GetLevel(button)
        if level > 0 then
            local color = ns.CUSTOM_ITEM_QUALITY_COLORS[quality]
            button.Count:SetText(level)
            button.Count:SetTextColor(color.r, color.g, color.b, 1)
            button.Count:Show()
        else
            button.Count:Hide()
        end
    else
        button.IconBorder:Hide()
        button.Count:Hide()
    end
end

local function UpdateDurability(button)
    local cur, max = GetInventoryItemDurability(button:GetID())
    if not cur or cur == max then
        button.Durability:Hide()
    else
        local perc = cur / max
        button.Durability:SetText(format('%d%%', perc * 100))
        button.Durability:SetTextColor(GetPrecColor(perc))
        button.Durability:Show()
    end
end

local function gen(f)
    return function(self, ...)
        if not IsOurButton(self) then
            return
        end
        return f(self, ...)
    end
end

local function hook(k, v)
    return ns.securehook(k, gen(v))
end

hook('PaperDollItemSlotButton_Update', function(self)
    UpdateQuality(self)
    UpdateDurability(self)
end)

hook('PaperDollItemSlotButton_OnShow', function(self)
    self:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
end)

hook('PaperDollItemSlotButton_OnHide', function(self)
    self:UnregisterEvent('UPDATE_INVENTORY_DURABILITY')
end)

hook('PaperDollItemSlotButton_OnEvent', function(self, event)
    if event == 'UPDATE_INVENTORY_DURABILITY' then
        UpdateDurability(self)
    end
end)

InitButtons('Character%sSlot', 'player')
