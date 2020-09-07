-- Browse.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/24/2020, 12:57:33 PM
--
---@type ns
local ns = select(2, ...)

local _G = _G
local point = ns.RePoint
local ipairs = ipairs

local GetMoney = GetMoney
local UnitName = UnitName
local GetAuctionItemInfo = GetAuctionItemInfo
local GetNumAuctionItems = GetNumAuctionItems
local GetSelectedAuctionItem = GetSelectedAuctionItem
local MoneyInputFrame_SetCopper = MoneyInputFrame_SetCopper

local BUTTON_HEIGHT = 18

---@type tdUIAuctionBrowse
local Browse = ns.class('Frame')
ns.Auction.Browse = Browse

function Browse:Constructor()
    self.noSearch = true
    self.prevSearchParams = {}

    self.Frame = CreateFrame('Frame', nil, self)

    self.scaner = ns.Auction.BrowseScaner:New()
    self.scaner:SetCallback('OnDone', function()
        self.prevSearchParams = self.searchParams
        self:UpdateAll()
    end)

    self:SetupScrollFrame()
    self:SetupBlizzard()
    self:SetupSortButtons()
    self:SetupEventsAndHooks()
    self:SaveSort()
end

function Browse:SetupBlizzard()
    if not BrowseResetButton then
        local button = CreateFrame('Button', 'BrowseResetButton', self, 'UIPanelButtonTemplate')
        button:SetText(RESET)
        button:SetSize(80, 22)
        button:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 67, -35)
        button:SetScript('OnClick', AuctionFrameBrowse_Reset)
        button:SetScript('OnUpdate', BrowseResetButton_OnUpdate)
    end

    local NoResultsText = self.Frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    NoResultsText:SetPoint('TOP', self.ScrollFrame, 'TOP', 0, -40)

    self.NameInput = BrowseName
    self.SearchButton = BrowseSearchButton
    self.ResetButton = BrowseResetButton
    self.PrevPageButton = BrowsePrevPageButton
    self.NextPageButton = BrowseNextPageButton
    self.QualityDropDown = BrowseDropDown
    self.IsUsableCheckButton = IsUsableCheckButton
    self.BidPrice = BrowseBidPrice
    self.BidButton = BrowseBidButton
    self.BuyoutButton = BrowseBuyoutButton
    self.SearchCountText = BrowseSearchCountText
    self.NoResultsText = NoResultsText
    self.MinLevelInput = BrowseMinLevel
    self.MaxLevelInput = BrowseMaxLevel

    for i = 1, NUM_BROWSE_TO_DISPLAY do
        ns.hide(_G['BrowseButton' .. i])
    end

    ns.hide(BrowseQualitySort)
    ns.hide(BrowseLevelSort)
    ns.hide(BrowseDurationSort)
    ns.hide(BrowseHighBidderSort)
    ns.hide(BrowseCurrentBidSort)
    ns.hide(BrowseScrollFrame)
    ns.hide(BrowseIsUsableText)
    ns.hide(BrowseShowOnCharacterText)
    ns.hide(BrowseTabText)
    ns.hide(BrowseNoResultsText)

    local function text(obj, text)
        obj:SetFontObject(GameFontHighlightSmall)
        obj:SetText(text)
    end

    text(ShowOnPlayerCheckButtonText, DISPLAY_ON_CHARACTER)
    text(IsUsableCheckButtonText, USABLE_ITEMS)

    local labels = {BrowseLevelText, BrowseNameText, BrowseDropDownName}
    local height = 0
    for _, label in ipairs(labels) do
        height = max(height, label:GetHeight())
    end
    for _, label in ipairs(labels) do
        label:SetHeight(height)
    end

    local nameWidth = 220

    self.NameInput:SetWidth(nameWidth)
    UIDropDownMenu_SetWidth(self.QualityDropDown, 60)

    point(BrowseSearchDotsText, 'LEFT', self.NoResultsText, 'RIGHT')

    point(self.SearchButton, 'TOPRIGHT', self.ResetButton, 'TOPLEFT', -5, 0)
    point(self.PrevPageButton, 'TOPLEFT', 658, -53)
    point(self.NextPageButton, 'TOPRIGHT', 70, -53)
    point(self.SearchCountText, 'BOTTOMLEFT', 190, 17)
    point(self.BidPrice, 'BOTTOM', 115, 18)

    point(BrowseLevelText, 'TOPLEFT', nameWidth + 90, -38)
    point(BrowseDropDownName, 'TOPLEFT', self, nameWidth + 170, -38)

    point(self.NameInput, 'TOPLEFT', BrowseNameText, 'BOTTOMLEFT', 3, -3)
    point(self.QualityDropDown, 'TOPLEFT', BrowseDropDownName, 'BOTTOMLEFT', -18, 3)
    point(self.IsUsableCheckButton, 'TOPLEFT', nameWidth + 260, -38)
    point(ShowOnPlayerCheckButton, 'TOPLEFT', self.IsUsableCheckButton, 'BOTTOMLEFT', 0, 2)

    local function parent(obj)
        obj:SetParent(self.Frame)
        obj:Show()
        obj.Hide = nop
    end

    parent(self.PrevPageButton)
    parent(self.NextPageButton)
    parent(self.SearchCountText)
    parent(self.BidButton)
    parent(self.BuyoutButton)
    parent(self.SearchButton)
    parent(self.ResetButton)

    local menuList = {}
    do
        tinsert(menuList, { --
            text = ALL,
            value = -1,
        })

        for i = Enum.ItemQuality.Poor, Enum.ItemQuality.Epic do
            local r, g, b = GetItemQualityColor(i)
            tinsert(menuList, {
                text = format('|cff%02x%02x%02x%s|r', r * 255, g * 255, b * 255, _G['ITEM_QUALITY' .. i .. '_DESC']),
                value = i,
            })
        end
    end

    ns.combobox(self.QualityDropDown, menuList)
    self.QualityDropDown:SetValue(-1)
