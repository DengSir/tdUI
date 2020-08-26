-- FullScan.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/25/2020, 10:33:08 AM
--
---@type ns
local ns = select(2, ...)

local pairs = pairs
local coroutine = coroutine
local debugprofilestop = debugprofilestop
local debugprofilestart = debugprofilestart

local GetTime = GetTime
local QueryAuctionItems = QueryAuctionItems
local GetAuctionItemLink = GetAuctionItemLink
local GetAuctionItemInfo = GetAuctionItemInfo
local GetNumAuctionItems = GetNumAuctionItems

local FullScan = ns.class('Frame')
ns.Auction.FullScan = FullScan

function FullScan:Constructor()
    self.pool = {}
    self:SetScript('OnEvent', self.OnEvent)
    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnUpdate', self.OnUpdate)
end

function FullScan:OnShow()
    self:SetFrameLevel(self:GetParent():GetFrameLevel() + 100)
    self.Blocker:SetFrameLevel(self:GetFrameLevel() - 1)
end

function FullScan:Start()
    if self.running then
        return
    end

    self.startTick = GetTime()
    self.running = true
    self.waiting = true
    self.prices = {}
    self:RegisterEvent('AUCTION_ITEM_LIST_UPDATE')

    QueryAuctionItems('', nil, nil, 0, nil, nil, true, false, nil)
end

function FullScan:OnEvent(event)
    if event == 'AUCTION_ITEM_LIST_UPDATE' then
        self.waiting = nil
    else

    end
end

function FullScan:OnUpdate()
    if self.running then
        if not self.waiting then
            self:Continue()
        end
    else

    end
    self:UpdateUI()
end

function FullScan:CanQuery()
    if self.running then
        return false
    end
    if not CanSendAuctionQuery('list') then
        return false
    end
    if not self.startTick then
        return true
    end
    return GetTime() - self.startTick > 15 * 60
end

function FullScan:UpdateUI()
    self.ExecButton:SetEnabled(self:CanQuery())

    if self.running then
        self.Time:SetText('Time left: ' .. SecondsToTime(GetTime() - self.startTick))
    end
end

function FullScan:Continue()
    if not self.co then
        self.co = coroutine.create(function()
            return self:Process()
        end)
    end

    if coroutine.status(self.co) ~= 'dead' then
        coroutine.resume(self.co)
    else
        self:SetScript('OnUpdate', nil)
        self.co = nil
    end
end

function FullScan:WaitAuctionInfo(index)
    local link
    local times = 0
    while true do
        times = times + 1
        link = GetAuctionItemLink('list', index)
        if link then
            return link, GetAuctionItemInfo('list', index)
        end

        if not GetAuctionItemInfo('list', index) then
            return
        end

        coroutine.yield()
    end
end

function FullScan:ProcessAuction(index)
    local link, name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice,
          bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo =
        self:WaitAuctionInfo(index)

    if not link then
        return
    end

    if buyoutPrice and buyoutPrice > 0 then
        local unitPrice = buyoutPrice / count
        local itemKey = ns.parseItemLink(link)

        if not self.prices[itemKey] then
            self.prices[itemKey] = unitPrice
        else
            self.prices[itemKey] = min(self.prices[itemKey], unitPrice)
        end
    end
end

function FullScan:Threshold()
    if debugprofilestop() > 16 then
        debugprofilestart()
        coroutine.yield()
    end
end

function FullScan:Process()
    for i = GetNumAuctionItems('list'), 1, -1 do
        self:ProcessAuction(i)
        self:Threshold()
    end

    for k, v in pairs(self.prices) do
        ns.global.auction.prices[k] = v
    end

    self.running = nil
    self.prices = nil
    self:UnregisterEvent('AUCTION_ITEM_LIST_UPDATE')

    print('Done')
end
