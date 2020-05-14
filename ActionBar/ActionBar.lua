-- ActionBar.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2019, 3:15:18 PM

---@type ns
local ns = select(2, ...)

local ipairs, pairs = ipairs, pairs
local hooksecurefunc = hooksecurefunc

local GetActionCount = GetActionCount
local IsConsumableAction = IsConsumableAction
local IsItemAction = IsItemAction
local IsStackableAction = IsStackableAction

local LibClassicSpellActionCount = LibStub('LibClassicSpellActionCount-1.0')

local buttons = ActionBarButtonEventsFrame.frames

local function InitActionButton(button)
    button.HotKey:SetFontObject('NumberFontNormal')

    if button:GetWidth() < 40 then
        button.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
    end
end

for _, button in ipairs(buttons) do
    InitActionButton(button)
end

local function ShowGrid()
    for _, button in pairs(buttons) do
        if button.Name then
            button.Name:Show()
        end
    end
end

local function HideGrid()
    for _, button in pairs(buttons) do
        if button.Name then
            button.Name:Hide()
        end
    end
end

HideGrid()

ns.event('ACTIONBAR_SHOWGRID', ShowGrid)
ns.event('ACTIONBAR_HIDEGRID', HideGrid)
ns.securehook('ActionBarButtonEventsFrame_RegisterFrame', InitActionButton)
ns.securehook('ActionButton_UpdateCount', function(button)
    local action = button.action
    if not IsItemAction(action) and (IsConsumableAction(action) or IsStackableAction(action)) then
        local count = LibClassicSpellActionCount:GetActionCount(action)
        if count > (button.maxDisplayCount or 9999) then
            button.Count:SetText('*')
        else
            button.Count:SetText(count)
        end
    end
end)
