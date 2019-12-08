-- ActionBar.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2019, 3:15:18 PM

local ipairs, pairs = ipairs, pairs
local hooksecurefunc = hooksecurefunc

local GetActionCount = GetActionCount
local IsConsumableAction = IsConsumableAction
local IsItemAction = IsItemAction
local IsStackableAction = IsStackableAction

local buttonNames = {}

local function InitActionButton(button)
    button.HotKey:SetFontObject('NumberFontNormal')

    if button:GetWidth() < 40 then
        button.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
    end

    if button.Name then
        button.Name:Hide()
        buttonNames[button.Name] = true
    end
end

for _, button in ipairs(ActionBarButtonEventsFrame.frames) do
    InitActionButton(button)
end

hooksecurefunc('ActionBarButtonEventsFrame_RegisterFrame', InitActionButton)

hooksecurefunc('ActionButton_ShowGrid', function()
    for name in pairs(buttonNames) do
        name:Show()
    end
end)

hooksecurefunc('ActionButton_HideGrid', function()
    for name in pairs(buttonNames) do
        name:Hide()
    end
end)

hooksecurefunc('ActionButton_UpdateCount', function(button)
    local action = button.action
    if not IsItemAction(action) and (IsConsumableAction(action) or IsStackableAction(action)) then
        local count = GetActionCount(action)
        if count > (button.maxDisplayCount or 9999) then
            button.Count:SetText('*')
        else
            button.Count:SetText(count)
        end
    end
end)
