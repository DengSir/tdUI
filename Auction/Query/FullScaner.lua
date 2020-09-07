-- FullScaner.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/1/2020, 11:38:22 AM
--
---@type ns
local ns = select(2, ...)

local Scaner = ns.Auction.Scaner

---@class FullScaner: Scaner
local FullScaner = ns.class(Scaner)
ns.Auction.FullScaner = FullScaner

function FullScaner:OnStart()
    Scaner.OnStart(self)
    self.reportCache = {}
    self.report = nil
end

function FullScaner:OnDone()
    local report = {}

    for _, quality in pairs(self.reportCache) do
        report[quality] = (report[quality] or 0) + 1
    end

    self.report = report

    self:SavePrices(self.db)
end

function FullScaner:ProcessAuction(index)
    local itemKey, count, unitPrice, quality = Scaner.ProcessAuction(self, index)
    if itemKey then
        self.reportCache[itemKey] = quality
    end
end

function FullScaner:GetReport()
    return self.report
end
