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
    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.Hide)
    self:SetScript('OnUpdate', self.OnUpdate)

    self.scaner = ns.Auction.FullScaner:New()

    -- ns.securehook('QueryAuctionItems', function()
    --     if self.running then
    --         self:Kill()
    --     end
    -- end)
end

function FullScan:OnShow()
    self.done = nil
    self:SetFrameLevel(self:GetParent():GetFrameLevel() + 100)
    self.Blocker:SetFrameLevel(self:GetFrameLevel() - 1)
end

function FullScan:Start()
    ns.Auction.Querier:Query({text = '', queryAll = true}, self.scaner)
end

function FullScan:OnUpdate()
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

function FullScan:Done()

end
