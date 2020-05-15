-- Inspect.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/15/2020, 4:08:09 PM

---@type ns
local ns = select(2, ...)

local DB = {}
local ALA_PREFIX = 'ATEADD'
local ALA_CMD_LEN = 6
local INSPECTED_NAME

C_ChatInfo.RegisterAddonMessagePrefix(ALA_PREFIX)

local INSPECT_INDEX = tIndexOf(UnitPopupMenus.FRIEND, 'WHISPER') + 1

UnitPopupButtons.INSPECT.dist = nil
tinsert(UnitPopupMenus.FRIEND, INSPECT_INDEX, 'INSPECT')

local function GetInspectUnit()
    local unit = InspectFrame and InspectFrame.unit
    if unit == 'none' then
        unit = nil
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
    if self.value == 'INSPECT' then
        local fullName = UIDROPDOWNMENU_INIT_MENU.chatTarget
        if fullName then
            Inspect(Ambiguate(fullName, 'none'))
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
                DB[name][slot] = link
            end
        end
    end
end)

ns.addon('Blizzard_InspectUI', function()
    local InspectFrame = InspectFrame

    InspectFrame:UnregisterEvent('PLAYER_TARGET_CHANGED')
    InspectFrame:UnregisterEvent('GROUP_ROSTER_UPDATE')

    InspectFrame:HookScript('OnShow', function()
        if not GetInspectUnit() then
            InspectNameText:SetText(INSPECTED_NAME)
            InspectFramePortrait:SetTexture([[Interface\FriendsFrame\FriendsFrameScrollIcon]])
        end
    end)

    InspectFrame:HookScript('OnHide', function()
        INSPECTED_NAME = nil
    end)

    ns.securehook('InspectPaperDollItemSlotButton_Update', function(button)
        if button.hasItem then
            return
        end

        button.itemId = nil

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

                button.itemId = tonumber(link:match('item:(%d+)'))
                button:RegisterEvent('GET_ITEM_INFO_RECEIVED')
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

    ns.securehook('InspectPaperDollItemSlotButton_OnEvent', function(button, event, id, ok)
        if event == 'GET_ITEM_INFO_RECEIVED' then
            if ok and button.itemId == id then
                InspectPaperDollItemSlotButton_Update(button)
            end
        end
    end)

    ns.hook('InspectPaperDollItemSlotButton_OnClick', function(orig, button)
        local link = GetInspectItemLink(button:GetID())
        if link then
            HandleModifiedItemClick(link)
        end
    end)

    ns.hook('InspectPaperDollFrame_SetLevel', function(orig)
        if GetInspectUnit() then
            orig()
        else
            InspectLevelText:SetText('')
        end
    end)
end)
