-- Querier.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/1/2020, 1:04:12 PM
--
---@type ns
local ns = select(2, ...)

---@class Querier: Frame
---@field params tdUIAuctionQueryParams
local Querier = CreateFrame('Frame')
ns.Auction.Querier = Querier

local STATUS_PENDING = 1
local STATUS_WAITRESP = 2
local STATUS_RUNNING = 3

function Querier:Init()
    self:Hide()
    self:SetScript('OnEvent', self.OnEvent)
    self:SetScript('OnUpdate', self.OnUpdate)

    self:RegisterEvent('AUCTION_HOUSE_CLOSED')
end

---@param params table
---@param scaner Scaner
function Querier:Query(params, scaner)
    self.params = params
    self.scaner = scaner
    self.page = params.page or 0
    self.status = STATUS_PENDING

    self.statusProcess = { --
        [STATUS_PENDING] = self.Pending,
        [STATUS_RUNNING] = self.Running,
    }

    self.scaner:OnStart()
    self:Show()
end

function Querier:OnEvent(event)
    if event == 'AUCTION_ITEM_LIST_UPDATE' then
        self:OnResponse()
    elseif event == 'AUCTION_HOUSE_CLOSED' then
        self.queryAllDisabled = nil
        self:Hide()
    end
end

function Querier:OnUpdate()
    local method = self.statusProcess[self.status]
    if method then
        method(self)
    end
end

function Querier:OnResponse()
    local count, total = GetNumAuctionItems('list')
    if total == 0 then
        self.pageMax = 0
    else
        self.pageMax = floor(total / max(count, NUM_AUCTION_ITEMS_PER_PAGE))
    end

    self.scaner:OnResponse()
    self.status = STATUS_RUNNING
    self:UnregisterEvent('AUCTION_ITEM_LIST_UPDATE')
end

function Querier:CanQuery()
    local canQuery, canQueryAll = CanSendAuctionQuery('list')
    if not canQuery then
        return false
    end

    if self.params.queryAll and (not canQueryAll or self.queryAllDisabled) then
        return false
    end
    return true
end

function Querier:CanQueryAll()
    if not self.queryAllDisabled then
        return false
    end
    local canQuery, canQueryAll = CanSendAuctionQuery('list')
    return canQuery and canQueryAll
end

function Querier:Pending()
    if not self:CanQuery() then
        return
    end

    local params = self.params
    local text, exact = ns.Auction.parseSearchText(params.text)

    self.status = STATUS_WAITRESP
    self:RegisterEvent('AUCTION_ITEM_LIST_UPDATE')

    self.scaner:PreQuery()

    QueryAuctionItems(text, params.minLevel, params.maxLevel, self.page, params.usable, params.quality, params.queryAll,
                      exact, params.filters)

    if params.queryAll then
        self.queryAllDisabled = true
    end
end

function Querier:Running()
    if not self.scaner:Continue() then
        return
    end

    if self.scaner:Next() and self.page < self.pageMax then
        self.page = self.page + 1
        print(self.page)
        self.status = STATUS_PENDING
        return
    end

    print('Done')

    self.scaner:Done()
    self:Hide()
end
