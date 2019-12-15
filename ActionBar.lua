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

local frames = ActionBarButtonEventsFrame.frames

local function InitActionButton(button)
    button.HotKey:SetFontObject('NumberFontNormal')

    if button:GetWidth() < 40 then
        button.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
    end
end

for _, button in ipairs(frames) do
    InitActionButton(button)
end

hooksecurefunc('ActionBarButtonEventsFrame_RegisterFrame', InitActionButton)

hooksecurefunc('ActionButton_ShowGrid', function()
    for _, button in pairs(frames) do
        if button.Name then
            button.Name:Show()
        end
    end
end)

hooksecurefunc('ActionButton_HideGrid', function()
    for _, button in pairs(frames) do
        if button.Name then
            button.Name:Hide()
        end
    end
end)

-- hooksecurefunc('ActionButton_UpdateCount', function(button)
--     local action = button.action
--     if not IsItemAction(action) and (IsConsumableAction(action) or IsStackableAction(action)) then
--         local count = GetActionCount(action)
--         print(count)
--         if count > (button.maxDisplayCount or 9999) then
--             button.Count:SetText('*')
--         else
--             button.Count:SetText(count)
--         end
--     end
-- end)
