---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_TrainerUI', function()
    local button = CreateFrame('Button', nil, ClassTrainerFrame, 'UIPanelButtonTemplate')
    button:SetAllPoints(ClassTrainerCancelButton)
    button:SetText('全部训练')
    button:Show()
    button:SetScript('OnClick', function()
        for i = GetNumTrainerServices(), 1, -1 do
            local _, _, serviceType = GetTrainerServiceInfo(i)
            if serviceType == 'available' then
                ClassTrainer_SetSelection(i)
                if GetTrainerServiceCost(i) <= GetMoney() then
                    BuyTrainerService(i)
                end
            end
        end
        ClassTrainerFrame_Update()
    end)

    ClassTrainerCancelButton:Hide()
end)
