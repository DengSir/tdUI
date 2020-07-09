-- MicroButton.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/9/2020, 3:28:13 PM
--
---@type ns
local ns = select(2, ...)

---@type Button[]
local buttons = {
    CharacterMicroButton, SpellbookMicroButton, TalentMicroButton, QuestLogMicroButton, SocialsMicroButton,
    WorldMapMicroButton, MainMenuMicroButton, HelpMicroButton,
}

local function UpdateMicroWidth()
    return MicroButtonAndBagsBar:SetWidth(26 * #buttons + 12)
end

local StyleMicroButton
do
    local function region(t)
        if t then
            t:SetTexCoord(0, 1, 18 / 58, 1)
        end
    end

    local function point(t)
        if t then
            local p, r, rp, x, y = t:GetPoint()
            t:SetPoint(p, r, rp, x, y + 18)
        end
    end

    CharacterMicroButton.icon = MicroButtonPortrait

    -- point(MicroButtonPortrait)

    function StyleMicroButton(button)
        button:SetHitRectInsets(0, 0, 3, 0)
        button:SetHeight(58 - 18)

        region(button:GetNormalTexture())
        region(button:GetPushedTexture())
        region(button:GetDisabledTexture())
        region(button:GetHighlightTexture())
        point(button.Flash)
        point(button.icon)
    end

    for _, button in ipairs(buttons) do
        StyleMicroButton(button)
    end
end

local function OnMouseDown(button)
    button.icon:SetTexCoord(0.2666, 0.8666, 0, 0.8333)
    button.icon:SetAlpha(0.5)
end

local function OnMouseUp(button)
    button.icon:SetTexCoord(0.2, 0.8, 0.0666, 0.9)
    button.icon:SetAlpha(1.0)
end

local function SetButtonState(button, state)
    if state and state:upper() == 'PUSHED' then
        OnMouseDown(button)
    else
        OnMouseUp(button)
    end
end

local function OnEvent(self, event)
    if event == 'UPDATE_BINDINGS' then
        self.tooltipText = MicroButtonTooltipText(self.text, self.keybinding)
    end
end

function ns.CreateMicroButton(opts)
    assert(opts.icon or opts.template)
    assert(not (opts.icon and opts.template))

    local button = CreateFrame('Button', nil, MainMenuBarArtFrame, 'MainMenuBarMicroButton')

    if opts.template then
        LoadMicroButtonTextures(button, opts.template)
    end
    if opts.icon then
        button:SetNormalTexture([[Interface\Buttons\UI-MicroButtonCharacter-Up]])
        button:SetPushedTexture([[Interface\Buttons\UI-MicroButtonCharacter-Down]])
        button:SetDisabledTexture([[Interface\Buttons\UI-MicroButtonCharacter-Disabled]])
        button:SetHighlightTexture([[Interface\Buttons\UI-MicroButton-Hilight]])

        local icon = button:CreateTexture(nil, 'OVERLAY')
        icon:SetTexture(opts.icon)
        icon:SetSize(18, 25)
        icon:SetPoint('TOP', 0, -28)
        button.icon = icon

        button:SetScript('OnMouseDown', OnMouseDown)
        button:SetScript('OnMouseUp', OnMouseUp)
        ns.securehook(button, 'SetButtonState', SetButtonState)
        OnMouseUp(button)
    end

    StyleMicroButton(button)

    if opts.keybinding then
        button.text = opts.text
        button.keybinding = opts.keybinding
        button.tooltipText = MicroButtonTooltipText(opts.text, opts.keybinding)
        button:RegisterEvent('UPDATE_BINDINGS')
        button:SetScript('OnEvent', OnEvent)
    else
        button.text = opts.text
    end

    if opts.frame then
        opts.frame:HookScript('OnShow', function()
            button:SetButtonState('PUSHED', true)
        end)
        opts.frame:HookScript('OnHide', function()
            button:SetButtonState('NORMAL')
        end)
    end

    if opts.onClick then
        button:SetScript('OnClick', opts.onClick)
    end

    local index = tIndexOf(buttons, opts.after)
    local anchorTo = buttons[index]

    button:SetPoint('BOTTOMLEFT', anchorTo, 'BOTTOMRIGHT', -3, 0)
    if buttons[index + 1] then
        buttons[index + 1]:SetPoint('BOTTOMLEFT', button, 'BOTTOMRIGHT', -3, 0)
    end

    tinsert(buttons, index + 1, button)
    UpdateMicroWidth()
    return button
end

