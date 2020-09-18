-- ActionBar.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2019, 3:15:18 PM

---@type ns
local ns = select(2, ...)

local ipairs, pairs = ipairs, pairs

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

local function CheckConfig()
    if ns.profile.actionbar.button.macroName then
        ShowGrid()
    else
        HideGrid()
    end
end

ns.event('ACTIONBAR_SHOWGRID', ShowGrid)
ns.event('ACTIONBAR_HIDEGRID', HideGrid)
ns.securehook('ActionBarButtonEventsFrame_RegisterFrame', InitActionButton)
ns.config('actionbar.button.macroName', CheckConfig)
ns.load(CheckConfig)