end

function Browse:SetupScrollFrame()
    self.ScrollFrame = CreateFrame('ScrollFrame', nil, self.Frame, 'tdAuctionBrowseScrollFrameTemplate')
    self.ScrollFrame:SetPoint('TOPLEFT', self, 'TOPLEFT', 190, -104)
    self.ScrollFrame.update = function()
        return self:UpdateList()
    end

    HybridScrollFrame_CreateButtons(self.ScrollFrame, 'tdAuctionBrowseItemTemplate')

    for _, button in ipairs(self.ScrollFrame.buttons) do
        ns.Auction.BrowseItem:Bind(button)
    end
end

function Browse:SetupSortButtons()
    self.sortButtons = {}

    local function OnClick(button)
        AuctionFrame_OnClickSortColumn('list', button.sortColumn)
        self:SaveSort()
    end

    local headers = {
        {text = NAME, width = 147, sortColumn = 'quality'},
        {text = REQ_LEVEL_ABBR, width = 30, sortColumn = 'level'},
        {text = 'Time', width = 60, sortColumn = 'duration'},
        {
            text = AUCTION_CREATOR,
            width = function(hasScrollBar)
                return hasScrollBar and 70 or 90
            end,
            sortColumn = 'seller',
        },
        {text = 'Bid', width = 96, sortColumn = 'bid'},
        {text = BUYOUT, width = 96, sortColumn = 'buyout'},
        {text = 'Unit price', width = 96, sortColumn = 'unitprice'},
    }

    for i, header in ipairs(headers) do
        local button = CreateFrame('Button', 'BrowseButtonSort' .. i, self.Frame, 'AuctionSortButtonTemplate')
        button.sortColumn = header.sortColumn
        button:SetHeight(19)
        button:SetText(header.text)
        button:SetScript('OnClick', OnClick)

        if i == 1 then
            button:SetPoint('TOPLEFT', AuctionFrameBrowse, 'TOPLEFT', 204, -82)
        else
            button:SetPoint('LEFT', self.sortButtons[i - 1], 'RIGHT')
        end
        if type(header.width) == 'function' then
            button.width = header.width
            button:SetWidth(header.width())
        else
            button:SetWidth(header.width)
        end
        tinsert(self.sortButtons, button)
    end
end

