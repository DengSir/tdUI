-- FullScaner.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/1/2020, 11:38:22 AM
--
---@type ns
local ns = select(2, ...)

local pairs = pairs
local tinsert, tremove = table.insert, table.remove

local GetNumAuctionItems = GetNumAuctionItems
local GetAuctionItemLink = GetAuctionItemLink
local GetAuctionItemInfo = GetAuctionItemInfo

---@class FullScaner: Scaner
local FullScaner = ns.class(ns.Auction.Scaner)
ns.Auction.FullScaner = FullScaner

function FullScaner:OnDone()
    self:SavePrices(self.prices)
end
