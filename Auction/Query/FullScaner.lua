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

function FullScaner:OnStart()
    self.pendings = {}
    self.prices = {}
end

function FullScaner:OnResponse()
    local count, total = GetNumAuctionItems('list')

    self.index = count
    self.maxPage = ceil(total / count)
end

function FullScaner:OnContinue()
    while true do
        local index = tremove(self.pendings)
        if not index then
            break
        end

        self:ProcessAuction(index)

        if self:Threshold() then
            return
        end
    end

    while true do
        if self.index == 0 then
            break
        end

        self:ProcessAuction(self.index)
        self.index = self.index - 1

        if self:Threshold() then
            return
        end
    end
    return #self.pendings == 0
end

function FullScaner:OnDone()
    local count = 0
    for itemKey, price in pairs(self.prices) do
        ns.global.auction.prices[itemKey] = price

        count = count + 1
    end
end

function FullScaner:ProcessAuction(index)
    local link = GetAuctionItemLink('list', index)
    local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount,
          highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo =
        GetAuctionItemInfo('list', index)

    if not link then
        if itemId then
            tinsert(self.pendings, index)
        end
        return
    end

    if buyoutPrice and buyoutPrice > 0 then
        local unitPrice = buyoutPrice / count
        local itemKey = ns.parseItemKey(link)

        if not self.prices[itemKey] then
            self.prices[itemKey] = unitPrice
        else
            self.prices[itemKey] = min(self.prices[itemKey], unitPrice)
        end
    end
end
