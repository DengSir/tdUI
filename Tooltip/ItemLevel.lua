-- ItemLevel.lua
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

GameTooltipText:SetSpacing(2)

local function GetTextLeft(tip, line)
    local name = tip:GetName()
    return name and _G[name .. 'TextLeft' .. line]
end

local function GetTextRight(tip, line)
    local name = tip:GetName()
    return name and _G[name .. 'TextRight' .. line]
end

local function AddFront(object, text)
    if object and object:GetText() then
        text = text or ' '
        object:SetText(text .. '|n' .. object:GetText())
        object:Show()
    end
end

local function AddLineFront(tip, line, leftText, rightText)
    if tip:NumLines() >= line then
        local textLeft = GetTextLeft(tip, line)
        local textRight = GetTextRight(tip, line)

        if tip.hasMoney and tip.shownMoneyFrames then
            for i = 1, tip.shownMoneyFrames do
                local moneyFrame = _G[tip:GetName() .. 'MoneyFrame' .. i]
                local p, r, rp, x, y = moneyFrame:GetPoint(1)

                if r == textLeft then
                    moneyFrame:SetPoint(p, r, rp, x, -textLeft:GetHeight() / 2 - 1)
                end
            end
        end

        AddFront(textRight, rightText)
        AddFront(textLeft, leftText)

    elseif rightText then
        tip:AddDoubleLine(leftText, rightText)
    else
        tip:AddLine(leftText, rightText)
    end
end

local function OnTooltipItem(tip, item)
    if not item then
        return
    end

    local name, _, _, level, _, _, _, _, equipLoc, icon = GetItemInfo(item)
    if not name then
        return
    end

    local nameLineNum = GetTextLeft(tip, 1):GetText() == CURRENTLY_EQUIPPED and 2 or 1

    if not ns.profile.tooltip.itemLevelOnlyEquip or (not INVALID_EQUIP_LOC[equipLoc] and IsEquippableItem(item)) then
        if level and level > 1 then
            AddLineFront(tip, nameLineNum + 1, format(ITEM_LEVEL, level))
        end
    end

    if ns.profile.tooltip.itemIcon then
        local nameLine = GetTextLeft(tip, nameLineNum)
        if icon and nameLine:GetText() then
            nameLine:SetFormattedText('|T%s:18|t %s', icon, nameLine:GetText())
        end
    end

    tip:Show()
end

local function OnTooltipSetItem(tip)
    if tip.__tditemlevel then
        return
    end

    local _, item = tip:GetItem()
    if item then
        OnTooltipItem(tip, item)
        tip.__tditemlevel = true
    end
end

local function OnTooltipCleared(tip)
    tip.__tditemlevel = nil
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
