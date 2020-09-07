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

local STATUS_NONE = 1
local STATUS_QUERY = 2
local STATUS_DONE = 3

function FullScan:Constructor()
    self.startTick = 0

    self:SetScript('OnShow', self.OnShow)
    self:SetScript('OnHide', self.Hide)
    self:SetScript('OnUpdate', self.OnUpdate)

    self.statusUpdaters = {
        [STATUS_NONE] = self.UpdateNone,
        [STATUS_QUERY] = self.UpdateQuering,
    }

    self.scaner = ns.Auction.FullScaner:New()
    self.scaner:SetCallback('OnDone', function()
        self.status = STATUS_DONE
        self:UpdateDone()
    end)
end

function FullScan:OnShow()
    self.status = STATUS_NONE
    self:SetFrameLevel(self:GetParent():GetFrameLevel() + 100)
    self.Blocker:SetFrameLevel(self:GetFrameLevel() - 1)
end

function FullScan:Start()
    self.scaner:Query({text = '', queryAll = true})
    self.status = STATUS_QUERY
    self.startTick = GetTime()
end

function FullScan:OnUpdate()
    self.ExecButton:SetEnabled(ns.Auction.Querier:CanQueryAll())

    local method = self.statusUpdaters[self.status]
    if method then
        method(self)
    end
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

function FullScan:UpdateNone()
    self.Time:SetText('')
end

function FullScan:UpdateDone()
    local report = self.scaner:GetReport()
    local sb = {}

    for quality = Enum.ItemQuality.Poor, Enum.ItemQuality.Heirloom do
        local r, g, b = GetItemQualityColor(quality)
        if report[quality] then
            tinsert(sb, format('|cff%02x%02x%02x%s|r: %d', r * 255, g * 255, b * 255,
                               _G['ITEM_QUALITY' .. quality .. '_DESC'], report[quality]))
        end
    end
    self.Time:SetText('Finished\n' .. table.concat(sb, '\n'))
end

function FullScan:UpdateQuering()
    self.Time:SetText('Time left: ' .. SecondsToTime(GetTime() - self.startTick))
end
