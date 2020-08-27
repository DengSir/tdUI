-- FullScan.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/25/2020, 10:33:08 AM
--
---@type ns
local ns = select(2, ...)

local next = next
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
    self.used = {}
    self.pool = {}

    self.firstRun = true

    self:SetScript('OnEvent', self.OnEvent)
    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.Hide)
    self:SetScript('OnUpdate', self.OnUpdate)

    ns.securehook('QueryAuctionItems', function()
        if self.running then
            self:Kill()
        end
    end)
end

function FullScan:OnShow()
    self.done = nil
    self:SetFrameLevel(self:GetParent():GetFrameLevel() + 100)
    self.Blocker:SetFrameLevel(self:GetFrameLevel() - 1)
end

function FullScan:Kill()
    self.killed = true
end

function FullScan:Start()
    if self.running then
        return
    end

    if self.firstRun then
        self.firstRun = nil

        for i = 1, 10 do
            self:CreateThread()
        end
    end

    self.startTick = GetTime()
    self.running = true
    self.waiting = true
    self.killed = nil
    self.prices = {}
    self:RegisterEvent('AUCTION_ITEM_LIST_UPDATE')

    QueryAuctionItems('', nil, nil, 0, nil, nil, true, false, nil)
end

function FullScan:OnEvent(event)
    if event == 'AUCTION_ITEM_LIST_UPDATE' then
        if self.waiting then
            self.waiting = nil
            self.index = GetNumAuctionItems('list')
        end
    end
end

function FullScan:OnUpdate()
    if self.running then
        if not self.waiting then
            self:Continue()
        end
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
    elseif self.done then
        self.Time:SetText('Finished')
    elseif not self:CanQuery() and self.startTick then
        self.Time:SetText('')
    end
end

function FullScan:Main()
    while true do
        if self:Process() then
            break
        else
            coroutine.yield()
        end
    end
    self:Done()
end

function FullScan:Continue()
    if not self.co then
        self.co = coroutine.create(function()
            return self:Main()
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
    while true do
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
        local itemKey = ns.parseItemKey(link)

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
        return true
    end
end

function FullScan:Process()
    for co in pairs(self.used) do
        coroutine.resume(co)

        if self:Threshold() then
            return
        end
    end

    while true do
        if self.index == 0 then
            break
        end

        local co = self:GetThread()
        if not co then
            return
        end

        coroutine.resume(co, self.index)
        self.index = self.index - 1

        if self:Threshold() then
            return
        end
    end
    return not next(self.used)
end

function FullScan:Done()
    local count = 0
    for k, v in pairs(self.prices) do
        ns.global.auction.prices[k] = v
        count = count + 1
    end

    self.done = true
    self.running = nil
    self.prices = nil
    self:UnregisterEvent('AUCTION_ITEM_LIST_UPDATE')

    print('Done', count)
end

function FullScan:ThreadMain()
    local co = coroutine.running()
    while true do
        self.pool[co] = true
        self.used[co] = nil

        local index = coroutine.yield()

        self.pool[co] = nil
        self.used[co] = true

        self:ProcessAuction(index)
    end
end

function FullScan:CreateThread()
    local co = coroutine.create(self.ThreadMain)
    coroutine.resume(co, self)
    return co
end

function FullScan:GetThread()
    return next(self.pool)
end
