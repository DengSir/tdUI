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

local INSPECT_INDEX = tIndexOf(UnitPopupMenus.FRIEND, 'WHISPER') + 1
do
    UnitPopupButtons.INSPECT.dist = nil
    tinsert(UnitPopupMenus.FRIEND, INSPECT_INDEX, 'INSPECT')
    C_ChatInfo.RegisterAddonMessagePrefix(ALA_PREFIX)
end

---------------

local function GetInspectUnit()
    local unit = InspectFrame and InspectFrame.unit or INSPECTED_UNIT
    if not unit or unit == 'none' then
        return
    end
    return unit
end

local function GetInspectUnitName(unit)
    local name
    local unit = unit and GetInspectUnit()
    if unit then
        name = UnitName(unit)
    else
        name = INSPECTED_NAME
    end
    return Ambiguate(name, 'none')
end

local function GetInspectItemLink(id)
    local link
    local unit = GetInspectUnit()
    if unit then
        link = GetInventoryItemLink(unit, id)
    end

    if not link then
        local name = GetInspectUnitName(unit)
        local data = name and DB[name]
        if data then
            link = data[id]
        end
    end
    return link
end

local function Inspect(name, unit)
    if not InspectFrame then
        LoadAddOn('Blizzard_InspectUI')
    end
    HideUIPanel(InspectFrame)

    INSPECTED_NAME = name
    INSPECTED_UNIT = unit or 'none'
    InspectFrame.unit = unit or 'none'

    if DB[name] then
        ShowUIPanel(InspectFrame)
        InspectSwitchTabs(1)
    end

    C_ChatInfo.SendAddonMessage(ALA_PREFIX, '_q_equ', 'WHISPER', name)
end

ns.securehook('UnitPopup_HideButtons', function()
    if UIDROPDOWNMENU_INIT_MENU.which == 'FRIEND' then
        UnitPopupShown[1][INSPECT_INDEX] = 1
    end
end)

ns.securehook('UnitPopup_OnClick', function(self)
    if self.value == 'INSPECT' and not UIDROPDOWNMENU_INIT_MENU.unit then
        local name = UIDROPDOWNMENU_INIT_MENU.chatTarget
        if name then
            Inspect(Ambiguate(name, 'none'))
        end
    end
end)

ns.hook('InspectUnit', function(orig, unit)
    if not unit then
        return
    end

    if CheckInteractDistance(unit, 1) then
        orig(unit)
    else
        Inspect(UnitName(unit), unit)
    end
end)

ns.event('CHAT_MSG_ADDON', function(prefix, msg, channel, sender)
    if prefix ~= ALA_PREFIX then
        return
    end

    local cmd = msg:sub(1, ALA_CMD_LEN)
    if cmd == '_r_equ' then
        local sep = msg:sub(ALA_CMD_LEN + 1, ALA_CMD_LEN + 1)
        local data = {strsplit(sep, msg:sub(ALA_CMD_LEN + 2))}

        local name = Ambiguate(sender, 'none')
        DB[name] = DB[name] or {}

        for i = 1, #data, 2 do
            local slot, link = tonumber(data[i]), data[i + 1]
            if link ~= 'item:-1' then
                DB[name][slot] = link
            end
        end

        if INSPECTED_NAME == name then
            ShowUIPanel(InspectFrame)
            InspectSwitchTabs(1)
            -- InspectPaperDollFrame_UpdateButtons()
        end
    end
end)

