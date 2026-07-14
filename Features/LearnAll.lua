---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_TrainerUI', function()
    local button = CreateFrame('Button', nil, ClassTrainerFrame, 'UIPanelButtonTemplate')
    button:SetAllPoints(ClassTrainerCancelButton)
    button:SetText('全部训练')
    button:Show()
    button:SetScript('OnClick', function()
        while true do
            local anyLeaned = false
            for i = GetNumTrainerServices(), 1, -1 do
                local _, _, serviceType = GetTrainerServiceInfo(i)
                if serviceType == 'available' then
                    ClassTrainer_SetSelection(i)
                    if GetTrainerServiceCost(i) <= GetMoney() then
                        BuyTrainerService(i)
                        anyLeaned = true
                    end
                end
            end
            if not anyLeaned then
                break
            end
        end
        ClassTrainerFrame_Update()
    end)

    ClassTrainerCancelButton:Hide()
end)