function Browse:SetupEventsAndHooks()
    ns.override('AuctionFrameBrowse_Update', nop)
    ns.override('AuctionFrameBrowse_UpdateArrows', function()
        return self:UpdateSortButtons()
    end)
    ns.override('AuctionFrameBrowse_Search', function()
        if self:IsAtWowToken() then
            AuctionWowToken_UpdateMarketPrice()
            BrowseWowTokenResults_Update()
        else
            self:RequestSearch()
        end
    end)

    ns.hookscript(self.SearchButton, 'OnEnable', function()
        for _, button in ipairs(self.sortButtons) do
            button:Enable()
        end
    end)
    ns.hookscript(self.SearchButton, 'OnDisable', function()
        for _, button in ipairs(self.sortButtons) do
            button:Disable()
        end
    end)

    ns.securehook('QueryAuctionItems', function()
        self.ScrollFrame.scrollBar:SetValue(0)
    end)
    ns.securehook('BrowseWowTokenResults_Update', function()
        self.Frame:SetShown(not self:IsAtWowToken())
    end)
    ns.securehook('SetSelectedAuctionItem', function(listType)
        if listType == 'list' then
            self:UpdateSelected()
            self:UpdateList()
        end
    end)

    ns.hook('ChatEdit_InsertLink', function(orig, text)
        if self.NameInput:IsVisible() and IsShiftKeyDown() then
            self.NameInput:Hide()
            local ok = orig(text)
            self.NameInput:Show()

            if not ok then
                local name, link = GetItemInfo(text)
                if link then
                    self.NameInput:SetText(link)
                    self:RequestSearch()
                    ok = true
                end
            end
            return ok
        else
            return orig(text)
        end
    end)

    ns.event('AUCTION_ITEM_LIST_UPDATE', function()
        self.isSearching = nil
        return self:UpdateAll()
    end)
    ns.event('AUCTION_HOUSE_CLOSED', function()
        self.noSearch = true
        self.NameInput:SetText('')
    end)

    self:HookScript('OnShow', self.OnShow)
    self:UnregisterAllEvents()
end

function Browse:OnShow()
    self.NameInput:SetFocus()
    self:UpdateSort()
    self:UpdateAll()
end

function Browse:BuildSearchParams()
    local params = {
        text = self.NameInput:GetText(),
        minLevel = self.MinLevelInput:GetNumber(),
        maxLevel = self.MaxLevelInput:GetNumber(),
        filters = self:GetFilters(),
        usable = self.IsUsableCheckButton:GetChecked(),
        quality = self.QualityDropDown:GetValue(),
    }

    local prevParams = self.prevSearchParams

    if (params.text ~= prevParams.text or params.minLevel ~= prevParams.minLevel or params.maxLevel ~=
        prevParams.maxLevel or params.filters ~= prevParams.filters or params.usable ~= prevParams.usable or
        params.quality ~= prevParams.quality) then

        self.searchParams = params
        self.page = 0
    end
    self.searchParams.page = self.page
end

function Browse:RequestSearch()
    self.noSearch = nil
    self.isSearching = true

    self:BuildSearchParams()
    self:UpdateList()
    self.scaner:Query(self.searchParams)
end

function Browse:SaveSort()
    self.sortColumn, self.sortReverse = GetAuctionSort('list', 1)
end

function Browse:UpdateSort()
    if self.sortColumn then
        AuctionFrame_SetSort('list', self.sortColumn, self.sortReverse)
    end
end

function Browse:IsFullScan()
    local num = GetNumAuctionItems('list')
    return num and num > NUM_AUCTION_ITEMS_PER_PAGE
end

function Browse:GetFilters()
    local categoryIndex = AuctionFrameBrowse.selectedCategoryIndex
    local subCategoryIndex = AuctionFrameBrowse.selectedSubCategoryIndex
    local subSubCategoryIndex = AuctionFrameBrowse.selectedSubSubCategoryIndex
    local filters

    if categoryIndex and subCategoryIndex and subSubCategoryIndex then
        filters = AuctionCategories[categoryIndex].subCategories[subCategoryIndex].subCategories[subSubCategoryIndex]
                      .filters
    elseif categoryIndex and subCategoryIndex then
        filters = AuctionCategories[categoryIndex].subCategories[subCategoryIndex].filters
    elseif categoryIndex then
        filters = AuctionCategories[categoryIndex].filters
    else
    end
    return filters
