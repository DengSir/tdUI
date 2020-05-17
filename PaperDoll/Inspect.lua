-- Inspect.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/15/2020, 4:08:09 PM

---@type ns
local ns = select(2, ...)

local Ambiguate = Ambiguate
local UnitName = UnitName
local SetPortraitTexture = SetPortraitTexture
local GetInventoryItemLink = GetInventoryItemLink
local CheckInteractDistance = CheckInteractDistance

---@type GameTooltip
local GameTooltip = GameTooltip

local DB = {}

local ALA_PREFIX = 'ATEADD'
local ALA_CMD_LEN = 6

---@type EquipButton[]
local EQUIP_BUTTONS = {}

local INSPECTED_NAME

ns.addon('Blizzard_InspectUI', function()
    local InspectFrame = InspectFrame
    local InspectPaperDollFrame = InspectPaperDollFrame

    local InspectNameText = InspectNameText
    local InspectFaction = InspectFaction
    local InspectModelFrame = InspectModelFrame
    local InspectFramePortrait = InspectFramePortrait

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

    InspectFrame:UnregisterEvent('PLAYER_TARGET_CHANGED')
    InspectFrame:UnregisterEvent('GROUP_ROSTER_UPDATE')

    InspectFaction:SetPoint('CENTER', InspectPaperDollFrame, 'CENTER', -10, 20)

    ---@type Texture
    local RaceBackground = InspectPaperDollFrame:CreateTexture(nil, 'ARTWORK')
    RaceBackground:SetPoint('TOPLEFT', 65, -76)
    RaceBackground:SetPoint('BOTTOMRIGHT', -85, 115)
    RaceBackground:SetAtlas('transmog-background-race-draenei')
    RaceBackground:SetDesaturated(true)

    do
        local t1 = InspectMainHandSlot:CreateTexture(nil, 'BACKGROUND', 'Char-BottomSlot', -1)
        t1:ClearAllPoints()
        t1:SetPoint('TOPLEFT', -4, 8)

        local t2 = InspectMainHandSlot:CreateTexture(nil, 'BACKGROUND', 'Char-Slot-Bottom-Left')
        t2:ClearAllPoints()
        t2:SetPoint('TOPRIGHT', t1, 'TOPLEFT')

        local t3 = InspectSecondaryHandSlot:CreateTexture(nil, 'BACKGROUND', 'Char-BottomSlot', -1)
        t3:ClearAllPoints()
        t3:SetPoint('TOPLEFT', -4, 8)

        local t4 = InspectRangedSlot:CreateTexture(nil, 'BACKGROUND', 'Char-BottomSlot', -1)
        t4:ClearAllPoints()
        t4:SetPoint('TOPLEFT', -4, 8)

        local t5 = InspectRangedSlot:CreateTexture(nil, 'BACKGROUND', 'Char-Slot-Bottom-Right')
        t5:ClearAllPoints()
        t5:SetPoint('TOPLEFT', t4, 'TOPRIGHT')
    end

    local CreateTab = (function()
        local id = 0
        local tabFrame = {Tabs = {}, selectedTab = 1}

        local function UpdateTabs(id)
            id = id or tabFrame.selectedTab
            for _, tab in pairs(tabFrame.Tabs) do
                tab.frame:SetShown(tab:GetID() == id)
            end
            PanelTemplates_SetTab(tabFrame, id)
        end

        local function OnClick(self)
            return UpdateTabs(self:GetID())
        end

        return function(text)
            id = id + 1

            ---@type Button
            local tab = CreateFrame('Button', 'tdInspectTab' .. id, InspectPaperDollFrame,
                                    'CharacterFrameTabButtonTemplate')
            tab:SetFrameLevel(InspectModelFrame:GetFrameLevel() + 100)
            tab:SetText(text)
            tab:SetID(id)
            tab:SetScript('OnClick', OnClick)

            if id == 1 then
                tab:SetPoint('CENTER', InspectPaperDollFrame, 'BOTTOMRIGHT', -78, 62)
            else
                tab:SetPoint('RIGHT', tabFrame.Tabs[id - 1], 'LEFT', 16, 0)
            end

            local frame = CreateFrame('Frame', nil, InspectPaperDollFrame)
            frame:SetPoint('TOPLEFT', 65, -76)
            frame:SetPoint('BOTTOMRIGHT', -85, 115)
            frame:SetShown(id == 0)

            tab.frame = frame
            tinsert(tabFrame.Tabs, tab)
            PanelTemplates_SetNumTabs(tabFrame, #tabFrame.Tabs)
            UpdateTabs()

            return frame
        end
    end)()

    local CreateEquipButton = (function()
        local EQUIP_HEIGHT = 17
        local EQUIP_SPACING = 0
        local EQUIP_MARGIN = 9
        local EQUIP_SLOTBACKDROP = {
            bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
            edgeFile = 'Interface\\Buttons\\WHITE8X8',
            tile = true,
            tileSize = 8,
            edgeSize = 1,
            insets = {left = 1, right = 1, top = 1, bottom = 1},
        }

        ---@class EquipButton: Button
        ---@field Name FontString
        ---@field ItemLevel FontString
        ---@field Slot FontString
        ---@field SlotBg Frame

        local function OnEnter(button)
            local item = GetInspectItemLink(button:GetID())
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

    local EquipFrame = CreateTab('Equip')
    local ModalFrame = CreateTab('Modal')

    InspectModelFrame:SetParent(ModalFrame)
    InspectFaction:SetParent(ModalFrame)

    for i, v in ipairs(EQUIP_SLOTS) do
        EQUIP_BUTTONS[v.id] = CreateEquipButton(EquipFrame, v.id, v.name, i)
    end

    local factionLogoTextures = {
        ['Alliance'] = 'Interface\\Timer\\Alliance-Logo',
        ['Horde'] = 'Interface\\Timer\\Horde-Logo',
        ['Neutral'] = 'Interface\\Timer\\Panda-Logo',
    }

    local function UpdateCharacter()
        local race
        local unit = GetInspectUnit()
        if unit then
            INSPECTED_NAME = UnitName(unit)
            SetPortraitTexture(InspectFramePortrait, unit)
            InspectNameText:SetText(GetUnitName(unit, true))
            race = select(2, UnitRace(unit))
        else
            InspectNameText:SetText(INSPECTED_NAME)
            InspectFramePortrait:SetTexture([[Interface\FriendsFrame\FriendsFrameScrollIcon]])
        end

        if not race then
            race = select(2, UnitRace('player'))
        end

        RaceBackground:SetAtlas('transmog-background-race-' .. race:lower())
    end

    local function UpdateModal()
        local unit = GetInspectUnit()
        if unit then
            InspectModelFrame:Show()

            if InspectModelFrame:SetUnit(unit) then
                InspectModelFrame:Show()
                InspectFaction:Hide()
                -- SetPaperDollBackground(InspectModelFrame, unit)
                return
            end
        end

        InspectModelFrame:Hide()
        InspectFaction:SetTexture(factionLogoTextures[UnitFactionGroup(unit or 'player')])
        InspectFaction:Show()
    end

    ---@param button EquipButton
    local function UpdateEquip(button)
        local id = button:GetID()
        local item = GetInspectItemLink(id)
        if item then
            local name, link, quality, itemLevel = GetItemInfo(item)
            if name then
                local r, g, b = GetItemQualityColor(quality)

                button.Name:SetText(name)
                button.Name:SetTextColor(r, g, b)
                -- button.SlotBg:SetBackdropBorderColor(r, g, b, 0.2)
                -- button.SlotBg:SetBackdropColor(r, g, b, 0.2)
                button.Slot:SetTextColor(r, g, b)
                button.ItemLevel:SetText(itemLevel)
                return
            else
                ns.waititem(item, button, UpdateEquip)
            end
        end

        local r, g, b = 0.6, 0.6, 0.6
        button.Name:SetText('')
        -- button.SlotBg:SetBackdropBorderColor(r, g, b, 0.2)
        -- button.SlotBg:SetBackdropColor(r, g, b, 0.2)
        button.Slot:SetTextColor(r, g, b)
        button.ItemLevel:SetText('')
    end

    local function UpdateEquips()
        for id, button in pairs(EQUIP_BUTTONS) do
            UpdateEquip(button, id)
        end
    end

    ModalFrame:SetScript('OnShow', UpdateModal)
    EquipFrame:SetScript('OnShow', UpdateEquips)

    InspectFrame:SetScript('OnShow', function()
        UpdateCharacter()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    end)

    InspectFrame:HookScript('OnHide', function()
        INSPECTED_NAME = nil
    end)

    InspectPaperDollFrame:SetScript('OnShow', function()
        print('OnShow')
        UpdateModal()
        InspectPaperDollFrame_SetLevel()
        InspectPaperDollFrame_UpdateButtons()
    end)

    ns.event('PLAYER_TARGET_CHANGED', function()
        if InspectFrame.unit == 'target' then
            InspectFrame.unit = 'none'
            UpdateCharacter()
            UpdateModal()
        end
    end)

    ns.securehook('InspectPaperDollFrame_UpdateButtons', UpdateEquips)

    ns.hook('InspectPaperDollFrame_SetLevel', function(orig)
        if GetInspectUnit() then
            orig()
        else
            InspectLevelText:SetText('')
        end
    end)
end)
