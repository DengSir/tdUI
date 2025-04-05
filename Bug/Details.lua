-- Details.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 4/1/2025, 11:08:04 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Details', function(self)
    local DF = DetailsFramework

    function DF.Language.GetFontForLanguageID()
        return [[Fonts\ARKai_T.ttf]]
    end
end)
