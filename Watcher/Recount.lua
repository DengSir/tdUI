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

        local SM = LibStub:GetLibrary('LibSharedMedia-3.0')

        local WIDTH = 240
        local HEIGHT

        local function GetBarTexture()
            return SM:Fetch(SM.MediaType.STATUSBAR, Recount.db.profile.BarTexture)
        end

        local function UpdateFont(label)
            local font = SM:Fetch('font', Recount.db.profile.BarFont)
            label:origSetFont(font, Recount.db.profile.BarFontSize)
        end

        local function UpdateBarBackground(row, texture)
            row.bg:SetTexture(texture or GetBarTexture())
        end

        local function UpdateBarFonts()
            for _, row in pairs(Window.Rows) do
                UpdateFont(row.LeftText)
                UpdateFont(row.RightText)
            end
        end

        local function UpdateBarTextures()
            local texture = GetBarTexture()
            for _, row in pairs(Window.Rows) do
                UpdateBarBackground(row, texture)
            end
        end

        local function UpdateBarIcons()
            for _, row in pairs(Window.Rows) do
                if row:IsVisible() then
                    local class = row.TooltipData and row.TooltipData.enClass
                    if class then
                        row.icon:SetTexture([[Interface\Glues\CharacterCreate\ui-charactercreate-classes]])
                        row.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
                    else
                        row.icon:SetTexture([[Interface\Icons\ability_dualwield]])
                        row.icon:SetTexCoord(0, 1, 0, 1)
                    end
                end
            end
        end

        local function HookFontString(fontString)
            fontString.origSetFont = fontString.SetFont
            fontString.SetFont = UpdateFont
            UpdateFont(fontString)
        end

        local function RowOnSizeChanged(row, width, height)
            row.icon:SetSize(height, height)
        end

        local function SetupRow(_, row)
            row.icon = row:CreateTexture(nil, 'ARTWORK')
            row.icon:SetPoint('BOTTOMLEFT')

            row.StatusBar:ClearAllPoints()
            row.StatusBar:SetPoint('BOTTOMLEFT', row.icon, 'BOTTOMRIGHT')
            row.StatusBar:SetPoint('BOTTOMRIGHT')
            row.StatusBar:SetHeight(8)

            row.bg = row.StatusBar:CreateTexture(nil, 'BACKGROUND')
            row.bg:SetAllPoints(row.StatusBar)
            row.bg:SetHorizTile(false)
            row.bg:SetVertTile(false)
            row.bg:SetVertexColor(0, 0, 0, 0.3)

            row.LeftText:ClearAllPoints()
            row.LeftText:SetPoint('LEFT', row.icon, 'RIGHT', 0, 0)
            HookFontString(row.LeftText)

            row.RightText:ClearAllPoints()
            row.RightText:SetPoint('RIGHT', row, 'RIGHT', 0, 0)
            HookFontString(row.RightText)

            row:HookScript('OnSizeChanged', RowOnSizeChanged)

            UpdateBarBackground(row)
            RowOnSizeChanged(row, row:GetSize())
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

        for _, v in pairs(Window.Rows) do
            SetupRow(nil, v)
        end

        Window.SavePosition = nop
        Recount.RestoreMainWindowPosition = UpdateMainWindowSize

        LockMainWindow()
        ScaleMainWindow()
        -- UpdateBarTextures()
        -- UpdateBarFonts()

        ns.securehook(Recount, 'SetupBar', SetupRow)
        ns.securehook(Recount, 'BarsChanged', UpdateMainWindowSize)
        ns.securehook(Recount, 'LockWindows', LockMainWindow)
        ns.securehook(Recount, 'ScaleWindows', ScaleMainWindow)
        ns.securehook(Recount, 'UpdateBarTextures', UpdateBarTextures)
        ns.securehook(Recount, 'SetBarTextures', UpdateBarTextures)
        ns.securehook(Recount, 'RefreshMainWindow', function()
            UpdateBarIcons()
            UpdateMainWindowSize()
        end)
        ns.securehook(Recount, 'ResetPositionAllWindows', function()
            ns.WatchManager:UpdateFrames()
        end)

        do -- options
            Recount.db.profile.BarTextColorSwap = false
            Recount.db.profile.Font = nil
            Recount.db.profile.BarFontSize = 13
        end

        do
            local FontOptions = Recount_Config_Fonts_Scrollbar:GetParent()

            local slider = CreateFrame('Slider', 'Recount_ConfigWindow_BarFontSize', FontOptions,
                                       'OptionsSliderTemplate')

            slider:SetOrientation('HORIZONTAL')
            slider:SetMinMaxValues(6, 35)
            slider:SetValueStep(0.5)
            slider:SetObeyStepOnDrag(true)
            slider:SetWidth(180)
            slider:SetHeight(16)
            slider:SetPoint('TOP', FontOptions, 'TOP', 0, -220)
            slider:SetScript('OnValueChanged', function(self)
                Recount.db.profile.BarFontSize = self:GetValue()
                _G[self:GetName() .. 'Text']:SetText('Font Size' .. ': ' .. Recount.db.profile.BarFontSize)
                UpdateBarFonts()
            end)
            slider:SetScript('OnMouseWheel', function(self, delta)
                self:SetValue(self:GetValue() + (delta * self:GetValueStep()))
            end)
            _G[slider:GetName() .. 'High']:SetText('36')
            _G[slider:GetName() .. 'Low']:SetText('6')
            slider:SetValue(Recount.db.profile.BarFontSize)

            local function UpdateOptionFonts()
                for _, row in pairs(FontOptions.Rows) do
                    if row.SetTo == Recount.db.profile.BarFont then
                        row.Texture:SetVertexColor(0.2, 0.9, 0.2)
                    else
                        row.Texture:SetVertexColor(0.9, 0.2, 0.2)
                    end
                end
            end

            UpdateOptionFonts()

            function Recount:SetFont(fontname)
                Recount.db.profile.BarFont = fontname
                UpdateBarFonts()
            end

            for _, row in ipairs(FontOptions.Rows) do
                row:HookScript('OnMouseDown', UpdateOptionFonts)
            end

            Recount_Config_Fonts_Scrollbar:HookScript('OnVerticalScroll', UpdateOptionFonts)
        end

        do -- title
            local bg = Window.TitleClick:CreateTexture(nil, 'BACKGROUND')
            bg:SetAtlas('Objective-Header', true)
            bg:SetPoint('TOPLEFT', -25, 20)
            bg:SetWidth(255 + 40)

            Window.Title:SetPoint('TOPLEFT', -5, -10)
            Window.Title:SetParent(Window.TitleClick)
            Window.Title:SetFont(GameFontNormal:GetFont())
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
