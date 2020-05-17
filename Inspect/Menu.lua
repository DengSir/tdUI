-- Menu.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/17/2020, 11:41:32 PM

---@type ns
local ns = select(2, ...)

UnitPopupButtons.INSPECT.dist = nil

local function GetDropdownUnitName()
    local menu = UIDROPDOWNMENU_INIT_MENU
    return menu and menu == FriendsDropDown and menu.chatTarget
end

---@type Button
local InspectButton = CreateFrame('Button', nil, DropDownList1)
do
    local ht = InspectButton:CreateTexture(nil, 'BACKGROUND')
    ht:SetAllPoints(true)
    ht:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
    ht:SetBlendMode('ADD')

    InspectButton:SetHeight(UIDROPDOWNMENU_BUTTON_HEIGHT)
    InspectButton:SetHighlightTexture(ht)
    InspectButton:SetNormalFontObject('GameFontHighlightSmallLeft')
    InspectButton:SetText(INSPECT)

    InspectButton:SetScript('OnHide', InspectButton.Hide)
    InspectButton:SetScript('OnClick', function()
        local name = GetDropdownUnitName()
        if name then
            ns.Inspect:Query(name)
        end
        CloseDropDownMenus()
    end)
    InspectButton:SetScript('OnEnter', function(self)
        local parent = self:GetParent()
        if parent then
            parent.isCounting = nil
        end
    end)
end

local function FindDropdownItem(dropdown, text)
    local name = dropdown:GetName()
    for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
        local button = _G[name .. 'Button' .. i]
        if button:IsShown() and button:GetText() == text then
            return i, button
        end
    end
end

local function FillToDropdownAfter(button, text, level)
    local dropdownName = 'DropDownList' .. level
    local dropdown = _G[dropdownName]
    local index, button = FindDropdownItem(dropdown, WHISPER)
    if index then
        local x, y = select(4, button:GetPoint())

        InspectButton:SetParent(dropdown)
        InspectButton:Show()
        InspectButton:ClearAllPoints()
        InspectButton:SetPoint('TOPLEFT', x, y - UIDROPDOWNMENU_BUTTON_HEIGHT)
        InspectButton:SetPoint('RIGHT', -x, 0)

        for i = index + 1, UIDROPDOWNMENU_MAXBUTTONS do
            local button = _G[dropdownName .. 'Button' .. i]
            local p, r, rp, x, y = button:GetPoint(1)

            button:SetPoint(p, r, rp, x, y - UIDROPDOWNMENU_BUTTON_HEIGHT)
        end

        dropdown:SetHeight(dropdown:GetHeight() + UIDROPDOWNMENU_BUTTON_HEIGHT)
    end
end

ns.securehook('UnitPopup_ShowMenu', function(dropdownMenu, which, _, name)
    if which == 'FRIEND' and UIDROPDOWNMENU_MENU_LEVEL == 1 and not UnitIsUnit('player', Ambiguate(name, 'none')) then
        FillToDropdownAfter(InspectButton, WHISPER, 1)
    end
end)

ns.hook('InspectUnit', function(orig, unit)
    if not unit then
        return
    end

    if CheckInteractDistance(unit, 1) then
        orig(unit)
    else
        ns.Inspect:Query(ns.UnitName(unit), unit)
    end
end)
