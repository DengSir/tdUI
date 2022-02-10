-- Taint.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/27/2021, 1:00:47 PM
--
---@type ns
local ns = select(2, ...)

ns.login(function()
    if GuildControlPopupFrame then
        ShowUIPanel(GuildControlPopupFrame)
        HideUIPanel(GuildControlPopupFrame)
    end
end)
