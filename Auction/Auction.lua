-- Auction.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/24/2020, 1:28:23 PM
--
---@type ns
local ns = select(2, ...)

ns.Auction = {}

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

    AuctionFrame_SetSort('list', 'unitprice')

    local FullScanFrame = CreateFrame('Frame', nil, AuctionFrame, 'tdUIAuctionFullScanFrame')
    local BrowseFrame = CreateFrame('ScrollFrame', nil, AuctionFrameBrowse, 'tdUIAuctionBrowseScrollFrameTemplate')
    local FullScanButton = CreateFrame('Button', nil, AuctionFrame, 'UIPanelButtonTemplate')

    FullScanButton:SetSize(80, 22)
    FullScanButton:SetPoint('RIGHT', AuctionFrameCloseButton, 'LEFT')
    FullScanButton:SetText('Full Scan')
    FullScanButton:SetScript('OnClick', function()
        FullScanFrame:Show()
    end)

    ns.Auction.Browse:Bind(BrowseFrame)
    ns.Auction.FullScan:Bind(FullScanFrame)
end)
