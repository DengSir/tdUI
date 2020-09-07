-- BrowseScaner.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/1/2020, 12:48:16 PM
--
---@type ns
local ns = select(2, ...)

local Scaner = ns.Auction.Scaner

---@class BrowseScaner: Scaner
local BrowseScaner = ns.class(Scaner)
ns.Auction.BrowseScaner = BrowseScaner

function BrowseScaner:Query(params)
    if not ns.Auction.paramsEq(params, self.params) then
        self.pages = {}
    end
    Scaner.Query(self, params)
end

function BrowseScaner:GetDB()
    return self.pages[self.params.page]
end

function BrowseScaner:OnResponse()
    Scaner.OnResponse(self)
    self.pages[self.params.page] = {}
end

function BrowseScaner:OnDone()
    local prices = {}
    local page = 0

    while true do
        local p = self.pages[page]
        if not p then
            break
        end

        for itemKey, price in pairs(p) do
            if not prices[itemKey] then
                prices[itemKey] = price
            else
                prices[itemKey] = min(prices[itemKey], price)
            end
        end
        page = page + 1
    end

    self:SavePrices(prices)
end
