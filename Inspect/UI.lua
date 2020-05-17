-- UI.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/17/2020, 11:45:32 PM

---@type ns
local ns = select(2, ...)

local Inspect = ns.Inspect
Inspect.tabs = {}

local index = 0

local function OnClick(tab)
    return Inspect:SetTab(tab:GetID())
end

function Inspect:CreateTab(text, icon)
    index = index + 1

    local tab = CreateFrame('CheckButton', nil, InspectPaperDollFrame, 'SpellBookSkillLineTabTemplate')
    tab:Show()
    tab:SetID(index)
    tab:SetNormalTexture(icon)
    tab:SetScript('OnClick', OnClick)
    if index == 1 then
        tab:SetPoint('TOPLEFT', InspectPaperDollFrame, 'TOPRIGHT', -32, -65)
    else
        tab:SetPoint('TOPLEFT', self.tabs[index - 1], 'BOTTOMLEFT', 0, -17)
    end

    local frame = CreateFrame('Frame', nil, InspectPaperDollFrame)
    frame:SetPoint('TOPLEFT', 65, -76)
    frame:SetPoint('BOTTOMRIGHT', -85, 115)

    print(tab, frame)

    tab.tooltip = text
    tab.frame = frame
    self.tabs[index] = tab

    if index == 1 then
        self:SetTab(1)
    end

    return frame
end

function Inspect:SetTab(id)
    for i, tab in ipairs(self.tabs) do
        tab.frame:SetShown(id == i)
        tab:SetChecked(id == i)
    end
end
