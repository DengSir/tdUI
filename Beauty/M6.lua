-- M6.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/27/2020, 10:57:26 AM
--
---@type ns
local ns = select(2, ...)

ns.addon('M6', function()
    local M6UI = M6UI

    M6UI.portrait:SetTexture([[Interface\MacroFrame\MacroFrame-Icon]])
    M6UI:SetScript('OnKeyDown', nil)
    M6UI:SetAttribute('UIPanelLayout-enabled', true)
    M6UI:SetAttribute('UIPanelLayout-defined', true)
    M6UI:SetAttribute('UIPanelLayout-whileDead', true)
    M6UI:SetAttribute('UIPanelLayout-area', 'left')
    M6UI:SetAttribute('UIPanelLayout-pushable', 1)
    M6UI:SetToplevel(true)

    local function Toggle()
        if M6UI:IsShown() then
            HideUIPanel(M6UI)
        else
            ShowUIPanel(M6UI)
            M6UI:ReturnToList(true)
        end
    end

    local orig_SlashCmdList_M6 = SlashCmdList.M6
    SlashCmdList.M6 = function(arg)
        if arg == 'vers' then
            return orig_SlashCmdList_M6(arg)
        end
        Toggle()
    end

    ns.addon('Blizzard_MacroUI', function()
        ---@type Button
        local button = CreateFrame('Button', nil, MacroFrame)
        local text = button:CreateFontString(nil, 'OVERLAY')
        text:SetPoint('RIGHT', button, 'LEFT', 0, 0)

        button:SetSize(26, 26)
        button:SetPoint('TOPRIGHT', -5, -28)
        button:SetFontString(text)
        button:SetNormalTexture([[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]])
        button:SetPushedTexture([[Interface\Buttons\UI-SpellbookIcon-NextPage-Down]])
        button:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], 'ADD')
        button:SetNormalFontObject('GameFontNormalSmall')
        button:SetHighlightFontObject('GameFontHighlightSmall')
        button:SetText('M6')
        button:SetScript('OnClick', Toggle)
    end)

    ns.addon('tullaRange', function()
        local tullaRange = tullaRange

        local IsCurrentSpell = IsCurrentSpell
        local IsAutoRepeatSpell = IsAutoRepeatSpell

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

        local hooked = {}

        ---@param button Button
        local function Hook(button)
            if hooked[button] then
                return
            end

            button.rangeTimer = nil
            button.NormalTexture = nil

            ---@type Texture
            local checkedTextture = button:GetCheckedTexture()
            ---@type Texture
            local texture = button._tdCheckedTexture or button:CreateTexture(nil, checkedTextture:GetDrawLayer())

            texture:Hide()
            texture:SetAllPoints(checkedTextture)
            texture:SetTexture(checkedTextture:GetTexture())
            texture:SetTexCoord(checkedTextture:GetTexCoord())
            texture:SetBlendMode(checkedTextture:GetBlendMode())

            checkedTextture:SetAlpha(0)

            button._tdCheckedTexture = texture
            hooked[button] = true
        end

        local function Unhook(button)
            button._tdCheckedTexture:Hide()
            button:GetCheckedTexture():SetAlpha(1)

            hooked[button] = nil
        end

        M6.PainterEvents.RawActionBookUpdates = function(event, button, _, _, state, _, _, _, _, _, _, spellId)
            if event == 'M6_BUTTON_UPDATE' then
                Hook(button)

                if state then
                    tullaRange:SetButtonState(button, GetState(state))
                    button._tdCheckedTexture:SetShown(IsCurrentSpell(spellId) or IsAutoRepeatSpell(spellId))
                    if button.cooldown then
                        button.cooldown:SetDrawEdge(false)
                    end
                end

            elseif event == 'M6_BUTTON_RELEASE' then
                Unhook(button)
            end
        end
    end)
end)
