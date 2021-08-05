-- ThreatClassic2.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/1/2020, 1:03:21 PM
---@type ns
local ns = select(2, ...)

ns.addonlogin('ThreatClassic2', function()
    local ipairs, select = ipairs, select
    local max, min = math.max, math.min
    local tremove = table.remove

    local UnitClassBase = UnitClassBase

    ---@type Frame
    local Window = ThreatClassic2BarFrame
    if not Window then
        return
    end

    local TC2 = (function()
        local ThreatLib = LibStub('LibThreatClassic2', true)
        if ThreatLib then
            for obj in pairs(ThreatLib.callbacks.events.ThreatUpdated) do
                if obj.frame == Window then
                    return obj
                end
            end
        end

        local AceComm = LibStub('AceComm-3.0', true)
        for v in pairs(AceComm.embeds) do
            if v.commPrefix == 'TC2' then
                return v
            end
        end
    end)()
    if not TC2 then
        return
    end

    local db = (function()
        local AceDB = LibStub('AceDB-3.0', true)
        for db in pairs(AceDB.db_registry) do
            if db.sv == ThreatClassic2DB then
                return db
            end
        end
    end)()
    if not db then
        return
    end

    local LSM = LibStub('LibSharedMedia-3.0')
    local TCC = db.profile
    local C = ns.profile.watch

    ns.WatchManager:Register(Window, 3, { --
        header = Window.header,
        marginLeft = 7,
        marginRight = 12,
        marginTop = 32,
        marginBottom = 5,
    })

    do
        TCC.frame.headerShow = true
        TCC.frame.scale = 1
        TCC.frame.locked = true
        TCC.frame.color = {0, 0, 0, 0}
        TCC.frame.position = {'TOPRIGHT'}
        TCC.frame.width = 100
        TCC.frame.height = 100
        TCC.bar.count = 1

        TC2:UpdateFrame()
    end

    do -- remove options
        if TC2.menuTable then
            tremove(TC2.menuTable, 1)
        end

        local options = ns.GetAceConfig('ThreatClassic2')

        ns.RemoveAceConfig(options, 'appearance', 'frame', 'locked')
        ns.RemoveAceConfig(options, 'appearance', 'frame', 'strata')
        ns.RemoveAceConfig(options, 'appearance', 'frame', 'headerShow')
        ns.RemoveAceConfig(options, 'appearance', 'frame', 'framePosition')
        ns.RemoveAceConfig(options, 'appearance', 'frame', 'scale')
        ns.RemoveAceConfig(options, 'appearance', 'frame', 'frameColors')
        ns.RemoveAceConfig(options, 'appearance', 'bar', 'height')
        ns.RemoveAceConfig(options, 'appearance', 'bar', 'padding')
        ns.RemoveAceConfig(options, 'appearance', 'bar', 'alpha')
        ns.RemoveAceConfig(options, 'appearance', 'bar', 'texture')
        ns.RemoveAceConfig(options, 'appearance', 'font')
        ns.RemoveAceConfig(options, 'appearance', 'reset')
    end

    do
        local function Show(bar)
            return (bar.edgeBackdrop or bar.backdrop):Show()
        end

        local function Hide(bar)
            return (bar.edgeBackdrop or bar.backdrop):Hide()
        end

        local function SetupBar(bar)
            local parent = bar.edgeBackdrop or bar.backdrop
            parent:ClearAllPoints()
            parent:SetParent(bar:GetParent())
            parent:SetBackdrop(nil)
            parent:SetSize(bar:GetSize())
            parent:SetShown(bar:IsShown())

            bar.icon = parent:CreateTexture(nil, 'ARTWORK')
            bar.icon:SetPoint('BOTTOMLEFT')
            bar.icon:SetSize(1, 1)

            bar:Show()
            bar:ClearAllPoints()
            bar:SetParent(parent)
            bar:SetHeight(8)
            bar:SetPoint('BOTTOMLEFT', bar.icon, 'BOTTOMRIGHT')
            bar:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT')

            bar.name:SetPoint('LEFT', bar.icon, 'RIGHT')
            bar.perc:SetPoint('RIGHT', parent, 'RIGHT', -2, 0)

            bar.bg:SetVertexColor(0, 0, 0, 0.3)
            bar.bg.SetVertexColor = nop

            bar.Show = Show
            bar.Hide = Hide
        end

        local function SetupHeader(header)
            header:SetStatusBarTexture('')

            local backdrop = header.edgeBackdrop or header.backdrop
            if backdrop then
                backdrop:Hide()
            end

            header.text:SetFont(GameFontNormal:GetFont())
            header.text:SetTextColor(1, 0.82, 0)

            header.text:ClearAllPoints()
            header.text:SetPoint('LEFT', header, 'LEFT')

            header.SetStatusBarTexture = nop
            header.text.SetFont = nop
            header.text.SetVertexColor = nop
        end

        local function SetupWindow(window)
            window.resize:Hide()
            window.resize.Show = nop
        end

        SetupWindow(Window)
        SetupHeader(Window.header)

        for i = 1, 40 do
            SetupBar(TC2.bars[i])
        end
    end

    local function GetThreatCount()
        local count = 0
        for i, v in ipairs(TC2.threatData) do
            if v.threatValue > 0 then
                count = count + 1
            end
        end
        return count
    end

    local function UpdateSize()
        local count = TCC.bar.count
        TCC.frame.width = C.frame.width - 21
        TCC.frame.height = max(1, count * (C.bar.height + C.bar.spacing))

        Window:SetSize(TCC.frame.width + 2, TCC.frame.height)
    end

    local function UpdateFont(fontString)
        fontString:SetFont(LSM:Fetch('font', C.font.name), C.font.size, C.font.style)
        fontString:SetTextColor(C.font.color.r, C.font.color.g, C.font.color.b, C.font.color.a)
    end

    local function getBackdrop(bar)
        return bar.edgeBackdrop or bar.backdrop
    end

    local function UpdateBars()
        for i = 1, 40 do
            local bar = TC2.bars[i]
            local backdrop = bar.edgeBackdrop or bar.backdrop

            if i == 1 then
                backdrop:SetPoint('TOP', 0, 0)
            else
                backdrop:SetPoint('TOP', getBackdrop(TC2.bars[i - 1]), 'BOTTOM', 0, -C.bar.spacing)
            end

            bar:SetHeight(min(C.bar.height, C.bar.inlineHeight))
            bar:SetStatusBarTexture(LSM:Fetch('statusbar', C.bar.texture))
            bar.icon:SetSize(C.bar.height, C.bar.height)

            backdrop:SetSize(C.frame.width + 2 - 21, C.bar.height)

            UpdateFont(bar.name)
            UpdateFont(bar.perc)
            UpdateFont(bar.val)

            bar.val:SetPoint('RIGHT', backdrop, 'RIGHT', -C.font.size * 3.5, 0)
        end

        TC2:UpdateThreatBars()
    end

    local function UpdateFrame()
        UpdateSize()
        UpdateBars()
    end

    local function UpdateBarIcon()
        for i = 1, TCC.bar.count do
            local bar = TC2.bars[i]
            if bar:IsVisible() then
                local name = bar.name:GetText()
                local class = UnitClassBase(name)

                if class then
                    bar.icon:SetTexture([[Interface\Glues\CharacterCreate\ui-charactercreate-classes]])
                    bar.icon:SetTexCoord(ns.CropClassCoords(class))
                else
                    bar.icon:SetTexture([[Interface\Icons\ability_dualwield]])
                    bar.icon:SetTexCoord(0, 1, 0, 1)
                end

                if bar.ignite:IsShown() then
                    bar.name:SetPoint('LEFT', bar.icon, 'RIGHT', TCC.igniteIndicator.size, 0)
                else
                    bar.name:SetPoint('LEFT', bar.icon, 'RIGHT')
                end
            end
        end
    end

    local function HideBars()
        for i = TCC.bar.count + 1, 40 do
            TC2.bars[i]:Hide()
        end
    end

    ns.override(TC2, 'UpdateFrame', UpdateFrame)
    ns.override(TC2, 'UpdateBars', UpdateBars)

    ns.hook(TC2, 'UpdateThreatBars', function(UpdateThreatBars, self, ...)
        local count = min(GetThreatCount(), C.ThreatClassic2.maxLines)
        if count ~= TCC.bar.count then
            TCC.bar.count = count
            UpdateFrame()
        else
            UpdateThreatBars(self, ...)
            UpdateBarIcon()
            HideBars()
        end
    end)

    ns.hook(TC2, 'TestMode', function(orig, self, ...)
        local count = TCC.bar.count
        TCC.bar.count = 40
        orig(self, ...)
        TCC.bar.count = count
        UpdateFrame()
    end)

    ns.config('watch.frame.width', UpdateFrame)
    ns.config('watch.bar.height', UpdateFrame)
    ns.config('watch.bar.inlineHeight', UpdateFrame)
    ns.config('watch.bar.spacing', UpdateFrame)
    ns.config('watch.font.name', UpdateFrame)
    ns.config('watch.font.size', UpdateFrame)
    ns.config('watch.font.style', UpdateFrame)
    ns.config('watch.font.color', UpdateFrame)
    ns.config('watch.bar.texture', UpdateFrame)
    ns.config('watch.ThreatClassic2.maxLines', UpdateFrame)

    UpdateFrame()
end)
