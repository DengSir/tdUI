-- Auction.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/27/2020, 4:34:52 PM
--
---@type ns
local ns = select(2, ...)

local point = ns.RePoint

local Auction = ns.class('Frame')
ns.Auction.Auction = Auction

function Auction:Constructor()
    local t = AuctionsItemButton:CreateTexture(nil, 'BACKGROUND')
    t:SetSize(173, 40)
    t:SetPoint('TOPLEFT', -2, 2)
    t:SetTexture([[Interface\AuctionFrame\UI-AuctionFrame-ItemSlot]])
    t:SetTexCoord(0.15625, 0.83203125, 0.171875, 0.796875)

    ns.hide(AuctionsShortAuctionButton)
    ns.hide(AuctionsMediumAuctionButton)
    ns.hide(AuctionsLongAuctionButton)

    point(AuctionsItemButton, 'TOPLEFT', 28, -94)
    point(AuctionsDurationText, 'TOPLEFT', 28, -185)
    point(StartPrice, 'BOTTOMLEFT', 35, 151)
    point(BuyoutPrice, 'TOPLEFT', StartPrice, 'BOTTOMLEFT', 0, -20)

    point(AuctionsStackSizeMaxButton, 'LEFT', AuctionsStackSizeEntry, 'RIGHT', 0, 1)
    point(AuctionsNumStacksMaxButton, 'LEFT', AuctionsNumStacksEntry, 'RIGHT', 0, 1)
    point(AuctionsStackSizeEntry, 'TOPLEFT', 33, -153)
    point(AuctionsNumStacksEntry, 'LEFT', AuctionsStackSizeEntry, 'RIGHT', 50, 0)
    point(AuctionsStackSizeEntryRight, 'RIGHT')
    point(AuctionsNumStacksEntryRight, 'RIGHT')

    AuctionsBuyoutErrorText:Hide()
    AuctionsBuyoutErrorText = self.BuyoutError

    AuctionsStackSizeEntry:SetWidth(40)
    AuctionsNumStacksEntry:SetWidth(40)
    AuctionsStackSizeMaxButton:SetWidth(40)
    AuctionsNumStacksMaxButton:SetWidth(40)

    AuctionFrameAuctions.priceType = 1

    local function OnTextChanged(frame, userInput)
        if not userInput and frame:GetText() == '0' then
            frame:SetText('')
        end
    end

    local function HookMoneyInput(frame)
        frame.gold:HookScript('OnTextChanged', OnTextChanged)
        frame.silver:HookScript('OnTextChanged', OnTextChanged)
        frame.copper:HookScript('OnTextChanged', OnTextChanged)
    end

    HookMoneyInput(StartPrice)
    HookMoneyInput(BuyoutPrice)

    ns.combobox(self.Duration, {
        {text = '2 ' .. HOURS, value = 1},
        {text = '8 ' .. HOURS, value = 2},
        {text = '24 ' .. HOURS, value = 3},
    }, function(value)
        return self:SetDuration(value)
    end)

    self:SetDuration(2)
    self.scaner = ns.Auction.PriceScaner:New()
    self.scaner:SetCallback('OnDone', function()
        local link = ns.Auction.GetAuctionSellItemLink()
        local itemKey = ns.parseItemKey(link)
        local price = ns.global.auction.prices[itemKey]

        if price then
            local unitPrice = floor(price)
            if unitPrice == price then
                unitPrice = price - 1
            end

            if AuctionFrameAuctions.priceType == 1 then
                MoneyInputFrame_SetCopper(BuyoutPrice, unitPrice)
                MoneyInputFrame_SetCopper(StartPrice, unitPrice * 0.95)
            else
                local stackSize = AuctionsStackSizeEntry:GetNumber()
                MoneyInputFrame_SetCopper(BuyoutPrice, unitPrice * stackSize)
                MoneyInputFrame_SetCopper(StartPrice, unitPrice * 0.95 * stackSize)
            end
        end
    end)

    ns.event('NEW_AUCTION_UPDATE', function()
        local name, texture, count, quality, canUse, price, pricePerUnit, stackCount, totalCount, itemId =
            GetAuctionSellItemInfo()

        if not C_WowTokenPublic.IsAuctionableWowToken(itemId) then
            if totalCount > 1 then
                AuctionsItemButtonCount:SetText(totalCount)
                AuctionsItemButtonCount:Show()
                AuctionsStackSizeEntry:Show()
                AuctionsStackSizeMaxButton:Show()
                AuctionsNumStacksEntry:Show()
                AuctionsNumStacksMaxButton:Show()
                PriceDropDown:Show()
                UpdateMaximumButtons()
            else
                AuctionsItemButtonCount:Hide()
                AuctionsStackSizeEntry:Hide()
                AuctionsStackSizeMaxButton:Hide()
                AuctionsNumStacksEntry:Hide()
                AuctionsNumStacksMaxButton:Hide()
                PriceDropDown:Hide()
            end

            if totalCount > 0 then
                local stackSize = ns.profile.auction.stackSize
                if stackSize == 0 then
                    stackSize = stackCount
                end
                stackSize = min(stackSize, totalCount, stackCount)
                local numStacks = floor(totalCount / stackSize)

                AuctionsStackSizeEntry:SetNumber(stackSize)
                AuctionsNumStacksEntry:SetNumber(numStacks)

                local deposit = GetAuctionDeposit(ns.profile.auction.duration, 1, 1, stackSize, numStacks)
                if ns.profile.auction.durationNoDeposit and deposit == 0 then
                    self:SetDuration(3)
                else
                    self:SetDuration(ns.profile.auction.duration)
                end

                MoneyInputFrame_SetCopper(StartPrice, 0)
                MoneyInputFrame_SetCopper(BuyoutPrice, 0)

                local link = ns.Auction.GetAuctionSellItemLink()
                self.scaner:SetItem(link)

                ns.Auction.Querier:Query({text = link}, self.scaner)
            end
        end
    end)
end

function Auction:SetDuration(duration)
    AuctionFrameAuctions.duration = duration
    self.Duration:SetValue(duration)
    UpdateDeposit()
end
