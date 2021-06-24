-- ItemRackBar.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/20/2021, 2:33:18 PM
--
---@type ns
local ns = select(2, ...)

local ItemRackBar = {}

local SIZE = 20
local ICON_SIZE = SIZE / 24 * 22
local BORDER_SIZE = SIZE / 24 * 33
local SPACING = SIZE * 0.1

local SLOT_BUTTONS = {[16] = 'CharacterMainHandSlot', [17] = 'CharacterSecondaryHandSlot', [18] = 'CharacterRangedSlot'}

function ItemRackBar:OnLoad()
    self.buttons = {}

    ns.hide(PlayerFrameGroupIndicator)

    local Bar = CreateFrame('Frame', nil, UIParent)
    Bar:SetHeight(SIZE)
    Bar:SetPoint('BOTTOMLEFT', PlayerFrame, 'TOPLEFT', 95, -18)
    Bar:EnableMouse(true)

    self.Bar = Bar

    _PutToBag = (function()
        local fixedFree = {}
        local timer

        local function OnTimer()
            timer = nil
            wipe(fixedFree)
        end

        local function GetFree(bag)
            return GetContainerNumFreeSlots(bag) - (fixedFree[bag] or 0)
        end

        local function PutIn(bag)
            fixedFree[bag] = (fixedFree[bag] or 0) + 1

            if bag == 0 then
                PutItemInBackpack()
            else
                PutItemInBag(ContainerIDToInventoryID(bag))
            end
        end

        return function()
            for bag = 0, 4 do
                if GetFree(bag) > 0 then
                    PutIn(bag)
                    break
                end
            end

            if not timer then
                timer = ns.oncetimer(0, OnTimer)
            end
        end
    end)()

    ns.securehook(ItemRack, 'UpdateCurrentSet', function()
        return self:UpdateCurrent()
    end)

    ns.event('BAG_UPDATE_DELAYED', function()
        return self:UpdateMissing()
    end)

    local UpdateAll = ns.nocombated(function()
        self:UpdateButtons()
        self:UpdateCurrent()
        self:UpdateMissing()
    end)

    ItemRack:RegisterExternalEventListener('ITEMRACK_SET_SAVED', UpdateAll)
    ItemRack:RegisterExternalEventListener('ITEMRACK_SET_DELETED', UpdateAll)

    UpdateAll()
end

function ItemRackBar:AllSets()
    local sets = {}

    for name, v in pairs(ItemRackUser.Sets) do
        if name:find('^%d+') and not ItemRack.IsHidden(name) then
            tinsert(sets, name)
        end
    end
    sort(sets)

    return sets
end

