-- BrowseScaner.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/1/2020, 12:48:16 PM
--
---@type ns
local ns = select(2, ...)

local BrowseScaner = ns.class(ns.Auction.Scaner)
ns.Auction.BrowseScaner = BrowseScaner

function BrowseScaner:OnContinue()
    return true
end
