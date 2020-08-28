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
    point(AuctionsItemButton, 'TOPLEFT', 28, -94)
    point(AuctionsDurationText, 'TOPLEFT', 28, -185)
    point(StartPrice, 'BOTTOMLEFT', 35, 181) -- 203 125
    point(BuyoutPrice, 'TOPLEFT', StartPrice, 'BOTTOMLEFT', 0, -20)
    -- point(self.Duration, 'TOPRIGHT', AuctionFrameAuctions, 'TOPLEFT', 217, -178)

    local t = AuctionsItemButton:CreateTexture(nil, 'BACKGROUND')
    t:SetSize(173, 40)
    t:SetPoint('TOPLEFT', -2, 2)
    t:SetTexture([[Interface\AuctionFrame\UI-AuctionFrame-ItemSlot]])
    t:SetTexCoord(0.15625, 0.83203125, 0.171875, 0.796875)

    point(AuctionsStackSizeMaxButton, 'LEFT', AuctionsStackSizeEntry, 'RIGHT', 0, 1)
    point(AuctionsNumStacksMaxButton, 'LEFT', AuctionsNumStacksEntry, 'RIGHT', 0, 1)
    point(AuctionsStackSizeEntry, 'TOPLEFT', 33, -153)
    point(AuctionsNumStacksEntry, 'LEFT', AuctionsStackSizeEntry, 'RIGHT', 40, 0)

    AuctionsBuyoutErrorText:Hide()
    AuctionsBuyoutErrorText = self.BuyoutError

    local function OnEnable(button)
        button.texture:SetDesaturated(false)
    end

    local function OnDisable(button)
        button.texture:SetDesaturated(true)
    end

    local function OnMouseDown(button)
        if button:IsEnabled() then
            button.texture:SetPoint('CENTER', -1, -1)
        end
    end

    local function OnMouseUp(button)
        button.texture:SetPoint('CENTER')
    end

    local function styleMaxButton(button)
        local texture = button:CreateTexture(nil, 'ARTWORK')
        texture:SetSize(12, 12)
        texture:SetPoint('CENTER')
        texture:SetTexture(519957)

        button.texture = texture
        button:SetWidth(20)
        button:SetText('')
        button:HookScript('OnEnable', OnEnable)
        button:HookScript('OnDisable', OnDisable)
        button:HookScript('OnMouseUp', OnMouseUp)
        button:HookScript('OnMouseDown', OnMouseDown)
    end

    AuctionsStackSizeEntry:Show()
    AuctionsStackSizeMaxButton:Show()
    AuctionsNumStacksEntry:Show()
    AuctionsNumStacksMaxButton:Show()
    PriceDropDown:Show()

    styleMaxButton(AuctionsStackSizeMaxButton)
    styleMaxButton(AuctionsNumStacksMaxButton)

    -- AuctionFrameAuctions.priceType = 1

    ns.event('NEW_AUCTION_UPDATE', function()
        local name, texture, count, quality, canUse, price, pricePerUnit, stackCount, totalCount, itemId =
            GetAuctionSellItemInfo()

        if not C_WowTokenPublic.IsAuctionableWowToken(itemId) then
            if totalCount > 1 then
                AuctionsItemButtonCount:SetText(totalCount)
                AuctionsItemButtonCount:Show()
                UpdateMaximumButtons()
            else
                AuctionsItemButtonCount:Hide()
            end
        end
    end)
end
