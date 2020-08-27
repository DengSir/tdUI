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

    local BGS = {}
    do
        local textures = {}
        local function T(key, ...)
            for i = 1, 3 do
                local val = select(i, ...)
                if val then
                    local obj = _G['AuctionFrame' .. key]
                    local texture = [[Interface\AddOns\tdUI\Media\AuctionFrame\UI-AuctionFrame-]] .. val .. '-' .. key
                    BGS[i] = BGS[i] or {}
                    BGS[i][obj] = texture

                    textures[texture] = true
                end
            end
        end

        T('TopLeft', 'Browse', 'Bid', 'Auction')
        T('Top', 'Browse', 'Auction', 'Auction')
        T('TopRight', 'Browse', 'Auction', 'Auction')
        T('BotLeft', 'Browse', 'Bid', 'Auction')
        T('Bot', 'Auction', 'Auction', 'Auction')
        T('BotRight', 'Bid', 'Bid', 'Auction')
    end

    ns.securehook('AuctionFrameTab_OnClick', function(self)
        local index = self:GetID()
        local bgs = BGS[index]
        if bgs then
            for k, v in pairs(bgs) do
                k:SetTexture(v)
            end
        end
    end)

    do
        -- Auction

        if not DurationDropDown then
            local dropdown = CreateFrame('Frame', 'DurationDropDown', AuctionFrameAuctions, 'UIDropDownMenuTemplate')
            dropdown:SetPoint('BOTTOMRIGHT', AuctionFrameAuctions, 'BOTTOMLEFT', 217, 89)
            UIDropDownMenu_SetWidth(dropdown, 80)
        end

        local t = AuctionsItemButton:CreateTexture(nil, 'BACKGROUND')
        t:SetSize(173, 40)
        t:SetPoint('TOPLEFT', -2, 2)
        t:SetTexture([[Interface\AuctionFrame\UI-AuctionFrame-ItemSlot]])
        t:SetTexCoord(0.15625, 0.83203125, 0.171875, 0.796875)

        ns.hide(AuctionsShortAuctionButton)
        ns.hide(AuctionsMediumAuctionButton)
        ns.hide(AuctionsLongAuctionButton)

        local point = ns.RePoint

        point(AuctionsItemButton, 'TOPLEFT', 30, -94)
        point(StartPrice, 'BOTTOMLEFT', 35, 170)
        point(BuyoutPrice, 'BOTTOMLEFT', 35, 125)

    end

    local FullScanFrame = CreateFrame('Frame', nil, AuctionFrame, 'tdUIAuctionFullScanFrameTemplate')
    local BrowseFrame = CreateFrame('ScrollFrame', nil, AuctionFrameBrowse, 'tdUIAuctionBrowseScrollFrameTemplate')
    local AuctionFrame = CreateFrame('Frame', nil, AuctionFrameAuctions, 'tdUIAuctionAuctionFrameTemplate')

    local FullScanButton = CreateFrame('Button', nil, AuctionFrame, 'UIPanelButtonTemplate')

    FullScanButton:SetSize(80, 22)
    FullScanButton:SetPoint('RIGHT', AuctionFrameCloseButton, 'LEFT')
    FullScanButton:SetText('Full Scan')
    FullScanButton:SetScript('OnClick', function()
        FullScanFrame:Show()
    end)

    ns.Auction.Browse:Bind(BrowseFrame)
    ns.Auction.FullScan:Bind(FullScanFrame)
    ns.Auction.Auction:Bind(AuctionFrame)
end)
