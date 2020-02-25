-- Glow.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/8/2020, 11:38:04 PM

local ns = select(2, ...)

local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemQualityColor = GetItemQualityColor

local function InitButtons(buttons)
    for _, button in ipairs(buttons) do
        button.IconBorder:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
        button.IconBorder:SetBlendMode('ADD')
        button.IconBorder:ClearAllPoints()
        button.IconBorder:SetPoint('CENTER')
        button.IconBorder:SetSize(67, 67)
        button.__tdglow = true
    end
end

hooksecurefunc('PaperDollItemSlotButton_Update', function(self)
    if not self.__tdglow then
        return
    end

    local quality = GetInventoryItemQuality('player', self:GetID())
    if quality and quality > 1 then
        local r, g, b = GetItemQualityColor(quality)
        self.IconBorder:SetVertexColor(r, g, b, 0.5)
        self.IconBorder:Show()
    else
        self.IconBorder:Hide()
    end
end)

InitButtons{
    CharacterHeadSlot, CharacterNeckSlot, CharacterShoulderSlot, CharacterBackSlot, CharacterChestSlot,
    CharacterShirtSlot, CharacterTabardSlot, CharacterWristSlot, CharacterHandsSlot, CharacterWaistSlot,
    CharacterLegsSlot, CharacterFeetSlot, CharacterFinger0Slot, CharacterFinger1Slot, CharacterTrinket0Slot,
    CharacterTrinket1Slot, CharacterMainHandSlot, CharacterSecondaryHandSlot, CharacterRangedSlot,
}

ns.WithAddon('Blizzard_InspectUI', function()
    local InspectFrame = InspectFrame

    hooksecurefunc('InspectPaperDollItemSlotButton_Update', function(self)
        if not self.__tdglow then
            return
        end

        local quality = GetInventoryItemQuality(InspectFrame.unit, self:GetID())
        if quality and quality > 1 then
            local r, g, b = GetItemQualityColor(quality)
            self.IconBorder:SetVertexColor(r, g, b, 0.5)
            self.IconBorder:Show()
        else
            self.IconBorder:Hide()
        end
    end)

    InitButtons{
        InspectHeadSlot, InspectNeckSlot, InspectShoulderSlot, InspectBackSlot, InspectChestSlot, InspectShirtSlot,
        InspectTabardSlot, InspectWristSlot, InspectHandsSlot, InspectWaistSlot, InspectLegsSlot, InspectFeetSlot,
        InspectFinger0Slot, InspectFinger1Slot, InspectTrinket0Slot, InspectTrinket1Slot, InspectMainHandSlot,
        InspectSecondaryHandSlot, InspectRangedSlot,
    }
end)
