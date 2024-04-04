---@type ns
local ns = select(2, ...)

local IsEngravingEnabled = C_Engraving and C_Engraving.IsEngravingEnabled

if IsEngravingEnabled and IsEngravingEnabled() then
    ns.addon('Blizzard_EngravingUI', function()
        local IsRuneEquipped = C_Engraving and C_Engraving.IsRuneEquipped
        ns.securehook('EngravingFrame_UpdateRuneList', function(frame)
            for _, button in ipairs(frame.scrollFrame.buttons) do
                button.selectedTex:SetShown(button.skillLineAbilityID and IsRuneEquipped(button.skillLineAbilityID))
            end
        end)
    end)
    ns.event('RUNE_UPDATED', function()
        local EngravingFrame = _G['EngravingFrame']
        local EngravingFrame_UpdateRuneList = _G['EngravingFrame_UpdateRuneList']
        if EngravingFrame and EngravingFrame:IsVisible() then
            EngravingFrame_UpdateRuneList(EngravingFrame)
        end
    end)
end
