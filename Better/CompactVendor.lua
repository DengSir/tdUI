-- CompactVendor.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/29/2026, 9:49:24 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('CompactVendor', function()

    local items = {[263977] = true, [246751] = true, [246752] = true, [246753] = true}

    ns.hook(assert(CompactVendorFrameMerchantButtonTemplate), 'OnClick', function(orig, self, button)
        if button == 'LeftButton' and IsAltKeyDown() then
            local item = self.merchantItem
            if items[item.itemID] then
                local id = item.index
                local count = math.huge
                for i = 1, GetMerchantItemCostInfo(id) do
                    local icon, cost, link = GetMerchantItemCostItem(id, i)
                    local info = C_CurrencyInfo.GetCurrencyInfoFromLink(link)
                    count = math.min(count, math.floor(info.quantity / cost))
                end

                BuyMerchantItem(id, count)
            end
        else
            return orig(self, button)
        end
    end)
end)
