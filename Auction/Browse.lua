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

---@type tdUIAuctionBrowse
local Browse = ns.class('ScrollFrame')
ns.Auction.Browse = Browse

function Browse:Constructor()
    self:SetupBlizzard()
    self:SetupScrollFrame()
    self:SetupSortButtons()
    self:SetupEventsAndHooks()
end

function Browse:SetupBlizzard()
    if not BrowseResetButton then
        local button = CreateFrame('Button', 'BrowseResetButton', AuctionFrameBrowse, 'UIPanelButtonTemplate')
        button:SetText(RESET)
        button:SetSize(80, 22)
        button:SetPoint('TOPRIGHT', 67, -35)
        button:SetScript('OnClick', AuctionFrameBrowse_Reset)
        button:SetScript('OnUpdate', BrowseResetButton_OnUpdate)
    end

    if not ExactMatchCheckButton then
        local button = CreateFrame('CheckButton', 'ExactMatchCheckButton', AuctionFrameBrowse, 'UICheckButtonTemplate')
        button:SetSize(24, 24)
        button:SetPoint('TOPLEFT', 25, -75)
        ExactMatchCheckButtonText:SetFontObject(GameFontHighlightSmall)
        ExactMatchCheckButtonText:SetText(AH_EXACT_MATCH)
    end

    self.SearchButton = BrowseSearchButton
    self.ResetButton = BrowseResetButton
    self.PrevPageButton = BrowsePrevPageButton
    self.NextPageButton = BrowseNextPageButton
    self.NoResultsText = BrowseNoResultsText
    self.SearchCountText = BrowseSearchCountText
    self.BidPrice = BrowseBidPrice
    self.BidButton = BrowseBidButton
    self.BuyoutButton = BrowseBuyoutButton

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

    BrowseName:SetWidth(240)

    point(self.SearchButton, 'TOPRIGHT', BrowseResetButton, 'TOPLEFT', -5, 0)
    point(self.PrevPageButton, 'TOPLEFT', 658, -53)
    point(self.NextPageButton, 'TOPRIGHT', 70, -53)
    point(self.SearchCountText, 'BOTTOMLEFT', 190, 17)
    point(self.BidPrice, 'BOTTOM', 115, 18)

    point(BrowseLevelText, 'TOPLEFT', 330, -38)
    point(BrowseDropDownName, 'TOPLEFT', AuctionFrameBrowse, 400, -38)
    point(BrowseName, 'TOPLEFT', BrowseNameText, 'BOTTOMLEFT', 3, -3)
    point(BrowseDropDown, 'TOPLEFT', BrowseDropDownName, 'BOTTOMLEFT', -18, 3)
    point(IsUsableCheckButton, 'TOPLEFT',  530, -38)
    point(ShowOnPlayerCheckButton, 'TOPLEFT', IsUsableCheckButton, 'BOTTOMLEFT', 0, 2)

    self.SearchButton:SetParent(self)
    self.ResetButton:SetParent(self)

    local function parent(obj)
        obj:SetParent(self)
        obj:Show()
        obj.Hide = nop
    end

    parent(self.PrevPageButton)
    parent(self.NextPageButton)
    parent(self.SearchCountText)

    do
        local BrowseDropDown = BrowseDropDown

        local function OnClick(_, value)
            UIDropDownMenu_SetSelectedValue(BrowseDropDown, value)
        end

        local function Checked(button)
            return UIDropDownMenu_GetSelectedValue(BrowseDropDown) == button.arg1
        end

        local menuList = {}
        do
            tinsert(menuList, {text = ALL, arg1 = -1, func = OnClick, checked = Checked})

            for i = Enum.ItemQuality.Poor, Enum.ItemQuality.Epic do
                local r, g, b = GetItemQualityColor(i)
                tinsert(menuList, {
                    text = _G['ITEM_QUALITY' .. i .. '_DESC'],
                    colorCode = format('|cff%02x%02x%02x', r * 255, g * 255, b * 255),
                    arg1 = i,
                    func = OnClick,
                    checked = Checked,
                })
            end
        end

        BrowseDropDown:SetScript('OnShow', nil)
        UIDropDownMenu_Initialize(BrowseDropDown, function(self, level)
            for _, info in ipairs(menuList) do
                UIDropDownMenu_AddButton(info, level)
            end
        end, nil, nil, menuList)
        UIDropDownMenu_SetSelectedValue(BrowseDropDown, -1)
    end
end

function Browse:SetupScrollFrame()
    self.update = self.UpdateList
    HybridScrollFrame_CreateButtons(self, 'tdUIAuctionBrowseItemTemplate')

    for _, button in ipairs(self.buttons) do
        ns.Auction.BrowseItem:Bind(button)
    end
end

