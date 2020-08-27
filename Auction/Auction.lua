-- Auction.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/27/2020, 4:34:52 PM
--
---@type ns
local ns = select(2, ...)

local Auction = ns.class('Frame')
ns.Auction.Auction = Auction

function Auction:Constructor()
    ns.hookscript(self.StackSizeSlider, 'OnValueChanged', function()
        self:UpdateSlider()
    end)

    ns.event('NEW_AUCTION_UPDATE', function()
        self:UpdateSlider()
    end)
end

function Auction:UpdateSlider()
    local name, texture, count, quality, canUse, price, pricePerUnit, stackCount, totalCount, itemId =
        GetAuctionSellItemInfo()

    if not C_WowTokenPublic.IsAuctionableWowToken(itemId) then
        local stackCountMax = min(stackCount, totalCount)
        local numStackCount = floor(totalCount / self.StackSizeSlider:GetValue())

        self.StackSizeSlider:SetMinMaxValues(1, stackCountMax)
        self.NumStackSlider:SetMinMaxValues(1, numStackCount)
    end
end
