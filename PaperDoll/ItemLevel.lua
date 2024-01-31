-- ItemLevel.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2022/11/7 13:44:29
--
local function GetSlotItemLevel(slot)
    local itemId = GetInventoryItemID('player', slot)
    if not itemId then
        return 0
    end

    local itemLevel = select(4, GetItemInfo(itemId))
    if itemLevel then
        return itemLevel
    end
end

local function GetMainhandItemLevel(slot)
    local itemId = GetInventoryItemID('player', slot)
    if not itemId then
        return 0
    end
    local itemLevel, _, _, _, _, itemEquipLoc = select(4, GetItemInfo(itemId))
    if itemEquipLoc == 'INVTYPE_2HWEAPON' then
        return itemLevel * 2
    end
    return itemLevel
end

local function GetRangedItemLevel(slot)
    if UnitClassBase('player') ~= 'HUNTER' then
        return 0, true
    end
    return GetSlotItemLevel(slot)
end

local SLOTS = {
    [INVSLOT_HEAD] = GetSlotItemLevel,
    [INVSLOT_NECK] = GetSlotItemLevel,
    [INVSLOT_SHOULDER] = GetSlotItemLevel,
    [INVSLOT_CHEST] = GetSlotItemLevel,
    [INVSLOT_WAIST] = GetSlotItemLevel,
    [INVSLOT_LEGS] = GetSlotItemLevel,
    [INVSLOT_FEET] = GetSlotItemLevel,
    [INVSLOT_WRIST] = GetSlotItemLevel,
    [INVSLOT_HAND] = GetSlotItemLevel,
    [INVSLOT_FINGER1] = GetSlotItemLevel,
    [INVSLOT_FINGER2] = GetSlotItemLevel,
    [INVSLOT_TRINKET1] = GetSlotItemLevel,
    [INVSLOT_TRINKET2] = GetSlotItemLevel,
    [INVSLOT_BACK] = GetSlotItemLevel,
    [INVSLOT_MAINHAND] = GetMainhandItemLevel,
    [INVSLOT_OFFHAND] = GetSlotItemLevel,
    [INVSLOT_RANGED] = GetRangedItemLevel,
}

local function GetItemLevel()
    local total, count = 0, 0

    for slot, f in pairs(SLOTS) do
        local itemLevel, ignore = f(slot)
        if not itemLevel then
            return
        end
        if not ignore then
            count = count + 1
            total = total + itemLevel
        end
    end
    return total / count
end

---@class ItemLevelFrame: Frame
local ItemLevelFrame = CreateFrame('Frame', nil, PaperDollFrame)

function ItemLevelFrame:OnLoad()
    self.Text = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
    self.Text:SetPoint('BOTTOMLEFT', PlayerStatFrameLeftDropDown, 'TOPLEFT', 24, 5)

    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.UnregisterAllEvents)
    self:SetScript('OnEvent', self.Update)
end

function ItemLevelFrame:OnShow()
    self:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    self:Update()
end

function ItemLevelFrame:Update()
    self.Text:SetFormattedText('iLvl: %d', (select(2, GetAverageItemLevel())))
end

ItemLevelFrame:OnLoad()
