-- Inspect.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/15/2020, 4:08:09 PM

---@type ns
local ns = select(2, ...)

local ALA_PREFIX = 'ATEADD'
local ALA_CMD_LEN = 6
local NO_ITEM = 'item:-1'
local INSPECTED_NAME

C_ChatInfo.RegisterAddonMessagePrefix(ALA_PREFIX)

local INSPECT_INDEX = tIndexOf(UnitPopupMenus.FRIEND, 'WHISPER') + 1

UnitPopupButtons.INSPECT.dist = nil
tinsert(UnitPopupMenus.FRIEND, INSPECT_INDEX, 'INSPECT')

ns.securehook('UnitPopup_HideButtons', function()
    if UIDROPDOWNMENU_INIT_MENU.which == 'FRIEND' then
        UnitPopupShown[1][INSPECT_INDEX] = 1
    end
end)

local origInspectUnit = InspectUnit
function InspectUnit(unit)
    if unit and CheckInteractDistance(unit, 1) then
        origInspectUnit(unit)
    else
        if not InspectFrame then
            LoadAddOn('Blizzard_InspectUI')
        end

        local name
        if unit then
            name = UnitName(unit)
        else
            name = UIDROPDOWNMENU_INIT_MENU and UIDROPDOWNMENU_INIT_MENU.chatTarget
        end
        name = Ambiguate(name, 'none')

        INSPECTED_NAME = name
        INSPECTED_UNIT = unit or 'none'
        InspectFrame.unit = unit or 'none'
        ShowUIPanel(InspectFrame)
        InspectSwitchTabs(1)

        C_ChatInfo.SendAddonMessage(ALA_PREFIX, '_q_equ', 'WHISPER', name)

    end
end

local DB = {}

ns.event('CHAT_MSG_ADDON', function(prefix, msg, channel, sender)
    if prefix ~= ALA_PREFIX then
        return
    end

    local cmd = msg:sub(1, ALA_CMD_LEN)
    if cmd == '_r_equ' then
        local sep = msg:sub(ALA_CMD_LEN + 1, ALA_CMD_LEN + 1)
        local data = {strsplit(sep, msg:sub(ALA_CMD_LEN + 2))}

        print(sep)

        sender = Ambiguate(sender, 'none')

        DB[sender] = DB[sender] or {}

        for i = 1, #data, 2 do
            local slot, link = tonumber(data[i]), data[i + 1]
            print(slot, link)
            if link ~= NO_ITEM then
                DB[sender][slot] = link

                GetItemInfo(link)
            end
        end

        InspectPaperDollFrame_UpdateButtons()
    end
end)

ns.addon('Blizzard_InspectUI', function()
    local function GetItem(button)
        local name
        if InspectFrame.unit and InspectFrame.unit ~= 'none' then
            name = UnitName(InspectFrame.unit)
        else
            name = INSPECTED_NAME
        end

        name = Ambiguate(name, 'none')

        local data = name and DB[name]
        return data and data[button:GetID()]
    end

    ns.securehook('InspectPaperDollItemSlotButton_Update', function(button)
        local item = GetItem(button)
        if item then
            SetItemButtonTexture(button, GetItemIcon(item))

            local quality = select(3, GetItemInfo(item))
            if quality and quality > 1 then
                local r, g, b = GetItemQualityColor(quality)
                button.IconBorder:SetVertexColor(r, g, b, 0.5)
                button.IconBorder:Show()
            else
                button.IconBorder:Hide()
            end
            button.hasItem = 1
        else
        end
    end)

    ns.securehook('InspectPaperDollItemSlotButton_OnEnter', function(button)
        if GameTooltip:GetItem() then
            return
        end
        local item = GetItem(button)
        if not item then
            return
        end

        GameTooltip:SetHyperlink(item)
    end)

    local origInspectPaperDollFrame_SetLevel = InspectPaperDollFrame_SetLevel

    function InspectPaperDollFrame_SetLevel()
        if InspectFrame.unit ~= 'none' then
            origInspectPaperDollFrame_SetLevel()
        else
        end
    end
end)
