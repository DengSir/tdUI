-- Auction.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/24/2020, 1:28:23 PM
--
---@type ns
local ns = select(2, ...)

ns.Auction = {}

function ns.Auction.parseSearchText(link)
    local exact = false
    local text = link
    local itemId, _, suffixId = ns.parseItemLink(link)
    if itemId then
        local name = GetItemInfo(link)
        if name then
            exact = true
            text = name

            if suffixId ~= 0 then
                local origName = GetItemInfo(itemId)
                if origName then
                    local suffix = name:gsub(origName, ''):trim()
                    text = origName .. ' ' .. suffix
                end
            end
        end
    end
    return text, exact
end

local Tooltip
function ns.Auction.GetAuctionSellItemLink()
    if not Tooltip then
        Tooltip = CreateFrame('GameTooltip', 'tdUIAuctionSellScaner', UIParent, 'GameTooltipTemplate')
        -- Tooltip = GameTooltip
    end
    Tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
    Tooltip:SetAuctionSellItem()
    return select(2, Tooltip:GetItem())
end

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

    local FullScanButton = CreateFrame('Button', nil, AuctionFrame, 'UIPanelButtonTemplate')
    local FullScan = CreateFrame('Frame', nil, AuctionFrame, 'tdUIAuctionFullScanFrameTemplate')
    local Browse = CreateFrame('ScrollFrame', nil, AuctionFrameBrowse, 'tdUIAuctionBrowseScrollFrameTemplate')
    local Auction = CreateFrame('Frame', nil, AuctionFrameAuctions, 'tdUIAuctionAuctionFrameTemplate')

    FullScanButton:SetSize(80, 22)
    FullScanButton:SetPoint('RIGHT', AuctionFrameCloseButton, 'LEFT')
    FullScanButton:SetText('Full Scan')
    FullScanButton:SetScript('OnClick', function()
        FullScan:Show()
    end)

    ns.Auction.Browse:Bind(Browse)
    ns.Auction.FullScan:Bind(FullScan)
    ns.Auction.Auction:Bind(Auction)
end)
