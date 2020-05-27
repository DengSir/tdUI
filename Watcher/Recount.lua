-- Recount.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/27/2020, 11:48:52 PM

---@type ns
local ns = select(2, ...)

ns.addon('Recount', function()
    local Window = Recount.MainWindow

    local MinimizeFrame = CreateFrame('Frame', nil, UIParent)
    do
        MinimizeFrame:SetSize(255, 30)
        MinimizeFrame:SetPoint('CENTER')

        local Button = CreateFrame('Button', nil, MinimizeFrame)
        Button:SetSize(16, 16)
        Button:SetPoint('TOPRIGHT', -8, -8)
        Button:SetNormalTexture([[Interface\Buttons\UI-Panel-QuestHideButton]])
        Button:SetPushedTexture([[Interface\Buttons\UI-Panel-QuestHideButton]])
        Button:SetHighlightTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]], 'ADD')
        Button:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)
        Button:GetPushedTexture():SetTexCoord(0.5, 1, 0, 0.5)

        local Label = Button:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        Label:SetPoint('RIGHT', Button, 'LEFT', -5, 0)
        Label:SetText('Recount')

        Button:SetScript('OnClick', function()
            Window:Show()
            Recount:RefreshMainWindow()
        end)

        Window:HookScript('OnShow', function()
            MinimizeFrame:Hide()
        end)
        Window:HookScript('OnHide', function()
            MinimizeFrame:Show()
        end)

        if Window:IsVisible() then
            MinimizeFrame:Hide()
        end
    end

    do
        Window:SetBackdrop(nil)

        local WIDTH = 240
        local HEIGHT

        local function SetFont(fontString, font, size, outline)
            fontString:origSetFont(font, 15) -- , 'OUTLINE')
        end

        local function HookFontString(fontString)
            fontString.origSetFont = fontString.SetFont
            fontString.SetFont = SetFont
            SetFont(fontString, fontString:GetFont())
        end

        local function SetupRow(_, row)
            row.StatusBar:ClearAllPoints()
            row.StatusBar:SetPoint('BOTTOMLEFT')
            row.StatusBar:SetPoint('BOTTOMRIGHT')
            row.StatusBar:SetHeight(3)

            row.LeftText:ClearAllPoints()
            row.LeftText:SetPoint('BOTTOMLEFT', row.StatusBar, 'TOPLEFT')
            HookFontString(row.LeftText)

            row.RightText:ClearAllPoints()
            row.RightText:SetPoint('BOTTOMRIGHT', row.StatusBar, 'TOPRIGHT')
            HookFontString(row.RightText)

            row.StatusBar.origSetStatusBarColor = row.StatusBar.SetStatusBarColor
            row.StatusBar.SetStatusBarColor = function(self, r, g, b)
                self:origSetStatusBarColor(r, g, b)
                row.LeftText:origSetTextColor(r, g, b)
            end
            row.StatusBar.SetVertexColor = row.StatusBar.SetStatusBarColor

            row.LeftText.origSetTextColor = row.LeftText.SetTextColor
            row.LeftText.SetTextColor = nop
        end

        local function LockMainWindow()
            Window.isLocked = true
            Window:EnableMouse(false)
            Window.DragBottomRight:Hide()
            Window.DragBottomLeft:Hide()
        end

        local function ScaleMainWindow()
            Window:SetScale(1)
            ns.WatchManager:UpdateFrames()
        end

        local function UpdateMainWindowSize()
            local lines = min(10, #Window.DispTableSorted + (Recount.db.profile.MainWindow.HideTotalBar and 0 or 1))
            local height =
                (Recount.db.profile.MainWindow.RowHeight + Recount.db.profile.MainWindow.RowSpacing) * lines + 33

            if height ~= HEIGHT then
                HEIGHT = height
                Window:SetSize(WIDTH, height)
                Recount:ResizeMainWindow()
            end
        end

        for _, v in pairs(Recount.MainWindow.Rows) do
            SetupRow(nil, v)
        end

        Window.SavePosition = nop
        Recount.RestoreMainWindowPosition = UpdateMainWindowSize

        LockMainWindow()
        ScaleMainWindow()
        C_Timer.After(1, UpdateMainWindowSize)

        ns.securehook(Recount, 'SetupBar', SetupRow)
        ns.securehook(Recount, 'BarsChanged', UpdateMainWindowSize)
        ns.securehook(Recount, 'LockWindows', LockMainWindow)
        ns.securehook(Recount, 'ScaleWindows', ScaleMainWindow)
        ns.securehook(Recount, 'ResetPositionAllWindows', function()
            ns.WatchManager:UpdateFrames()
        end)

        ns.securehook(Recount, 'RefreshMainWindow', function()
            UpdateMainWindowSize()
        end)

        do -- options
            Recount.db.profile.BarTextColorSwap = false

        end

        do -- title
            local bg = Window.TitleClick:CreateTexture(nil, 'BACKGROUND')
            bg:SetAtlas('Objective-Header', true)
            bg:SetPoint('TOPLEFT', -25, 20)
            bg:SetWidth(255 + 40)

            Window.Title:SetPoint('TOPLEFT', -5, -10)
            Window.Title:SetParent(Window.TitleClick)
            Window.Title:SetTextColor(1, 0.82, 0)
            Window.Title.SetFont = nop
            Window.Title.SetTextColor = nop

            Window.CloseButton:SetSize(16, 16)
            Window.CloseButton:SetNormalTexture([[Interface\Buttons\UI-Panel-QuestHideButton]])
            Window.CloseButton:SetPushedTexture([[Interface\Buttons\UI-Panel-QuestHideButton]])
            Window.CloseButton:SetHighlightTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]], 'ADD')
            Window.CloseButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
            Window.CloseButton:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1)
            Window.CloseButton:ClearAllPoints()
            Window.CloseButton:SetPoint('TOPRIGHT', 2, -8)
            Window.CloseButton.SetWidth = nop
        end
    end

    ns.WatchManager:Register(MinimizeFrame)
    ns.WatchManager:Register(Window, {marginRight = 10, marginBottom = 5})
end)