ns.event('INSPECT_READY', function(guid)
    local unit = GetInspectUnit()
    if not unit then
        return
    end

    if UnitGUID(unit) ~= guid then
        return
    end

    local name = select(6, GetPlayerInfoByGUID(guid))
    if name then
        name = Ambiguate(name, 'none')

        DB[name] = DB[name] or {}

        for slot = 0, 18 do
            local link = GetInventoryItemLink(unit, slot)
            if link then
                DB[name][slot] = link:match('(item:[%-0-9:]+)')
            end
        end
    end
end)

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

    -- local frame = CreateFrame('Frame', nil, InspectPaperDollFrame)
    -- frame:SetPoint('TOPLEFT', 65, -76)
    -- frame:SetPoint('BOTTOMRIGHT', -85, 115)

    ---@type Texture
    local RaceBackground = InspectPaperDollFrame:CreateTexture(nil, 'ARTWORK')
    RaceBackground:SetPoint('TOPLEFT', 65, -76)
    RaceBackground:SetPoint('BOTTOMRIGHT', -85, 115)
    RaceBackground:SetAtlas('transmog-background-race-draenei')
    RaceBackground:SetDesaturated(true)

    local CreateTab = (function()
        local tabs = {}
        local index = 0
        local width, height = 60, 22

        local function OnClick(self)
            for tab, frame in pairs(tabs) do
                if self == tab then
                    tab:Disable()
                    frame:Show()
                else
                    tab:Enable()
                    frame:Hide()
                end
            end
        end

        return function(text)
            local tab = CreateFrame('Button', nil, InspectPaperDollFrame, 'UIPanelButtonTemplate')
            tab:SetSize(width, height)
            tab:SetPoint('TOPRIGHT', -50 - (index * width), -50)
            tab:SetFrameLevel(InspectModelFrame:GetFrameLevel() + 100)
            tab:SetText(text)
            tab:SetScript('OnClick', OnClick)
            tab:SetEnabled(index ~= 0)

            local frame = CreateFrame('Frame', nil, InspectPaperDollFrame)
            frame:SetPoint('TOPLEFT', 65, -76)
            frame:SetPoint('BOTTOMRIGHT', -85, 115)
            frame:SetShown(index == 0)
            index = index + 1

            tabs[tab] = frame

            return frame
        end
    end)()

    local CreateEquipButton = (function()
        local EQUIP_HEIGHT = 16
        local EQUIP_SPACING = 1
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

            ---@type Frame
            local SlotBg = CreateFrame('Frame', nil, button)
            SlotBg:SetSize(38, EQUIP_HEIGHT)
            SlotBg:SetPoint('LEFT')
            SlotBg:SetBackdrop(EQUIP_SLOTBACKDROP)

            local Slot = SlotBg:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
            Slot:SetFont(Slot:GetFont(), 12, 'OUTLINE')
            Slot:SetPoint('CENTER')
            Slot:SetText(name)

            local ItemLevel = button:CreateFontString(nil, 'ARTWORK', 'TextStatusBarText')
            ItemLevel:SetFont(ItemLevel:GetFont(), 14, 'OUTLINE')
            ItemLevel:SetWidth(20)
            ItemLevel:SetJustifyH('LEFT')
            ItemLevel:SetPoint('LEFT', SlotBg, 'RIGHT', 5, 0)

            local Name = button:CreateFontString(nil, 'ARTWORK', 'ChatFontNormal')
            Name:SetFont(Name:GetFont(), 13)
            Name:SetWordWrap(false)
            Name:SetJustifyH('LEFT')
            Name:SetPoint('LEFT', ItemLevel, 'RIGHT', 5, 0)
            Name:SetPoint('RIGHT')

            local ht = button:CreateTexture(nil, 'HIGHLIGHT')
            ht:SetAllPoints(true)
            ht:SetColorTexture(0.5, 0.5, 0.5, 0.3)

            local bg = button:CreateTexture(nil, 'BACKGROUND')
            bg:SetAllPoints(true)
            bg:SetColorTexture(0.3, 0.3, 0.3, 0.1)

            button.Name = Name
            button.ItemLevel = ItemLevel
            button.Slot = Slot
            button.SlotBg = SlotBg

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
                SetPaperDollBackground(InspectModelFrame, unit)
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
                button.SlotBg:SetBackdropBorderColor(r, g, b, 0.2)
                button.SlotBg:SetBackdropColor(r, g, b, 0.2)
                button.Slot:SetTextColor(r, g, b)
                button.ItemLevel:SetText(itemLevel)
                return
            else
                ns.waititem(item, button, UpdateEquip)
            end
        end

        local r, g, b = 0.6, 0.6, 0.6
        button.Name:SetText('')
        button.SlotBg:SetBackdropBorderColor(r, g, b, 0.2)
        button.SlotBg:SetBackdropColor(r, g, b, 0.2)
        button.Slot:SetTextColor(r, g, b)
        button.ItemLevel:SetText('')
    end

    local function UpdateEquips()
        print('UpdateEquips', debugstack())
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

    ns.securehook('InspectPaperDollItemSlotButton_Update', function(button)
        if button.hasItem then
            return
        end

        local link = GetInspectItemLink(button:GetID())
        if link then
            SetItemButtonTexture(button, GetItemIcon(link))
            button.hasItem = 1

            local quality = select(3, GetItemInfo(link))
            if quality and quality > 1 then
                local r, g, b = GetItemQualityColor(quality)
                button.IconBorder:SetVertexColor(r, g, b, 0.5)
                button.IconBorder:Show()
            else
                button.IconBorder:Hide()

                ns.waititem(link, button, InspectPaperDollItemSlotButton_Update)
            end
        end
    end)

    ns.securehook('InspectPaperDollItemSlotButton_OnEnter', function(button)
        if GameTooltip:GetItem() then
            return
        end
        local item = GetInspectItemLink(button:GetID())
        if item then
            GameTooltip:SetHyperlink(item)
        end
    end)

    ns.hook('InspectPaperDollFrame_SetLevel', function(orig)
        if GetInspectUnit() then
            orig()
        else
            InspectLevelText:SetText('')
        end
    end)

    function InspectPaperDollItemSlotButton_OnClick(button)
        local link = GetInspectItemLink(button:GetID())
        if link then
            HandleModifiedItemClick(link)
        end
    end
end)
