-- Fonts.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/27/2020, 4:41:48 PM
---@type ns
local ns = select(2, ...)

if GetLocale() == 'zhCN' then

    local function Font(obj, font, size, flag)
        if not obj then
            return
        end

        local _font, _size, _flag = obj:GetFont()
        font = font or _font
        size = size or _size
        flag = flag or _flag

        obj:SetFont(font, size, flag)
    end

    Font(PriceFont, [[Fonts\ARKai_T.TTF]], 13)
    Font(Number13Font, [[Fonts\ARHei.TTF]], 14)
    Font(Number12Font, [[Fonts\ARHei.TTF]], 13)

    Font(NumberFont_Normal_Med, [[Fonts\ARHei.TTF]], 13)
    Font(NumberFont_GameNormal, [[Fonts\ARHei.TTF]], 13)

    Font(NumberFont_Outline_Med, [[Fonts\ARKai_T.TTF]], 13, 'OUTLINE')
    Font(NumberFont_Outline_Large, [[Fonts\ARKai_T.TTF]], 14, 'OUTLINE')
    Font(NumberFont_OutlineThick_Mono_Small, [[Fonts\ARKai_T.TTF]], 12, 'OUTLINE')

    Font(SystemFont_Shadow_Med1, [[Fonts\ARKai_T.TTF]], 15)
    Font(SystemFont_Shadow_Small, [[Fonts\ARKai_T.TTF]], 13)
    Font(SystemFont_Shadow_Large, [[Fonts\ARKai_T.TTF]], 17)

    Font(TextStatusBarText, [[Fonts\ARHei.TTF]], 11, 'OUTLINE')

    Font(CombatTextFont, [[Fonts\ARKai_C.TTF]], 24)
    Font(CombatTextFontOutline, [[Fonts\ARKai_C.TTF]], 24)
end
