-- Scaner.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/1/2020, 11:35:54 AM
--
---@type ns
local ns = select(2, ...)

---@class Scaner
---@field params tdUIAuctionQueryParams
local Scaner = ns.class()
ns.Auction.Scaner = Scaner

function Scaner:GetDB()
    return self.db
end

function Scaner:Query(params)
    self.params = params
    ns.Auction.Querier:Query(params, self)
end

function Scaner:Threshold()
    if debugprofilestop() > 16 then
        debugprofilestart()
        return true
    end
end

function Scaner:Continue()
    debugprofilestart()
    return self:OnContinue()
end

function Scaner:Done()
    self:OnDone()
    self:Fire('OnDone')
end

function Scaner:Next()
end

function Scaner:OnStart()
    self.pendings = {}
    self.db = {}
end

function Scaner:PreQuery()
end

function Scaner:OnResponse()
    self.index = GetNumAuctionItems('list')
end

function Scaner:OnContinue()
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

function Scaner:OnDone()
end

local VALID_NPCS = {
    -- 幽暗城
    [8672] = true,
    [8721] = true,
    [15675] = true,
    [15676] = true,
    [15682] = true,
    [15683] = true,
    [15684] = true,
    [15686] = true,
    -- 铁炉堡
    [8671] = true,
    [8720] = true,
    [9859] = true,
    -- 暴风城
    [8670] = true,
    [8719] = true,
    [15659] = true,
    -- 奥格瑞玛
    [8673] = true,
    [8724] = true,
    [9856] = true,
    -- 雷霆崖
    [8674] = true,
    [8722] = true,
    -- 达纳苏斯
    [8723] = true,
    [8669] = true,
    [15678] = true,
    [15679] = true,
}

local function NpcId()
    local guid = UnitGUID('npc')
    return guid and tonumber(guid:match('.-%-%d+%-%d+%-%d+%-%d+%-(%d+)'))
end

function Scaner:SavePrices(db)
    local npcId = NpcId()
    if not npcId or not VALID_NPCS[npcId] then
        return
    end
    for itemKey, price in pairs(db) do
        ns.global.auction.prices[itemKey] = price
    end
end

function Scaner:ProcessAuction(index)
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

    local db = self:GetDB()

    if buyoutPrice and buyoutPrice > 0 then
        local unitPrice = floor(buyoutPrice / count)
        local itemKey = ns.parseItemKey(link)

        if not db[itemKey] then
            db[itemKey] = unitPrice
        else
            db[itemKey] = min(db[itemKey], unitPrice)
        end
        return itemKey, count, unitPrice, quality
    end
end
