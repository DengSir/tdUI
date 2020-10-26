-- ActionBar.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2019, 3:15:18 PM
--
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

ns.addon('M6', 'tullaRange', function()
    local function GetState(state)
        local usable = state % 2048 < 1024
        local nomana, norange = state % 16 > 7, state % 32 > 15

        if usable then
            if norange then
                return 'oor'
            else
                return 'normal'
            end
        elseif nomana then
            return 'oom'
        else
            return 'unusable'
        end
    end

    M6.PainterEvents.RawActionBookUpdates = function(_, button, _, _, state)
        if not state then
            return
        end

        button.rangeTimer = nil
        button.NormalTexture = nil

        tullaRange:SetButtonState(button, GetState(state))
    end
end)