function ItemRackBar:UpdateButtons()
    local sets = self:AllSets()

    for i, name in ipairs(sets) do
        local button = self.buttons[i] or self:CreateButton(i)
        local set = ItemRackUser.Sets[name]

        button.name = name
        button.icon:SetTexture(set.icon)
        button:Show()

        button.macro:SetAttribute('macrotext', self:GenMacro(set))
    end

    for i = #sets + 1, #self.buttons do
        self.buttons[i]:Hide()
    end

    self.Bar:SetWidth((SIZE + SPACING) * #sets)
end

function ItemRackBar:UpdateMissing()
    for i, button in ipairs(self.buttons) do
        if button:IsVisible() and button.name then
            if not ItemRack.MissingItems(button.name) then
                button.nt:SetVertexColor(1, 1, 1)
            else
                button.nt:SetVertexColor(1, 0.5, 0.5)
            end
        end
    end
end

function ItemRackBar:UpdateCurrent()
    for _, button in ipairs(self.buttons) do
        if button:IsVisible() and button.name then
            button.ct:SetShown(ItemRackUser.CurrentSet == button.name)
        end
    end
end

function ItemRackBar:GenMacro(set)
    local sb = {}

    for slot = 16, 18 do
        local id = set.equip[slot]
        if id then
            if id == 0 then
                tinsert(sb, format('/click %s\n/run _PutToBag()', SLOT_BUTTONS[slot]))
            else
                local name = GetItemInfo('item:' .. id)
                if name then
                    tinsert(sb, format('/equipslot %d %s', slot, name))
                end
            end
        end
    end

    local macro = table.concat(sb, '\n')
    return macro
end

local function ButtonOnEnter(button)
    ItemRack.SetTooltip(button, button.name)
end

local function ButtonPreClick(button, clicked)
    if clicked == 'RightButton' then
        if not ItemRackOptFrame then
            EnableAddOn('ItemRackOptions')
            LoadAddOn('ItemRackOptions')
        end

        local toSet = not ItemRackOptFrame:IsVisible() or not ItemRackOptSubFrame2:IsVisible() or
                          ItemRackOptSetsName:GetText() ~= button.name
        if toSet then
            if not ItemRackOptFrame:IsVisible() then
                ItemRackOptFrame:Show()
            end
            ItemRackOpt.TabOnClick(nil, 2)

            local oldSet = ItemRackUser.CurrentSet

            ItemRackUser.CurrentSet = button.name
            ItemRackOpt.ChangeEditingSet()
            ItemRackUser.CurrentSet = oldSet
        elseif ItemRackUser.CurrentSet == button.name then
            ItemRackOpt.TabOnClick(nil, 4)
        end
    else
        ItemRack.RunSetBinding(button.name)
    end
end

function ItemRackBar:CreateButton(i)
    local button = CreateFrame('Button', nil, self.Bar, 'SecureActionButtonTemplate')
    button:SetSize(SIZE, SIZE)

    button.icon = button:CreateTexture(nil, 'BACKGROUND')
    button.icon:SetPoint('CENTER')
    button.icon:SetSize(ICON_SIZE, ICON_SIZE)
    button.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)

    local mask = button:CreateMaskTexture()
    mask:SetAllPoints(button.icon)
    mask:SetTexture([[Interface\CharacterFrame\TempPortraitAlphaMask]])
    button.icon:AddMaskTexture(mask)

    button.nt = button:CreateTexture(nil, 'OVERLAY', nil, -1)
    button.nt:SetAtlas('worldquest-tracker-ring')
    button.nt:SetSize(BORDER_SIZE, BORDER_SIZE)
    button.nt:SetPoint('CENTER')
    button:SetNormalTexture(button.nt)

    button.ct = button:CreateTexture(nil, 'OVERLAY')
    button.ct:SetAtlas('worldquest-tracker-ring-selected')
    button.ct:SetSize(BORDER_SIZE, BORDER_SIZE)
    button.ct:SetPoint('CENTER')
    button.ct:Hide()

    button.ht = button:CreateTexture(nil, 'HIGHLIGHT')
    button.ht:SetAtlas('worldquest-tracker-ring-selected')
    button.ht:SetSize(BORDER_SIZE, BORDER_SIZE)
    button.ht:SetPoint('CENTER')
    button.ht:SetAlpha(0.6)

    button:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    button:SetScript('OnEnter', ButtonOnEnter)
    button:SetScript('OnLeave', GameTooltip_Hide)
    button:SetScript('PreClick', ButtonPreClick)

    local macroButtonName = 'tdItemRackBarButton' .. i

    button:SetAttribute('type', 'macro')
    button:SetAttribute('macrotext', '/click [combat]' .. macroButtonName)

    local macro = CreateFrame('Button', macroButtonName, UIParent, 'SecureActionButtonTemplate')
    macro:SetAttribute('type', 'macro')

    button.macro = macro

    if i == 1 then
        button:SetPoint('BOTTOMLEFT', 0, 0)
    else
        button:SetPoint('LEFT', self.buttons[i - 1], 'RIGHT', SPACING, 0)
    end

    self.buttons[i] = button
    return button
end

ns.addonlogin('ItemRack', ns.nocombated(function()
    ItemRackBar:OnLoad()
end))

