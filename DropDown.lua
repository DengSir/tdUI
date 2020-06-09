-- DropDown.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/9/2020, 4:08:30 PM

---@type ns
local ns = select(2, ...)

local _G = _G
local BUTTON_HEIGHT = UIDROPDOWNMENU_BUTTON_HEIGHT

local dropdownButtons = {}

local function OnHide(self)
    self.func = nil
    self.args = nil
    self.argCount = nil
    self:Hide()
    dropdownButtons[self] = true
end

local function OnClick(self)
    self.func(unpack(self.args, 1, self.argCount))
    CloseDropDownMenus()
end

local function Alloc()
    local button = next(dropdownButtons)
    if not button then
        button = CreateFrame('Button', nil, UIParent)

        local ht = button:CreateTexture(nil, 'BACKGROUND')
        ht:SetAllPoints(true)
        ht:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
        ht:SetBlendMode('ADD')

        button:Hide()
        button:SetHeight(BUTTON_HEIGHT)
        button:SetHighlightTexture(ht)
        button:SetNormalFontObject('GameFontHighlightSmallLeft')

        button:SetScript('OnHide', OnHide)
        button:SetScript('OnClick', OnClick)
    end
    return button
end

local function FindDropdownItem(dropdown, text)
    local name = dropdown:GetName()
    for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
        local dropdownItem = _G[name .. 'Button' .. i]
        if dropdownItem:IsShown() and dropdownItem:GetText() == text then
            return i, dropdownItem
        end
    end
end

function ns.InsertDropdownAfter(level, target, text, func, ...)
    local dropdownName = 'DropDownList' .. level
    local dropdown = _G[dropdownName]
    local index, dropdownItem = FindDropdownItem(dropdown, target)
    if index then
        local button = Alloc()
        local x, y = select(4, dropdownItem:GetPoint())

        button:SetParent(dropdown)
        button:ClearAllPoints()
        button:SetPoint('TOPLEFT', x, y - BUTTON_HEIGHT)
        button:SetPoint('RIGHT', -x, 0)
        button:Show()
        button:SetText(text)
        button.func = func
        button.args = {...}
        button.argCount = select('#', ...)

        for i = index + 1, UIDROPDOWNMENU_MAXBUTTONS do
            local dropdownItem = _G[dropdownName .. 'Button' .. i]
            if dropdownItem:IsShown() then
                local p, r, rp, x, y = dropdownItem:GetPoint(1)
                dropdownItem:SetPoint(p, r, rp, x, y - BUTTON_HEIGHT)
            else
                break
            end
        end

        dropdown:SetHeight(dropdown:GetHeight() + BUTTON_HEIGHT)
    end
end
