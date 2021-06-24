-- Flyable.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/24/2021, 11:24:54 PM
--
---@type ns
local ns = select(2, ...)

ns.hookscript(TaxiFrame, 'OnShow', function()
    Dismount()
end)
