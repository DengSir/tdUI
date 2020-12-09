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
end)
