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

    SystemFont_Shadow_Med1:SetFont([[Fonts\ARKai_T.TTF]], 15, (select(3, SystemFont_Shadow_Med1:GetFont())))
    SystemFont_Shadow_Small:SetFont([[Fonts\ARKai_T.TTF]], 13, (select(3, SystemFont_Shadow_Small:GetFont())))
    SystemFont_Shadow_Large:SetFont([[Fonts\ARKai_T.TTF]], 17, (select(3, SystemFont_Shadow_Large:GetFont())))

    TextStatusBarText:SetFont([[Fonts\ARHei.TTF]], 11, 'OUTLINE')

    CombatTextFont:SetFont([[Fonts\ARKai_C.TTF]], 24, (select(3, CombatTextFont:GetFont())))
    CombatTextFontOutline:SetFont([[Fonts\ARKai_C.TTF]], 24, (select(3, CombatTextFontOutline:GetFont())))
end
