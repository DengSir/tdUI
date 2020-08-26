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

    ns.securehook('AuctionFrameTab_OnClick', function(self)
        local index = self:GetID()
        if index == 1 then
            AuctionFrameTopLeft:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Browse-TopLeft]])
            AuctionFrameTop:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Browse-Top]])
            AuctionFrameTopRight:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Browse-TopRight]])
            AuctionFrameBotLeft:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Browse-BotLeft]])
            AuctionFrameBot:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Auction-Bot]])
            AuctionFrameBotRight:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Bid-BotRight]])
        elseif index == 2 then
            AuctionFrameTopLeft:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Bid-TopLeft]])
            AuctionFrameTop:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Auction-Top]])
            AuctionFrameTopRight:SetTexture(
                [[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Auction-TopRight]])
            AuctionFrameBotLeft:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Bid-BotLeft]])
            AuctionFrameBot:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Auction-Bot]])
            AuctionFrameBotRight:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Bid-BotRight]])
        else
            AuctionFrameTopLeft:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Auction-TopLeft]])
            AuctionFrameTop:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Auction-Top]])
            AuctionFrameTopRight:SetTexture(
                [[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Auction-TopRight]])
            AuctionFrameBotLeft:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Auction-BotLeft]])
            AuctionFrameBot:SetTexture([[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Auction-Bot]])
            AuctionFrameBotRight:SetTexture(
                [[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-Auction-BotRight]])
        end
    end)

    do
        -- Auction

        local t = AuctionsItemButton:CreateTexture(nil, 'BACKGROUND')
        t:SetSize(173, 40)
        t:SetPoint('TOPLEFT', -2, 2)
        t:SetTexture([[Interface\AuctionFrame\UI-AuctionFrame-ItemSlot]])
        t:SetTexCoord(0.15625, 0.83203125, 0.171875, 0.796875)

    end

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
