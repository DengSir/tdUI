-- BrowseItem.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/24/2020, 12:59:33 PM
--
---@type ns
local ns = select(2, ...)

---@type tdUIAuctionBrowseItem
local BrowseItem = ns.class('Button')
ns.Auction.BrowseItem = BrowseItem

local NONE = GRAY_FONT_COLOR:WrapTextInColorCode(NONE)
local DURATION_TEXT = { --
    [1] = RED_FONT_COLOR:WrapTextInColorCode('< 30m'),
    [2] = YELLOW_FONT_COLOR:WrapTextInColorCode('30m-2h'),
    [3] = GREEN_FONT_COLOR:WrapTextInColorCode('2-8h'),
    [4] = GRAY_FONT_COLOR:WrapTextInColorCode('> 8h'),
}

function BrowseItem:Constructor()
    self:SetScript('OnClick', self.OnClick)
end

function BrowseItem:OnClick()
    local link = GetAuctionItemLink('list', self.id)
    if IsModifiedClick() then
        HandleModifiedItemClick(link)
    else
        if GetCVarBool('auctionDisplayOnCharacter') then
            DressUpLink(link)
        end

        SetSelectedAuctionItem('list', self.id)
        CloseAuctionStaticPopups()
    end
end

function BrowseItem:Update(id)
    local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount,
          highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo =
        GetAuctionItemInfo('list', id)
    local duration = GetAuctionItemTimeLeft('list', id)
    local selectedId = GetSelectedAuctionItem('list')

    self.id = id
    self:SetID(id)

    self.Bg:SetShown(id % 2 == 1)
    self.Selected:SetShown(selectedId == id)

    if count > 1 then
        self.Name:SetText(format('|cffffd100%dx|r%s', count, name))
    else
        self.Name:SetText(name)
    end
    self.Name:SetTextColor(ns.rgb(GetItemQualityColor(quality)))

    self.Icon:SetTexture(texture)
    if canUse then
        self.Icon:SetVertexColor(1, 1, 1)
    else
        self.Icon:SetVertexColor(1, 0, 0)
    end

    self.Level:SetText(level)
    if UnitLevel('player') >= level then
        self.Level:SetTextColor(1, 1, 1)
    else
        self.Level:SetTextColor(1, 0, 0)
    end

    self.Time:SetText(DURATION_TEXT[duration])
    self.Seller:SetText(owner)

    local bid = ns.gsc(bidAmount == 0 and minBid or bidAmount)

    self.Bid:SetText(bid)

    if highBidder then
        self.Bid:SetTextColor(0, 1, 0)
    elseif bidAmount ~= 0 then
        self.Bid:SetTextColor(1, 0, 0)
    else
        self.Bid:SetTextColor(1, 1, 1)
    end

    if buyoutPrice == 0 then
        self.Buyout:SetText(NONE)
        self.UnitPrice:SetText(NONE)
    else
        self.Buyout:SetText(ns.gsc(buyoutPrice))
        self.UnitPrice:SetText(ns.gsc(buyoutPrice / count))
    end
end