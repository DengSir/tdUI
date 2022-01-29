-- Fonts.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/27/2020, 4:41:48 PM
---@type ns
local ns = select(2, ...)

if GetLocale() == 'zhCN' then
    NumberFont_GameNormal:SetFont([[Fonts\ARHei.TTF]], 13, 'OUTLINE')

    NumberFont_Outline_Med:SetFont([[Fonts\ARKai_T.TTF]], 13, 'OUTLINE')
    NumberFont_Outline_Large:SetFont([[Fonts\ARKai_T.TTF]], 14, 'OUTLINE')
    NumberFont_OutlineThick_Mono_Small:SetFont([[Fonts\ARKai_T.TTF]], 12, 'OUTLINE')

    SystemFont_Shadow_Med1:SetFont([[Fonts\ARKai_T.TTF]], 15)
    SystemFont_Shadow_Small:SetFont([[Fonts\ARKai_T.TTF]], 13)
    SystemFont_Shadow_Large:SetFont([[Fonts\ARKai_T.TTF]], 17)

    TextStatusBarText:SetFont([[Fonts\ARHei.TTF]], 11, 'OUTLINE')

    CombatTextFont:SetFont([[Fonts\ARKai_C.TTF]], 24)
    CombatTextFontOutline:SetFont([[Fonts\ARKai_C.TTF]], 24)
end

local function OnTooltipSetItem(tip)
    tip:GetFontStringLeft(2):SetFontObject(tip:GetFontStringLeft(1):GetText() == CURRENTLY_EQUIPPED and
                                               'GameTooltipHeaderText' or 'GameTooltipText')
end

local function SetupTooltip(tip)
    tip:GetFontStringLeft(1):SetFontObject('GameTooltipHeaderText')
    tip:GetFontStringRight(1):SetFontObject('GameTooltipHeaderText')

    if tip.shoppingTooltips then
        for i, shopping in pairs(tip.shoppingTooltips) do
            SetupTooltip(shopping)

            shopping:HookScript('OnTooltipSetItem', OnTooltipSetItem)

            shopping:GetFontStringLeft(2):SetFontObject('GameTooltipHeaderText')
            shopping:GetFontStringRight(2):SetFontObject('GameTooltipHeaderText')

            local i = 3
            while shopping:GetFontStringLeft(i) do
                shopping:GetFontStringLeft(i):SetFontObject('GameTooltipText')
                shopping:GetFontStringRight(i):SetFontObject('GameTooltipText')

                i = i + 1
            end
        end
    end
end

-- for _, tip in ipairs({GameTooltip, ItemRefTooltip, WorldMapTooltip}) do
--     SetupTooltip(tip)
-- end
