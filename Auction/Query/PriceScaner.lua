-- PriceScaner.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/1/2020, 11:46:00 AM
--
---@type ns
local ns = select(2, ...)

local FullScaner = ns.Auction.FullScaner
local PriceScaner = ns.class(FullScaner)
ns.Auction.PriceScaner = PriceScaner

function PriceScaner:SetItem(link)
    self.link = link
    self.itemKey = ns.parseItemKey(link)
end

function PriceScaner:GetResponseItems()
    return self.items
end

function PriceScaner:Next()
    return not self.prices[self.itemKey]
end

function PriceScaner:OnStart()
    FullScaner.OnStart(self)
    self.items = {}
    self.itemCache = {}
end

function PriceScaner:PreQuery()
    SortAuctionClearSort('list')
    SortAuctionSetSort('list', 'unitprice', false)
end

local function compare(a, b)
    return a.price < b.price
end

function PriceScaner:OnDone()
    FullScaner.OnDone(self)

    for price, count in pairs(self.itemCache) do
        tinsert(self.items, {price = price, count = count})
    end

    sort(self.items, compare)
end

function PriceScaner:ProcessAuction(index)
    local itemKey, count, unitPrice = FullScaner.ProcessAuction(self, index)
    if itemKey == self.itemKey then
        self.itemCache[unitPrice] = (self.itemCache[unitPrice] or 0) + count
    end
end
