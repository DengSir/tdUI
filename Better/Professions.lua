-- Professions.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/4/2026, 2:38:04 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_Professions', function()

    local function ProcessPage(page)
        local SchematicForm = page.SchematicForm
        local AllocateBestQualityCheckbox = SchematicForm.AllocateBestQualityCheckbox

        local width = AllocateBestQualityCheckbox:GetWidth() + AllocateBestQualityCheckbox.Text:GetWidth()

        AllocateBestQualityCheckbox:ClearAllPoints()
        AllocateBestQualityCheckbox:SetPoint('TOP', SchematicForm.Details, 'BOTTOM', -width / 2, 0)
    end

    ProcessPage(ProfessionsFrame.CraftingPage)
    ProcessPage(ProfessionsFrame.OrdersPage.OrderView.OrderDetails)
end)

ns.addon('Auctionator', function()
    ns.securehook(Auctionator.CraftingInfo, 'InitializeProfessionsFrame', function()
        AuctionatorCraftingInfoProfessionsFrame.Total:SetFontObject('GameFontNormalSmall')
        AuctionatorCraftingInfoProfessionsOrderFrame.Total:SetFontObject('GameFontNormalSmall')
    end)
end)
