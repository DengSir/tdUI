-- WorldMap.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/9/2020, 12:32:21 PM

WorldMapFrame:HookScript('OnShow', UpdateMicroButtons)
WorldMapFrame:HookScript('OnHide', UpdateMicroButtons)

-- UIErrorsFrame:SetPoint('TOP', 0, -302)

-- print(Recount_MainWindow)

-- local window = Recount_MainWindow

-- window:SetBackdrop{
--     bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
--     tile = true,
--     insets = {left = 0, right = 0, top = 12, bottom = 0},
-- }

-- C_Timer.After(1, function()
--     Recount.SaveMainWindowPosition = nop
--     Recount.RestoreMainWindowPosition = nop

--     window:SetParent(ChatFrame6)
--     window:ClearAllPoints()
--     window:SetPoint('TOPLEFT', ChatFrame1, 'TOPLEFT', 0, 12)
--     window:SetPoint('BOTTOMRIGHT', ChatFrame1, 'BOTTOMRIGHT', 0, -5)

--     Recount.Colors:UpdateAllColors()
-- end)

local emu = _G.__ala_meta__ and _G.__ala_meta__.emu
if emu then
    local orgCreateMainFrame = emu.CreateMainFrame

    emu.CreateMainFrame = function()
        local mainFrame = orgCreateMainFrame()

        local equipmentButton = mainFrame.objects.equipmentButton

        equipmentButton:HookScript('OnShow', function()
            C_Timer.After(0, function()
                emu.Emu_ToggleEquipmentFrame(mainFrame)
            end)
        end)

        return mainFrame
    end
end
