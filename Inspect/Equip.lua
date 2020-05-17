-- Equip.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/18/2020, 1:28:20 AM

---@type ns
local ns = select(2, ...)
local Inspect = ns.Inspect

ns.addon('Blizzard_InspectUI', function()
    local EquipFrame = Inspect:CreateTab('Equip', 135005)

    local EQUIP_BUTTONS = {}

    local EQUIP_SLOTS = {
        {id = 1, name = HEADSLOT}, --
        {id = 2, name = NECKSLOT}, --
        {id = 3, name = SHOULDERSLOT}, --
        {id = 15, name = BACKSLOT}, --
        {id = 5, name = CHESTSLOT}, --
        {id = 9, name = WRISTSLOT}, --
        {id = 10, name = HANDSSLOT}, --
        {id = 6, name = WAISTSLOT}, --
        {id = 7, name = LEGSSLOT}, --
        {id = 8, name = FEETSLOT}, --
        {id = 11, name = FINGER0SLOT}, --
        {id = 12, name = FINGER1SLOT}, --
        {id = 13, name = TRINKET0SLOT}, --
        {id = 14, name = TRINKET1SLOT}, --
        {id = 16, name = MAINHANDSLOT}, --
        {id = 17, name = SECONDARYHANDSLOT}, --
        {id = 18, name = RANGEDSLOT}, --
    }

    local CreateEquipButton = (function()
        local EQUIP_HEIGHT = 17
        local EQUIP_SPACING = 0
        local EQUIP_MARGIN = 9

        ---@class EquipButton: Button
        ---@field Name FontString
        ---@field ItemLevel FontString
        ---@field Slot FontString
        ---@field SlotBg Frame

        local function OnEnter(button)
            local item = Inspect:GetItemLink(button:GetID())
            if item then
                GameTooltip:SetOwner(button, 'ANCHOR_RIGHT')
                GameTooltip:SetHyperlink(item)
                GameTooltip:Show()
            end
        end

        ---@return EquipButton
        return function(parent, id, name, index)
            local y = -(index - 1) * (EQUIP_HEIGHT + EQUIP_SPACING) - EQUIP_MARGIN

            ---@type EquipButton
            local button = CreateFrame('Button', nil, parent)
            button:SetHeight(EQUIP_HEIGHT)
            button:SetPoint('TOPLEFT', 10, y)
            button:SetPoint('TOPRIGHT', -10, y)
            button:SetID(id)
            button:SetScript('OnEnter', OnEnter)
            button:SetScript('OnLeave', GameTooltip_Hide)
            button.UpdateTooltip = OnEnter

            local Slot = button:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
            Slot:SetFont(Slot:GetFont(), 12, 'OUTLINE')
            Slot:SetWidth(38)
            Slot:SetPoint('LEFT')
            Slot:SetText(name)

            local ItemLevel = button:CreateFontString(nil, 'ARTWORK', 'TextStatusBarText')
            ItemLevel:SetFont(ItemLevel:GetFont(), 14, 'OUTLINE')
            ItemLevel:SetWidth(20)
            ItemLevel:SetJustifyH('LEFT')
            ItemLevel:SetPoint('LEFT', Slot, 'RIGHT', 5, 0)

            local Name = button:CreateFontString(nil, 'ARTWORK', 'ChatFontNormal')
            Name:SetFont(Name:GetFont(), 13)
            Name:SetWordWrap(false)
            Name:SetJustifyH('LEFT')
            Name:SetPoint('LEFT', ItemLevel, 'RIGHT', 5, 0)
            Name:SetPoint('RIGHT')

            local ht = button:CreateTexture(nil, 'HIGHLIGHT')
            ht:SetAllPoints(true)
            ht:SetColorTexture(0.5, 0.5, 0.5, 0.3)

            if index % 2 == 1 then
                local bg = button:CreateTexture(nil, 'BACKGROUND')
                bg:SetAllPoints(true)
                bg:SetColorTexture(0.3, 0.3, 0.3, 0.3)
            end

            button.Name = Name
            button.ItemLevel = ItemLevel
            button.Slot = Slot

            return button
        end
    end)()

    for i, v in ipairs(EQUIP_SLOTS) do
        EQUIP_BUTTONS[v.id] = CreateEquipButton(EquipFrame, v.id, v.name, i)
    end

    ---@param button EquipButton
    local function UpdateEquip(button)
        local id = button:GetID()
        local item = Inspect:GetItemLink(id)
        if item then
            local name, link, quality, itemLevel = GetItemInfo(item)
            if name then
                local r, g, b = GetItemQualityColor(quality)

                button.Name:SetText(name)
                button.Name:SetTextColor(r, g, b)
                button.Slot:SetTextColor(r, g, b)
                button.ItemLevel:SetText(itemLevel)
                return
            else
                ns.waititem(item, button, UpdateEquip)
            end
        end

        local r, g, b = 0.6, 0.6, 0.6
        button.Name:SetText('')
        button.Slot:SetTextColor(r, g, b)
        button.ItemLevel:SetText('')
    end

    local function UpdateEquips()
        for id, button in pairs(EQUIP_BUTTONS) do
            UpdateEquip(button, id)
        end
    end

    EquipFrame:SetScript('OnShow', UpdateEquips)

    Inspect:Callback(function()
        UpdateEquips()
    end)
end)
