-- AuctionPlus.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 11/17/2021, 11:54:12 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('tdAuction', function()
    local tdAuction = LibStub('AceAddon-3.0'):GetAddon('tdAuction')
    local FullScaner = tdAuction:GetClass('FullScaner')

    local orig_OnStart = FullScaner.OnStart
    local orig_OnDone = FullScaner.OnDone
    local orig_ProcessAuction = FullScaner.ProcessAuction

    local items = {}

    function FullScaner:OnStart()
        wipe(items)
        orig_OnStart(self)
    end

    function FullScaner:OnDone()
        orig_OnDone(self)

        for itemId, d in pairs(items) do
            local link = select(2, GetItemInfo(itemId))
            if link then
                DEFAULT_CHAT_FRAME:AddMessage(link .. ' ' .. GetMoneyString(d))
            else
                print('not found item', itemId)
            end
        end
    end

    function FullScaner:ProcessAuction(index)
        orig_ProcessAuction(self, index)

        local _, _, count, quality, _, _, _, _, _, buyoutPrice, _, _, _, owner, _, _, itemId, hasAllInfo =
            GetAuctionItemInfo('list', index)

        if not itemId or not buyoutPrice or buyoutPrice <= 0 then
            return
        end

        local name, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemId)
        if not name then
            return
        end

        local unitPrice = buyoutPrice / count
        if sellPrice - unitPrice <= 0 then
            return
        end

        items[itemId] = sellPrice - unitPrice
    end

    local BrowseItem = tdAuction:GetClass('UI.BrowseItem')

    local orig_BrowseItem_Update = BrowseItem.Update

    function BrowseItem:Update(id)
        orig_BrowseItem_Update(self, id)

        local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice,
              bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo =
            GetAuctionItemInfo('list', id)

        local name, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemId)
        if not name then
            return
        end

        local unitPrice = buyoutPrice / count

        if unitPrice > 0 and unitPrice < sellPrice then
            self.Name.Text:SetText(self.Name.Text:GetText() .. ' ' .. GetMoneyString(sellPrice * count - buyoutPrice))
        end
    end
end)
