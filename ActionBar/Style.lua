-- ActionBar.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2019, 3:15:18 PM
--
---@type ns
local ns = select(2, ...)

local ipairs, pairs = ipairs, pairs

local inited = {}

---@param button Button
local function OnSizeChanged(button)
    local buttonWidth, buttonHeight = button:GetSize()
    buttonWidth = buttonWidth / 36 * 40
    buttonHeight = buttonHeight / 36 * 40

    local function Layout(texture, anchor, origWidth, origHeight)
        if not texture then
            return
        end
        local x, y
        if anchor == 'TOPLEFT' then
            x = (origWidth - 45) / 2 / 45 * buttonWidth
            y = -(origHeight - 45) / 2 / 45 * buttonHeight
        else
            x = 0
            y = 0
        end
        local w = origWidth / 45 * buttonWidth
        local h = origHeight / 45 * buttonHeight
        texture:ClearAllPoints()
        texture:SetPoint('CENTER', button, 'CENTER', x, y)
        texture:SetSize(w, h)
    end

    Layout(button.SlotBackground, 'TOPLEFT', 45, 45)
    Layout(button.NormalTexture, 'TOPLEFT', 51, 51)
    Layout(button.PushedTexture, 'TOPLEFT', 51, 51)
    Layout(button.HighlightTexture, 'TOPLEFT', 46, 45)
    Layout(button.CheckedTexture, 'TOPLEFT', 46, 45)
    Layout(button.Border, 'TOPLEFT', 46, 45)
    Layout(button.SpellHighlightTexture, 'TOPLEFT', 46, 45)
    Layout(button.NewActionTexture, 'TOPLEFT', 46, 45)

    Layout(button.QuickKeybindHighlightTexture, 'CENTER', 52.9, 51.75)
    Layout(button.IconMask, 'CENTER', 64, 64)
    Layout(button.icon, 'CENTER', 45, 45)
end

local function InitActionButton(button)
    if inited[button] then
        return
    end
    inited[button] = true

    button.HotKey:SetFontObject('NumberFontNormalSmallGray')

    if button.SlotBackground then
        button.SlotBackground:SetAtlas('UI-HUD-ActionBar-IconFrame-Background')
        button.SlotBackground:SetAlpha(1)
    end

    if button.NormalTexture then
        -- button:SetNormalAtlas('UI-HUD-ActionBar-IconFrame-AddRow')
        button.NormalTexture:SetTexture(4615764)
        button.NormalTexture:SetTexCoord(0.701171875, 0.900390625, 0.21533203125, 0.26513671875)
        button.NormalTexture:SetDrawLayer('OVERLAY')
        button.NormalTexture:SetAlpha(1)
    end

    if button.PushedTexture then
        button:SetPushedAtlas('UI-HUD-ActionBar-IconFrame-AddRow-Down')
        button.PushedTexture:SetAlpha(1)
    end

    if button.HighlightTexture then
        button:SetHighlightAtlas('UI-HUD-ActionBar-IconFrame-Mouseover')
    end

    if button.CheckedTexture then
        button.CheckedTexture:SetAtlas('UI-HUD-ActionBar-IconFrame-Mouseover')
        button.CheckedTexture:SetAlpha(1)
    end

    if button.Border then
        button.Border:SetAtlas('UI-HUD-ActionBar-IconFrame-Border')
        button.Border:SetAlpha(1)
    end

    if button.SpellHighlightTexture then
        button.SpellHighlightTexture:SetAtlas('UI-HUD-ActionBar-IconFrame-Mouseover')
        button.SpellHighlightTexture:SetAlpha(0.4)
        button.SpellHighlightTexture:SetBlendMode('ADD')
    end

    if button.NewActionTexture then
        button.NewActionTexture:SetAtlas('UI-HUD-ActionBar-IconFrame-Mouseover')
        button.NewActionTexture:SetAlpha(1)
    end

    if button.QuickKeybindHighlightTexture then
        button.QuickKeybindHighlightTexture:SetAtlas('UI-HUD-ActionBar-IconFrame-Mouseover')
    end

    if button.IconMask then
        button.IconMask:SetAtlas('UI-HUD-ActionBar-IconFrame-Mask')
    end

    button:HookScript('OnSizeChanged', OnSizeChanged)
    OnSizeChanged(button)
end

local function InitButtons(buttons)
    for _, button in ipairs(buttons) do
        InitActionButton(button)
    end
end

local buttons = ActionBarButtonEventsFrame.frames

InitButtons(ActionBarButtonEventsFrame.frames)
InitButtons(StanceBar.actionButtons)
InitButtons(PetActionBar.actionButtons)

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
ns.event('ACTIONBAR_HIDEGRID', CheckConfig)

if ActionBarButtonEventsFrame_RegisterFrame then
    ns.securehook('ActionBarButtonEventsFrame_RegisterFrame', InitActionButton)
else
    ns.securehook(ActionBarButtonEventsFrame, 'RegisterFrame', InitActionButton)
end
ns.config('actionbar.button.macroName', CheckConfig)
ns.load(CheckConfig)
ns.login(CheckConfig)

if BagsBar then
    EventRegistry:UnregisterCallback('MainActionBarMixin.UpdateEndCaps', BagsBar)
end

local function ShouldUseMainMenuBarAsEndCaps(actionBar)
    return not actionBar:IsSystemSettingDefault(Enum.EditModeActionBarSetting.HideBarArt)
end

ns.securehook(MainActionBar, 'UpdateEndCaps', function(self, flag)
    self.EndCaps:SetShown(flag or ShouldUseMainMenuBarAsEndCaps(self))
end)
