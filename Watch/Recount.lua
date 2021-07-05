-- Recount.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/27/2020, 11:48:52 PM
--
---@type ns
local ns = select(2, ...)

ns.addonlogin('Recount', function()
    local pairs = pairs

    local Recount = Recount

    local Window = Recount.MainWindow
    if not Window then
        return
    end

    ns.WatchManager:Register(Window, 2, { --
        header = Window.TitleClick,
        minimizeButton = Window.CloseButton,
        marginLeft = 5,
        marginRight = 10,
        marginBottom = 5,
    })

    local LSM = LibStub('LibSharedMedia-3.0')
    local L = LibStub('AceLocale-3.0'):GetLocale('Recount')
    local C = ns.profile.watch

    local MinimizeFrame = CreateFrame('Frame', nil, UIParent)
    do
        MinimizeFrame:SetSize(C.frame.width, 30)
        MinimizeFrame:SetPoint('CENTER')

        local Button = CreateFrame('Button', nil, MinimizeFrame)
        ns.WatchManager:Register(MinimizeFrame, 1, { --
            minimizeButton = Button,
        })

        Button:Fold()

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

    do -- options
        Recount.db.profile.Font = nil
        Recount.db.profile.MainWindow.ShowScrollbar = false
        Recount:HideScrollbarElements('Recount_MainWindow_ScrollBar')

        Recount_MainWindow_ScrollBar:ClearAllPoints()
        Recount_MainWindow_ScrollBar:SetAllPoints(Window.Center)
        Recount_MainWindow_ScrollBar.SetPoint = nop
        -- ns.hide(Recount_MainWindow_ScrollBar)
    end

    do -- remove options
        Recount_Config_Fonts_Scrollbar:GetParent():Hide()
        Recount_Config_StatusBar_Scrollbar:GetParent():Hide()
        Recount_ConfigWindow_RowHeight_Slider:Hide()
        Recount_ConfigWindow_RowSpacing_Slider:Hide()

        local function HideColor(frame, branch, name)
            for _, frame in ipairs {frame:GetChildren()} do
                if frame.Rows then
                    for _, row in pairs(frame.Rows) do
                        if row.Branch == branch and row.Name == name then
                            row:Hide()
                            break
                        end
                    end
                end
            end
        end

        local function HideChild(frame, key)
            for _, frame in ipairs {frame:GetChildren()} do
                if frame[key] then
                    frame[key]:Hide()
                    break
                end
            end
        end

        HideColor(Recount_ConfigWindow.ColorOpt, 'Bar', 'Bar Text')
        HideColor(Recount_ConfigWindow.ColorOpt, 'Window', 'Title')
        HideColor(Recount_ConfigWindow.ColorOpt, 'Window', 'Background')
        HideColor(Recount_ConfigWindow.ColorOpt, 'Window', 'Title Text')

        HideChild(Recount_ConfigWindow.ColorOpt, 'MainWindowTitle')
        HideChild(Recount_ConfigWindow.Appearance, 'BarTextColorSwap')
        HideChild(Recount_ConfigWindow.Window, 'ShowSB')
    end

    do
        local function UpdateFont(fontString)
            fontString:origSetFont(LSM:Fetch('font', C.font.name), C.font.size, C.font.style)
            fontString:origSetTextColor(C.font.color.r, C.font.color.g, C.font.color.b, C.font.color.a)
        end

        local function SetBarTexture(row, texture)
            texture = texture or LSM:Fetch(LSM.MediaType.STATUSBAR, C.bar.texture)
            row.StatusBar:SetStatusBarTexture(texture)
            row.bg:SetTexture(texture)
        end

        local function UpdateBarFont()
            for _, row in pairs(Window.Rows) do
                UpdateFont(row.LeftText)
                UpdateFont(row.RightText)
            end
        end

        local function UpdateBarTexture()
            local texture = LSM:Fetch(LSM.MediaType.STATUSBAR, C.bar.texture)
            for _, row in pairs(Window.Rows) do
                SetBarTexture(row, texture)
            end
        end

        local function UpdateBarSize()
            local offs = Recount.db.profile.MainWindow.HideTotalBar and 0 or 1

            for k, row in pairs(Window.Rows) do
                row.StatusBar:SetHeight(min(C.bar.inlineHeight, C.bar.height))
                row:SetHeight(C.bar.height)
                row:SetPoint('TOPLEFT', Window, 'TOPLEFT', 2, -32 - (C.bar.height + C.bar.spacing) * (k - 1 + offs))
            end
        end

        local function UpdateConfig()
            local profile = Recount.db.profile

            profile.MainWindow.RowHeight = C.bar.height
            profile.MainWindow.RowSpacing = C.bar.spacing
            profile.BarTexture = C.bar.texture
        end

        local function UpdateBarIcon()
            for _, row in pairs(Window.Rows) do
                if row:IsVisible() then
                    local class = row.TooltipData and row.TooltipData.enClass
                    if class then
                        row.icon:SetTexture([[Interface\Glues\CharacterCreate\ui-charactercreate-classes]])
                        row.icon:SetTexCoord(ns.CropClassCoords(class))
                    else
                        row.icon:SetTexture([[Interface\Icons\ability_dualwield]])
                        row.icon:SetTexCoord(0, 1, 0, 1)
                    end
                end
            end
        end

        local function HookFontString(fontString)
            fontString.origSetFont = fontString.SetFont
            fontString.origSetTextColor = fontString.SetTextColor
            fontString.SetFont = nop
            fontString.SetTextColor = nop
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
            row.StatusBar:SetHeight(min(C.bar.inlineHeight, C.bar.height))

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

            SetBarTexture(row)
            RowOnSizeChanged(row, row:GetSize())
        end

        local function LockWindow()
            Window.isLocked = true
            Window:EnableMouse(false)
            Window.DragBottomRight:Hide()
            Window.DragBottomLeft:Hide()
        end

        local function ScaleWindow()
            Window:SetScale(1)
            ns.WatchManager:Refresh()
        end

        local WIDTH, HEIGHT
        local function UpdateWindowSize()
            local offs = Recount.db.profile.MainWindow.HideTotalBar and 0 or 1
            local lines = min(C.Recount.maxLines, #Window.DispTableSorted + (offs))

            local width = C.frame.width - 15
            local height = (C.bar.height + C.bar.spacing) * lines + 33

            if height ~= HEIGHT or width ~= WIDTH then
                WIDTH = width
                HEIGHT = height

                Window:SetSize(width, height)
                Recount:ResizeMainWindow()
            end
        end

        for _, v in pairs(Window.Rows) do
            SetupRow(nil, v)
        end

        do -- title
            Window.Title:ClearAllPoints()
            Window.Title:SetPoint('LEFT', Window.TitleClick)
            Window.Title:SetParent(Window.TitleClick)
            Window.Title:SetFont(GameFontNormal:GetFont())
            Window.Title:SetTextColor(1, 0.82, 0)
            Window.Title.SetFont = nop
            Window.Title.SetTextColor = nop

            Window.TitleClick:SetSize(100, 15)
        end

        Window:SetBackdrop(nil)
        Window.SavePosition = nop
        Recount.RestoreMainWindowPosition = UpdateWindowSize

        LockWindow()
        ScaleWindow()

        ns.securehook(Recount, 'SetupBar', SetupRow)
        ns.securehook(Recount, 'LockWindows', LockWindow)
        ns.securehook(Recount, 'ScaleWindows', ScaleWindow)
        ns.securehook(Recount, 'BarsChanged', UpdateWindowSize)
        ns.override(Recount, 'UpdateBarTextures', UpdateBarTexture)
        ns.override(Recount, 'SetBarTextures', UpdateBarTexture)
        ns.hook(Recount, 'RefreshMainWindow', function(orig, ...)
            if Window:IsVisible() then
                orig(...)
                UpdateBarIcon()
                UpdateWindowSize()
            end
        end)
        ns.securehook(Recount, 'ResetPositionAllWindows', function()
            ns.WatchManager:Refresh()
        end)

        local DropMenu = CreateFrame('Frame', 'tdUIDropMenu', UIParent, 'UIDropDownMenuTemplate')
        DropMenu.displayMode = 'MENU'
        DropMenu.initialize = EasyMenu_Initialize

        local function OpenMenu(frame, menuList, point, relativePoint)
            local isOpened = DropDownList1:IsShown() and UIDROPDOWNMENU_OPEN_MENU == DropMenu and DropMenu.relativeTo ==
                                 frame
            CloseDropDownMenus()

            if not isOpened then
                DropMenu.point = point or 'TOPRIGHT'
                DropMenu.relativePoint = relativePoint or 'TOPLEFT'
                DropMenu.relativeTo = frame

                if type(menuList) == 'function' then
                    DropMenu.initialize = menuList
                    ToggleDropDownMenu(1, nil, DropMenu, frame, 0, 0)
                else
                    DropMenu.initialize = EasyMenu_Initialize
                    ToggleDropDownMenu(1, nil, DropMenu, frame, 0, 0, menuList)
                end
            end
        end

        local function CreateModeDropDown()
            for k, v in pairs(Recount.MainWindowData) do
                UIDropDownMenu_AddButton {
                    text = v[1],
                    checked = Recount.db.profile.MainWindowMode == k,
                    func = function()
                        Recount:SetMainWindowMode(k)
                    end,
                }
            end
        end

        local function SetFight(set, name)
            Recount.db.profile.CurDataSet = set
            Recount.MainWindow.DispTableSorted = {}
            Recount.MainWindow.DispTableLookup = {}
            Recount.FightName = name
            Recount:RefreshMainWindow()
            if RecountDeathTrack then
                RecountDeathTrack:SetFight(Recount.db.profile.CurDataSet)
            end
        end

        local function CreateFightDropDown()
            local current = Recount.db.profile.CurDataSet

            UIDropDownMenu_AddButton {
                text = L['Overall Data'],
                checked = current == 'OverallData',
                func = function()
                    SetFight('OverallData', 'Overall Data')
                end,
            }

            UIDropDownMenu_AddButton {
                text = L['Current Fight'],
                checked = current == 'CurrentFightData' or current == 'LastFightData',
                func = function()
                    SetFight(Recount.InCombat and 'CurrentFightData' or 'LastFightData', 'Current Fight')
                end,
            }

            for k, v in pairs(Recount.db2.FoughtWho) do
                UIDropDownMenu_AddButton {
                    text = L['Fight'] .. ' ' .. k .. ' - ' .. v,
                    checked = current == 'Fight' .. k,
                    func = function()
                        SetFight('Fight' .. k, v)
                    end,
                }
            end
        end

        ns.override(Recount, 'OpenBarDropDown', function(_, frame)
            return OpenMenu(frame, Recount.CreateBarDropdown)
        end)

        ns.override(Recount, 'OpenModeDropDown', function(_, frame)
            return OpenMenu(frame, CreateModeDropDown)
        end)

        ns.override(Recount, 'OpenFightDropDown', function(_, frame)
            return OpenMenu(frame, CreateFightDropDown)
        end)

        local function UpdateLayout()
            UpdateConfig()
            UpdateBarSize()
            UpdateWindowSize()
        end

        ns.config('watch.frame.width', UpdateLayout)
        ns.config('watch.bar.height', UpdateLayout)
        ns.config('watch.bar.inlineHeight', UpdateLayout)
        ns.config('watch.bar.spacing', UpdateLayout)
        ns.config('watch.font.name', UpdateBarFont)
        ns.config('watch.font.size', UpdateBarFont)
        ns.config('watch.font.style', UpdateBarFont)
        ns.config('watch.font.color', UpdateBarFont)
        ns.config('watch.Recount.maxLines', UpdateLayout)
        ns.config('watch.bar.texture', function()
            UpdateConfig()
            UpdateBarTexture()
        end)

        UpdateLayout()
    end
end)
