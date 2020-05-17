-- Modal.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/18/2020, 1:04:14 AM

---@type ns
local ns = select(2, ...)
local Inspect = ns.Inspect

ns.addon('Blizzard_InspectUI', function()
    -- local ModalFrame = CreateFrame('Frame', nil, InspectPaperDollFrame)
    -- ModalFrame:SetPoint('TOPLEFT', 65, -76)
    -- ModalFrame:SetPoint('BOTTOMRIGHT', -85, 115)

    local ModalFrame = Inspect:CreateTab('Modal', 135005)

    InspectFaction:SetPoint('CENTER', InspectPaperDollFrame, 'CENTER', -10, 20)

    InspectModelFrame:SetParent(ModalFrame)
    InspectFaction:SetParent(ModalFrame)

    local factionLogoTextures = {
        ['Alliance'] = 'Interface\\Timer\\Alliance-Logo',
        ['Horde'] = 'Interface\\Timer\\Horde-Logo',
        ['Neutral'] = 'Interface\\Timer\\Panda-Logo',
    }

    local function UpdateModal()
        local unit = Inspect:GetUnit()
        if unit then
            InspectModelFrame:Show()

            if InspectModelFrame:SetUnit(unit) then
                InspectModelFrame:Show()
                InspectFaction:Hide()
                return
            end
        end

        InspectModelFrame:Hide()
        InspectFaction:SetTexture(factionLogoTextures[UnitFactionGroup(unit or 'player')])
        InspectFaction:Show()
    end

    ModalFrame:SetScript('OnShow', UpdateModal)
end)