function Browse:SetupSortButtons()
    self.sortButtons = {}

    local function SortOnClick(button)
        return AuctionFrame_OnClickSortColumn('list', button.sortColumn)
    end

    local headers = {
        {text = NAME, width = 152, sortColumn = 'quality'},
        {text = REQ_LEVEL_ABBR, width = 30, sortColumn = 'level'},
        {text = 'Time', width = 70, sortColumn = 'duration'},
        {text = AUCTION_CREATOR, width = 70, sortColumn = 'seller'},
        {text = 'Bid', width = 96, sortColumn = 'bid'},
        {text = BUYOUT, width = 96, sortColumn = 'buyout'},
        {text = 'Unit price', width = 96, sortColumn = 'unitprice'},
    }

    local x = 204
    for i, header in ipairs(headers) do
        local button = CreateFrame('Button', 'BrowseButtonSort' .. i, self, 'AuctionSortButtonTemplate')
        button.sortColumn = header.sortColumn
        button:SetHeight(19)
        button:SetWidth(header.width)
        button:SetText(header.text)
        button:SetScript('OnClick', SortOnClick)
        button:SetPoint('TOPLEFT', AuctionFrameBrowse, 'TOPLEFT', x, -82)
        tinsert(self.sortButtons, button)

        x = x + header.width
    end
end

function Browse:SetupEventsAndHooks()
    ns.override('AuctionFrameBrowse_Update', nop)
    ns.override('AuctionFrameBrowse_UpdateArrows', function()
        return self:UpdateSortButtons()
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
        self.scrollBar:SetValue(0)
    end)
    ns.securehook('BrowseWowTokenResults_Update', function()
        if not AuctionFrame_DoesCategoryHaveFlag('WOW_TOKEN_FLAG', AuctionFrameBrowse.selectedCategoryIndex) then
            self:Show()
        else
            self:Hide()
        end
    end)
    ns.securehook('SetSelectedAuctionItem', function(listType)
        if listType == 'list' then
            self:UpdateSelected()
            self:UpdateList()
        end
    end)

    ns.event('AUCTION_ITEM_LIST_UPDATE', function()
        return self:UpdateAll()
    end)

    ns.hookscript(BrowseResetButton, 'OnClick', function()
        self.NoResultsText:SetShown(GetNumAuctionItems('list') == 0)
        BrowseDropDownText:SetText(ALL)
    end)

    ns.hook('QueryAuctionItems',
            function(orig, text, minLevel, maxLevel, page, usable, rarity, a1, exactMatch, filterData)
        return orig(text, minLevel, maxLevel, page, usable, rarity, a1, ExactMatchCheckButton:GetChecked(), filterData)
    end)

    self:SetScript('OnShow', self.UpdateAll)
end

function Browse:UpdateSortButtons()
    for _, button in ipairs(self.sortButtons) do
        SortButton_UpdateArrow(button, 'list', button.sortColumn)
    end
end

function Browse:UpdateList()
    if not self:IsVisible() then
        return
    end

    local offset = HybridScrollFrame_GetOffset(self)
    local page = AuctionFrameBrowse.page
    local numBatchAuctions, totalAuctions = GetNumAuctionItems('list')
    local hasScrollBar = numBatchAuctions * 18 > self:GetHeight()
    local buttonWidth = hasScrollBar and 608 or 630

    self:SetWidth(hasScrollBar and 612 or 632)
    self.NoResultsText:SetShown(numBatchAuctions == 0)

    for i, button in ipairs(self.buttons) do
        local id = offset + i
        local index = id + NUM_AUCTION_ITEMS_PER_PAGE * page
        local shouldHide = index > numBatchAuctions + NUM_AUCTION_ITEMS_PER_PAGE * page
        if shouldHide then
            button:Hide()
        else
            button:Show()
            button:Update(id)
            button:SetWidth(buttonWidth)
        end
    end
    HybridScrollFrame_Update(self, numBatchAuctions * 18, self:GetHeight())
end

function Browse:UpdateSelected()
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

    if not highBidder and not isMine and money >= MoneyInputFrame_GetCopper(self.BidPrice) and
        MoneyInputFrame_GetCopper(self.BidPrice) <= MAXIMUM_BID_PRICE then
        self.BidButton:Enable()
    end
end

function Browse:UpdateButtons()
    local numBatchAuctions, totalAuctions = GetNumAuctionItems('list')
    local page = AuctionFrameBrowse.page
    if totalAuctions > NUM_AUCTION_ITEMS_PER_PAGE then
        self.PrevPageButton.isEnabled = page ~= 0
        self.NextPageButton.isEnabled = page ~= ceil(totalAuctions / NUM_AUCTION_ITEMS_PER_PAGE) - 1

        local itemsMin = page * NUM_AUCTION_ITEMS_PER_PAGE + 1
        local itemsMax = itemsMin + numBatchAuctions - 1
        self.SearchCountText:SetFormattedText(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax, totalAuctions)
    else
        self.PrevPageButton.isEnabled = false
        self.NextPageButton.isEnabled = false
        self.SearchCountText:SetText('')
    end
end

function Browse:UpdateAll()
    self:UpdateList()
    self:UpdateSelected()
    self:UpdateButtons()
    self:UpdateSortButtons()
end
