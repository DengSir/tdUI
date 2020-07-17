-- Item.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/17/2020, 12:43:36 AM

---@type ns
local ns = select(2, ...)

local _G = _G

local format = string.format

local GetItemInfo = GetItemInfo
local IsEquippableItem = IsEquippableItem

local ITEM_LEVEL = NORMAL_FONT_COLOR_CODE .. ITEM_LEVEL_PLUS:gsub(' *%%d%+$', ' %%d') .. '|r'
local CURRENTLY_EQUIPPED = CURRENTLY_EQUIPPED

local INVALID_EQUIP_LOC = {[''] = true, ['INVTYPE_BAG'] = true, ['INVTYPE_AMMO'] = true}

---@param tip GameTooltip
local function OnTooltipItem(tip, item)
    if not item then
        return
    end

    local name, _, rarity, level, _, _, _, _, equipLoc, icon = GetItemInfo(item)
    if not name then
        return
    end

    local nameLineNum = tip:GetFontStringLeft(1):GetText() == CURRENTLY_EQUIPPED and 2 or 1

    if not ns.profile.tooltip.item.itemLevelOnlyEquip or (not INVALID_EQUIP_LOC[equipLoc] and IsEquippableItem(item)) then
        if level and level > 1 then
            tip:AppendLineFrontLeft(nameLineNum + 1, format(ITEM_LEVEL, level))
        end
    end

    if ns.profile.tooltip.item.icon then
        local nameLine = tip:GetFontStringLeft(nameLineNum)
        if icon and nameLine:GetText() then
            nameLine:SetFormattedText('|T%s:18|t %s', icon, nameLine:GetText())
        end
    end

    tip:Show()
end

local function OnTooltipSetItem(tip)
    if tip._tdtipitem then
        return
    end

    local _, item = tip:GetItem()
    if item then
        OnTooltipItem(tip, item)
        tip._tdtipitem = true
    end
end

local function OnTooltipCleared(tip)
    tip._tdtipitem = nil
end

local function HookTip(tip)
    tip:HookScript('OnTooltipSetItem', OnTooltipSetItem)
    tip:HookScript('OnTooltipCleared', OnTooltipCleared)
    tip:HookScript('OnHide', OnTooltipCleared)
end

HookTip(GameTooltip)
HookTip(ItemRefTooltip)
HookTip(ShoppingTooltip1)
HookTip(ShoppingTooltip2)
