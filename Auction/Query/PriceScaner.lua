-- PriceScaner.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/1/2020, 11:46:00 AM
--
---@type ns
local ns = select(2, ...)

local Scaner = ns.Auction.Scaner

---@class PriceScaner: Scaner
local PriceScaner = ns.class(Scaner)
ns.Auction.PriceScaner = PriceScaner

function PriceScaner:SetItem(link)
    self.link = link
    self.itemKey = ns.parseItemKey(link)
end

function PriceScaner:GetResponseItems()
    return self.items
end

function PriceScaner:Next()
    return not self.db[self.itemKey]
end

function PriceScaner:OnStart()
    Scaner.OnStart(self)
    self.items = {}
    self.cache = {}
end

function PriceScaner:PreQuery()
    SortAuctionClearSort('list')
    SortAuctionSetSort('list', 'unitprice', false)
end

local function compare(a, b)
    return a.price < b.price
end

function PriceScaner:OnDone()
    self:SavePrices(self.db)

    for price, info in pairs(self.cache) do
        tinsert(self.items, {price = price, count = info.count, isMine = info.isMine})
    end

    sort(self.items, compare)
end

function PriceScaner:ProcessAuction(index)
    local itemKey, count, unitPrice, _, owner = Scaner.ProcessAuction(self, index)
    if itemKey == self.itemKey then

        if not self.cache[unitPrice] then
            self.cache[unitPrice] = {count = 0, isMine = false}
        end

        local c = self.cache[unitPrice]

        c.count = c.count + count
        c.isMine = c.isMine or (owner and UnitIsUnit('player', owner))
    end
end