end

function Browse:IsAtWowToken()
    return AuctionFrame_DoesCategoryHaveFlag('WOW_TOKEN_FLAG', AuctionFrameBrowse.selectedCategoryIndex)
end

function Browse:UpdateSortButtons()
    if not self:IsVisible() then
        return
    end

    for _, button in ipairs(self.sortButtons) do
        SortButton_UpdateArrow(button, 'list', button.sortColumn)
    end
end

function Browse:UpdateList()
    if not self:IsVisible() then
        return
    end

    local scrollFrame = self.ScrollFrame
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local page = self.page

    local num, total = GetNumAuctionItems('list')
    local shouldHide = self.isSearching or self:IsFullScan() or self.noSearch
    local hasScrollBar = not shouldHide and num * BUTTON_HEIGHT > self:GetHeight()
    local buttonWidth = hasScrollBar and 608 or 630
    local totalHeight = shouldHide and 0 or num * BUTTON_HEIGHT

    if self.noSearch then
        self.NoResultsText:SetText(BROWSE_SEARCH_TEXT)
    elseif shouldHide then
        self.NoResultsText:SetText(SEARCHING_FOR_ITEMS)
    elseif num and num == 0 then
        self.NoResultsText:SetText(BROWSE_NO_RESULTS)
    else
        self.NoResultsText:SetText('')
    end

    for i, button in ipairs(scrollFrame.buttons) do
        local id = offset + i
        local index = id + NUM_AUCTION_ITEMS_PER_PAGE * page
        if shouldHide or (index > num + NUM_AUCTION_ITEMS_PER_PAGE * page) then
            button:Hide()
        else
            button:Show()
            button:Update(id)
            button:SetWidth(buttonWidth)
        end
    end
    HybridScrollFrame_Update(scrollFrame, totalHeight, self:GetHeight())
end

function Browse:UpdateSelected()
    if not self:IsVisible() then
        return
    end

    self.BidButton:Show()
    self.BuyoutButton:Show()
    self.BidButton:Disable()
    self.BuyoutButton:Disable()

    local id = GetSelectedAuctionItem('list')
    if id == 0 then
        return
    end

    local money = GetMoney()
    local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount,
          highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo =
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
            self.BuyoutButton:Enable()
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

    MoneyInputFrame_SetCopper(self.BidPrice, requiredBid)

    if not highBidder and not isMine and money >= requiredBid and requiredBid <= MAXIMUM_BID_PRICE then
        self.BidButton:Enable()
    end
end

function Browse:UpdateButtons()
    if not self:IsVisible() then
        return
    end

    local num, total = GetNumAuctionItems('list')
    local page = self.page
    if total > NUM_AUCTION_ITEMS_PER_PAGE and num <= NUM_AUCTION_ITEMS_PER_PAGE then
        self.PrevPageButton.isEnabled = page ~= 0
        self.NextPageButton.isEnabled = page ~= ceil(total / NUM_AUCTION_ITEMS_PER_PAGE) - 1

        local itemsMin = page * NUM_AUCTION_ITEMS_PER_PAGE + 1
        local itemsMax = itemsMin + num - 1
        self.SearchCountText:SetFormattedText(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax, total)
    else
        self.PrevPageButton.isEnabled = false
        self.NextPageButton.isEnabled = false
        self.SearchCountText:SetText('')
    end
end

function Browse:UpdateWidth()
    if not self:IsVisible() or self.isSearching or self:IsFullScan() then
        return
    end

    local num = GetNumAuctionItems('list')
    local hasScrollBar = num * BUTTON_HEIGHT > self:GetHeight()

    self.ScrollFrame:SetWidth(hasScrollBar and 612 or 632)

    for _, button in ipairs(self.sortButtons) do
        if button.width then
            button:SetWidth(button.width(hasScrollBar))
        end
    end
end

function Browse:UpdateAll()
    self:UpdateWidth()
    self:UpdateList()
    self:UpdateSelected()
    self:UpdateButtons()
    self:UpdateSortButtons()
end
