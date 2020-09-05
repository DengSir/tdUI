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

    point(AuctionsItemButton, 'TOPLEFT', 30, -94)
    point(AuctionsDurationText, 'LEFT', self.Duration, 'RIGHT', -192, 3)
    point(StartPrice, 'BOTTOMLEFT', 35, 196)
    point(BuyoutPrice, 'BOTTOMLEFT', StartPrice, 'BOTTOMLEFT', 0, -35)
    point(PriceDropDown, 'TOPRIGHT', AuctionFrameAuctions, 'TOPLEFT', 217, -192)

    point(AuctionsStackSizeMaxButton, 'LEFT', AuctionsStackSizeEntry, 'RIGHT', 0, 1)
    point(AuctionsNumStacksMaxButton, 'LEFT', AuctionsNumStacksEntry, 'RIGHT', 0, 1)
    point(AuctionsStackSizeEntry, 'TOPLEFT', 33, -153)
    point(AuctionsNumStacksEntry, 'LEFT', AuctionsStackSizeEntry, 'RIGHT', 50, 0)
    point(AuctionsStackSizeEntryRight, 'RIGHT')
    point(AuctionsNumStacksEntryRight, 'RIGHT')

    point(AuctionsWowTokenAuctionFrame.BuyoutPriceLabel, 'TOPLEFT', 6, -58)

    AuctionsBuyoutErrorText:Hide()
    AuctionsBuyoutErrorText = self.BuyoutError

    AuctionsStackSizeEntry:SetWidth(40)
    AuctionsNumStacksEntry:SetWidth(40)
    AuctionsStackSizeMaxButton:SetWidth(40)
    AuctionsNumStacksMaxButton:SetWidth(40)

    self.AutoPrice.CountLabel:SetText('Count')
    self.AutoPrice.PriceLabel:SetText('Price')

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

    local scrollFrame = self.AutoPrice.ScrollFrame

    HybridScrollFrame_CreateButtons(scrollFrame, 'tdUIAuctionAutoPriceItemTemplate')
    scrollFrame.update = function()
        return self:UpdateAutoPriceList()
    end
    scrollFrame:SetScript('OnShow', scrollFrame.update)

    self:SetDuration(2)
    self.scaner = ns.Auction.PriceScaner:New()
    self.scaner:SetCallback('OnDone', function()
        local link = ns.Auction.GetAuctionSellItemLink()
        local itemKey = ns.parseItemKey(link)
        local price = ns.global.auction.prices[itemKey]
        local items = self.scaner:GetResponseItems()
        local err

        if not price then
            local p = select(11, GetItemInfo(link))
            if p then
                price = p * 10
                err = 'Use merchant price x10'
            else
                err = 'No price'
            end
        else
            price = price - 1
            if #items == 0 then
                err = 'Use history price'
            end
        end

        if #items > 0 then
            self:UpdateAutoPriceList()
            self.AutoPriceButton:Show()
        end

        if err then
            self.PriceSetText:SetText(err)
        else
            self.PriceSetText:SetText('Choose other price')
        end

        self.items = items
        self:SetPrice(price)
        self.PriceSetText:Show()
        self.PriceReading:Hide()
    end)

    ns.event('NEW_AUCTION_UPDATE', function()
        local name, texture, count, quality, canUse, price, pricePerUnit, stackCount, totalCount, itemId =
            GetAuctionSellItemInfo()

        self.AutoPrice:Hide()
        self.AutoPriceButton:Hide()
        self.PriceSetText:Hide()

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
                local stackSize = ns.profile.auction.sell.stackSize
                if stackSize == 0 then
                    stackSize = stackCount
                end
                stackSize = min(stackSize, totalCount, stackCount)
                local numStacks = floor(totalCount / stackSize)

                AuctionsStackSizeEntry:SetNumber(stackSize)
                AuctionsNumStacksEntry:SetNumber(numStacks)

                local deposit = GetAuctionDeposit(ns.profile.auction.sell.duration, 1, 1, stackSize, numStacks)
                if ns.profile.auction.sell.durationNoDeposit ~= 0 and deposit == 0 then
                    self:SetDuration(ns.profile.auction.sell.durationNoDeposit)
                else
                    self:SetDuration(ns.profile.auction.sell.duration)
                end

                MoneyInputFrame_SetCopper(StartPrice, 0)
                MoneyInputFrame_SetCopper(BuyoutPrice, 0)

                local link = ns.Auction.GetAuctionSellItemLink()
                self.scaner:SetItem(link)
                self.scaner:Query({text = link})

                self.PriceReading:Show()
            end
            self.Duration:Show()
        else
            self.Duration:Hide()
        end
    end)
end

function Auction:UpdateAutoPriceList()
    if not self.items then
        return
    end
    local scrollFrame = self.AutoPrice.ScrollFrame
    local buttons = scrollFrame.buttons
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local hasScrollBar = #self.items * 20 > scrollFrame:GetHeight()
    local width = hasScrollBar and 149 or 169

    for i, button in ipairs(buttons) do
        local item = self.items[i + offset]
        if not item then
            button:Hide()
        else
            button.price = item.price
            button.Count:SetText(item.count)
            button.Price:SetText(GetMoneyString(item.price))
            button:Show()
            button:SetWidth(width)
        end
    end

    HybridScrollFrame_Update(scrollFrame, #self.items * 20, scrollFrame:GetHeight())

    scrollFrame:SetWidth(width)

    print(width, scrollFrame:GetWidth())

end

function Auction:SetDuration(duration)
    AuctionFrameAuctions.duration = duration
    self.Duration:SetValue(duration)
    UpdateDeposit()
end

function Auction:SetPrice(price)
    if not price then
        return
    end

    if AuctionFrameAuctions.priceType == 1 then
        MoneyInputFrame_SetCopper(BuyoutPrice, price)
        MoneyInputFrame_SetCopper(StartPrice, price * 0.95)
    else
        local stackSize = AuctionsStackSizeEntry:GetNumber()
        MoneyInputFrame_SetCopper(BuyoutPrice, price * stackSize)
        MoneyInputFrame_SetCopper(StartPrice, price * 0.95 * stackSize)
    end
end
