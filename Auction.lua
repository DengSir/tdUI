-- Auction.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/17/2020, 7:03:55 PM
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_AuctionUI', function()
    -- list sorts
    AuctionSort['list_level'] = {
        {column = 'duration', reverse = true},
        {column = 'unitprice', reverse = false},
        {column = 'quantity', reverse = false},
        {column = 'minbidbuyout', reverse = true},
        {column = 'name', reverse = true},
        {column = 'quality', reverse = true},
        {column = 'level', reverse = false},
    }

    AuctionSort['list_duration'] = {
        {column = 'unitprice', reverse = false},
        {column = 'quantity', reverse = true},
        {column = 'minbidbuyout', reverse = false},
        {column = 'name', reverse = false},
        {column = 'level', reverse = true},
        {column = 'quality', reverse = false},
        {column = 'duration', reverse = false},
    }

    AuctionSort['list_seller'] = {
        {column = 'duration', reverse = false},
        {column = 'unitprice', reverse = false},
        {column = 'quantity', reverse = true},
        {column = 'minbidbuyout', reverse = false},
        {column = 'name', reverse = false},
        {column = 'level', reverse = true},
        {column = 'quality', reverse = false},
        {column = 'seller', reverse = false},
    }

    AuctionSort['list_unitprice'] = {
        {column = 'duration', reverse = false},
        {column = 'quantity', reverse = true},
        {column = 'name', reverse = false},
        {column = 'level', reverse = true},
        {column = 'quality', reverse = false},
        {column = 'unitprice', reverse = false},
    }

    AuctionSort['list_quality'] = {
        {column = 'duration', reverse = false},
        {column = 'unitprice', reverse = false},
        {column = 'quantity', reverse = true},
        {column = 'minbidbuyout', reverse = false},
        {column = 'name', reverse = false},
        {column = 'level', reverse = true},
        {column = 'quality', reverse = false},
    }

    AuctionSort['list_buyout'] = {
        {column = 'duration', reverse = false},
        {column = 'quantity', reverse = true},
        {column = 'name', reverse = false},
        {column = 'level', reverse = true},
        {column = 'quality', reverse = false},
        {column = 'buyout', reverse = false},
    }

    AuctionFrameBrowse:UnregisterEvent('AUCTION_ITEM_LIST_UPDATE')
    AuctionFrame_SetSort('list', 'unitprice')

    ns.hide(BrowseQualitySort)
    ns.hide(BrowseLevelSort)
    ns.hide(BrowseDurationSort)
    ns.hide(BrowseHighBidderSort)
    ns.hide(BrowseCurrentBidSort)
    ns.hide(BrowseScrollFrame)

    for i = 1, NUM_BROWSE_TO_DISPLAY do
        ns.hide(_G['BrowseButton' .. i])
    end

    local function HideText(obj)
        for i, v in ipairs({obj:GetRegions()}) do
            if v:GetObjectType() == 'FontString' then
                v:Hide()
            end
        end
    end

    BrowseNextPageButton:ClearAllPoints()
    BrowseNextPageButton:SetPoint('TOPRIGHT', 70, -45)
    HideText(BrowseNextPageButton)

    BrowsePrevPageButton:ClearAllPoints()
    BrowsePrevPageButton:SetPoint('RIGHT', BrowseNextPageButton, 'LEFT')
    HideText(BrowsePrevPageButton)

    BrowseSearchCountText:ClearAllPoints()
    BrowseSearchCountText:SetPoint('BOTTOMLEFT', 190, 17)

    BrowseBidPrice:SetPoint('BOTTOM', 115, 18)

    local NONE = GRAY_FONT_COLOR:WrapTextInColorCode(NONE)
    local DURATION_TEXT = { --
        [1] = RED_FONT_COLOR:WrapTextInColorCode('< 30m'),
        [2] = YELLOW_FONT_COLOR:WrapTextInColorCode('30m-2h'),
        [3] = GREEN_FONT_COLOR:WrapTextInColorCode('2-8h'),
        [4] = GRAY_FONT_COLOR:WrapTextInColorCode('> 8h'),
    }

    local Browse = CreateFrame('Frame', nil, AuctionFrameBrowse, 'tdUIAuctionBrowseFrameTemplate')
    local ScrollFrame = Browse.ScrollFrame

    local function GSC(money)
        money = floor(money)
        local text = ''
        if (money % 100 > 0) and (money < 10000) or (money == 0) then
            text = COPPER_AMOUNT_TEXTURE:format(money % 100, 0, 0)
        end
        money = floor(money / 100)
        if (money % 100 > 0) and (money < 100000) then
            text = SILVER_AMOUNT_TEXTURE:format(money % 100) .. ' ' .. text
        end
        money = floor(money / 100)
        if (money > 0) then
            text = GOLD_AMOUNT_TEXTURE:format(money, 0, 0) .. ' ' .. text
        end
        return text
    end

    local sortButtons = {}
    do
        local headers = {
            {text = NAME, width = 160, sortColumn = 'quality'},
            {text = REQ_LEVEL_ABBR, width = 30, sortColumn = 'level'},
            {text = 'Time', width = 70, sortColumn = 'duration'},
            {text = AUCTION_CREATOR, width = 70, sortColumn = 'seller'},
            {text = 'Bid', width = 96, sortColumn = 'bid'},
            {text = BUYOUT, width = 96, sortColumn = 'buyout'},
            {text = 'Unit price', width = 96, sortColumn = 'unitprice'},
        }

        local function SortOnClick(button)
            return AuctionFrame_OnClickSortColumn('list', button.sortColumn)
        end

        local prev
        for i, v in ipairs(headers) do
            local button = CreateFrame('Button', 'BrowseButtonSort' .. i, Browse, 'AuctionSortButtonTemplate')
            button:SetHeight(19)
            button:SetWidth(v.width)
            button:SetText(v.text)
            button.sortColumn = v.sortColumn
            button:SetScript('OnClick', SortOnClick)
            tinsert(sortButtons, button)

            if prev then
                button:ClearAllPoints()
                button:SetPoint('LEFT', prev, 'RIGHT')
            else
                button:SetPoint('TOPLEFT', AuctionFrameBrowse, 'TOPLEFT', 186, -82)
            end
            prev = button
        end
    end

    ns.override('AuctionFrameBrowse_Update', nop)

    ns.override('AuctionFrameBrowse_UpdateArrows', function()
        for _, button in ipairs(sortButtons) do
            SortButton_UpdateArrow(button, 'list', button.sortColumn)
        end
    end)

    ns.hookscript(BrowseSearchButton, 'OnEnable', function()
        for _, button in ipairs(sortButtons) do
            button:Enable()
        end
    end)

    ns.hookscript(BrowseSearchButton, 'OnDisable', function()
        for _, button in ipairs(sortButtons) do
            button:Disable()
        end
    end)

    local function UsableColor(usable)
        if usable then
            return 1, 1, 1
        else
            return 1, 0.1, 0.1
        end
    end

    local UpdateBrowseList = ns.pend(function(self)
        self = self or ScrollFrame
        if not self:IsVisible() then
            return
        end

        local offset = HybridScrollFrame_GetOffset(self)
        local numBatchAuctions, totalAuctions = GetNumAuctionItems('list')
        local selectedId = GetSelectedAuctionItem('list')
        local width = numBatchAuctions > #self.buttons and 614 or 634
        local playerLevel = UnitLevel('player')

        self:GetParent():SetWidth(width)
        BrowseNoResultsText:SetShown(numBatchAuctions == 0)

        for i, button in ipairs(self.buttons) do
            local id = offset + i
            local index = id + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)
            local shouldHide = index > (numBatchAuctions + NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)
            if shouldHide then
                button:Hide()
            else
                button:Show()

                local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice,
                      bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo =
                    GetAuctionItemInfo('list', id)
                local duration = GetAuctionItemTimeLeft('list', id)

                button.id = id
                button:SetID(id)
                button:SetWidth(width)

                button.Bg:SetShown(id % 2 == 1)
                button.Selected:SetShown(selectedId == id)

                button.Name:SetText(count > 1 and format('|cffffd100%dx|r%s', count, name) or name)
                button.Name:SetTextColor(ns.rgb(GetItemQualityColor(quality)))

                button.Icon:SetTexture(texture)
                button.Icon:SetVertexColor(UsableColor(canUse))

                button.Level:SetText(level)
                button.Level:SetTextColor(UsableColor(playerLevel >= level))

                button.Time:SetText(DURATION_TEXT[duration])
                button.Seller:SetText(owner)

                button.Bid:SetText(GSC(bidAmount == 0 and minBid or bidAmount))

                if buyoutPrice == 0 then
                    button.Buyout:SetText(NONE)
                    button.UnitPrice:SetText(NONE)
                else
                    button.Buyout:SetText(GSC(buyoutPrice))
                    button.UnitPrice:SetText(GSC(buyoutPrice / count))
                end
            end
        end
        HybridScrollFrame_Update(self, numBatchAuctions * 18, self:GetHeight())

        if totalAuctions > NUM_AUCTION_ITEMS_PER_PAGE then
            BrowsePrevPageButton.isEnabled = AuctionFrameBrowse.page ~= 0
            BrowseNextPageButton.isEnabled =
                AuctionFrameBrowse.page ~= ceil(totalAuctions / NUM_AUCTION_ITEMS_PER_PAGE) - 1

            BrowsePrevPageButton:Show()
            BrowseNextPageButton:Show()
            BrowseSearchCountText:Show()
            local itemsMin = AuctionFrameBrowse.page * NUM_AUCTION_ITEMS_PER_PAGE + 1
            local itemsMax = itemsMin + numBatchAuctions - 1
            BrowseSearchCountText:SetFormattedText(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax, totalAuctions)
        else
            BrowsePrevPageButton.isEnabled = false
            BrowseNextPageButton.isEnabled = false
            BrowsePrevPageButton:Hide()
            BrowseNextPageButton:Hide()
            BrowseSearchCountText:Hide()
        end
    end)

    local function UpdateSelectedItem()
        BrowseBidButton:Show()
        BrowseBuyoutButton:Show()
        BrowseBidButton:Disable()
        BrowseBuyoutButton:Disable()

        local id = GetSelectedAuctionItem('list')
        if id == 0 then
            return
        end

        local money = GetMoney()
        local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice,
              bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo =
            GetAuctionItemInfo('list', id)
        local ownerName = ownerFullName or owner
        local isMine = UnitName('player') == ownerName

        if buyoutPrice > 0 and buyoutPrice >= minBid then
            local canBuyout = 1
            if money < buyoutPrice then
                if not highBidder or money + bidAmount < buyoutPrice then
                    canBuyout = nil
                end
            end
            if canBuyout and not isMine then
                BrowseBuyoutButton:Enable()
                AuctionFrame.buyoutPrice = buyoutPrice
            end
        else
            AuctionFrame.buyoutPrice = nil
        end

        local requiredBid

        if (bidAmount == 0) then
            requiredBid = minBid
        else
            requiredBid = bidAmount + minIncrement
        end

        MoneyInputFrame_SetCopper(BrowseBidPrice, requiredBid)

        if not highBidder and not isMine and money >= MoneyInputFrame_GetCopper(BrowseBidPrice) and
            MoneyInputFrame_GetCopper(BrowseBidPrice) <= MAXIMUM_BID_PRICE then
            BrowseBidButton:Enable()
        end
    end

    do
        ScrollFrame.update = UpdateBrowseList
        HybridScrollFrame_CreateButtons(ScrollFrame, 'tdUIAuctionBrowseItemTemplate')

        local function OnClick(button)
            if IsModifiedClick() then
                if not HandleModifiedItemClick(GetAuctionItemLink('list', button.id)) then
                    if IsModifiedClick('DRESSUP') then
                        DressUpBattlePet(GetAuctionItemBattlePetInfo('list', button.id))
                    end
                end
            else
                if GetCVarBool('auctionDisplayOnCharacter') then
                    if not DressUpItemLink(GetAuctionItemLink('list', button.id)) then
                        DressUpBattlePet(GetAuctionItemBattlePetInfo('list', button.id))
                    end
                end

                SetSelectedAuctionItem('list', button.id)
                CloseAuctionStaticPopups()
                UpdateSelectedItem()
                UpdateBrowseList()
            end
        end

        local function ItemOnClick(self)
            return OnClick(self:GetParent())
        end

        for i, button in ipairs(ScrollFrame.buttons) do
            button:SetScript('OnClick', OnClick)
            button.Enter:SetScript('OnClick', ItemOnClick)
        end
    end

    ns.securehook('BrowseWowTokenResults_Update', function()
        return Browse:SetShown(not AuctionFrame_DoesCategoryHaveFlag('WOW_TOKEN_FLAG',
                                                                     AuctionFrameBrowse.selectedCategoryIndex))
    end)

    ScrollFrame:SetScript('OnShow', UpdateBrowseList)

    ns.event('AUCTION_ITEM_LIST_UPDATE', function()
        UpdateBrowseList()
        UpdateSelectedItem()
        AuctionFrameBrowse.isSearching = nil
        BrowseNoResultsText:SetText(BROWSE_NO_RESULTS)
    end)
end)
