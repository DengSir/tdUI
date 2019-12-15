-- Battlefield.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/14/2019, 9:29:15 PM

---@type EditBox
local Input = CreateFrame('EditBox', nil, BattlefieldFrame, 'NumericInputSpinnerTemplate')
local Button = CreateFrame('Button', nil, BattlefieldFrame, 'UIPanelButtonTemplate')

Input:SetSize(50, 20)
Input:SetPoint('TOPRIGHT', -95, -50)
Input.IncrementButton:Hide()
Input.DecrementButton:Hide()
Input:HookScript('OnEnterPressed', function()
    Button:Click()
end)

local function JumpTo(index)
    local buttonHeight = BATTLEFIELD_ZONES_HEIGHT
    local maxCount = BATTLEFIELD_ZONES_DISPLAYED
    local height = buttonHeight * (index - 1)
    FauxScrollFrame_SetOffset(BattlefieldListScrollFrame, height)
    BattlefieldListScrollFrame.ScrollBar:SetValue(height)
end

Button:SetSize(50, 22)
Button:SetPoint('LEFT', Input, 'RIGHT', 3, 0)
Button:SetText('Goto')
Button:SetFrameLevel(Input:GetFrameLevel() + 100)
Button:SetScript('OnClick', function()
    local id = Input:GetNumber()
    if not id then
        return
    end

    Input:ClearFocus()

    for i = 1, GetNumBattlefields() do
        local instanceId = GetBattlefieldInstanceInfo(i)
        if instanceId == id then
            SetSelectedBattlefield(i)
            JumpTo(i)
            return
        end
    end
end)
