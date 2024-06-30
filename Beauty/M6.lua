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
            -- M6UI:ReturnToList(true)
        end
    end

    ns.hook(SlashCmdList, 'M6', function(orig, arg)
        if arg and arg:trim() ~= '' then
            return orig(arg)
        end
        Toggle()
    end)

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

    pcall(function()
        local core = OneRingLib.ext.ActionBook:compatible('Rewire', 1, 20):seclib()

        setfenv(core.setMute, setmetatable({
            GetCVar = function()
                return GetCVar('Sound_EnableErrorSpeech')
            end,
            SetCVar = function(_, flag)
                return SetCVar('Sound_EnableErrorSpeech', flag)
            end,
        }, {__index = _G}))
    end)

    ns.logout(function()
        ns.cleantable(M6DB.profiles)
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

        local function SetButtonState(button, state)
            if tullaRange.SetButtonState then
                tullaRange:SetButtonState(button, state)
            elseif tullaRange.GetColor then
                local r, g, b, a, d = tullaRange:GetColor(state)
                button.icon:SetVertexColor(r, g, b, a)
                button.icon:SetDesaturated(d)

                r, g, b = tullaRange:GetColor(state == 'oor' and state or 'normal')
                button.HotKey:SetVertexColor(r, g, b)
            end
        end

        local hooked = {}

        ---@param button Button
        local function Hook(button)
            if hooked[button] then
                return
            end

            if button.GetCheckedTexture then
                ---@type Texture
                local checkedTexture = button:GetCheckedTexture()
                ---@type Texture
                local texture = button._CheckedTexture or button:CreateTexture(nil, (checkedTexture:GetDrawLayer()))

                texture:Hide()
                texture:SetAllPoints(checkedTexture)
                texture:SetTexture(checkedTexture:GetTexture())
                texture:SetTexCoord(checkedTexture:GetTexCoord())
                texture:SetBlendMode(checkedTexture:GetBlendMode())

                checkedTexture:SetAlpha(0)

                button._CheckedTexture = texture
            end

            button._NormalTexture = button.NormalTexture or button._NormalTexture
            button.NormalTexture = nil
            button.rangeTimer = nil

            hooked[button] = true
        end

        local function Unhook(button)
            if button._CheckedTexture then
                button._CheckedTexture:Hide()
            end
            if button.GetCheckedTexture then
                local ct = button:GetCheckedTexture()
                if ct then
                    ct:SetAlpha(1)
                end
            end

            hooked[button] = nil
        end

        ns.securehook('ActionButton_ShowGrid', function(button)
            if button._NormalTexture then
                button._NormalTexture:SetVertexColor(1.0, 1.0, 1.0, 0.5)
            end
        end)

        M6:RegisterButtonUpdateListener(function(event, ...)
            if event == 'M6_BUTTON_UPDATE' then
                local button, _, _, state, _, _, count, _, _, tf, id = ...

                if not button.icon then
                    return
                end

                Hook(button)

                local spellId, itemId

                if tf == GameTooltip.SetItemByID then
                    itemId = id
                elseif tf == GameTooltip.SetSpellByID then
                    spellId = id
                else

                end

                if state then
                    SetButtonState(button, GetState(state))

                    if button._CheckedTexture and spellId then
                        button._CheckedTexture:SetShown(IsCurrentSpell(spellId) or IsAutoRepeatSpell(spellId))
                    end

                    if button.cooldown then
                        button.cooldown:SetDrawEdge(false)
                    end
                end

            elseif event == 'M6_BUTTON_RELEASE' then
                local button = ...
                Unhook(button)
            end
        end)

        -- ActionBarButtonEventsFrame:UnregisterEvent('ACTIONBAR_UPDATE_COOLDOWN')

        -- ns.event('ACTIONBAR_UPDATE_COOLDOWN', function()
        --     for i, button in ipairs(ActionBarButtonEventsFrame.frames) do
        --         if not hooked[button] then
        --             ActionButton_UpdateCooldown(button)
        --             if GameTooltip:GetOwner() == button then
        --                 ActionButton_SetTooltip(button)
        --             end
        --         end
        --     end
        -- end)
    end)
end)
