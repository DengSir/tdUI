-- MinimapButtons.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/20/2020, 9:36:45 AM
--
---@type ns
local ADDON, ns = ...

local nop = nop
local pairs, ipairs = pairs, ipairs
local max = math.max
local tinsert, unpack = table.insert, table.unpack or unpack
local sort, wipe = table.sort, table.wipe or wipe

local Minimap = Minimap
local MinimapBackdrop = MinimapBackdrop

local BLACK_LIST = { --
    ['TimeManagerClockButton'] = true,
    ['BattlefieldMinimap'] = true,
    ['MiniMapBattlefieldFrame'] = true,
}

local WHITE_LIST = { --
    ['RecipeRadarMinimapButtonFrame'] = true,
}

ns.load(function()
    ---@type Button
    local ToggleButton
    ---@type Frame
    local CollectFrame

    ---@type table<Button, tdUIMinimapButtonOpt>
    local buttonOpts = {}
    local buttonEdit = {}
    local buttonList = {}

    local dirty = nil

    local function IsIgnore(button)
        return ns.profile.minimap.buttons.ignores[button:GetName()]
    end

    local function SetIgnore(button, flag)
        ns.profile.minimap.buttons.ignores[button:GetName()] = flag or nil
    end

    local function CompareButton(a, b)
        return a:GetName() < b:GetName()
    end

    local function LayoutButton()
        if dirty then
            dirty = nil

            wipe(buttonList)

            for button, opt in pairs(buttonOpts) do
                if opt.collected then
                    tinsert(buttonList, button)
                end
            end

            sort(buttonList, CompareButton)
        end

        local SIZE = 33
        local HALF_SIZE = SIZE / 2
        local MARGIN_TOP = 15
        local MARGIN_LEFT = 15

        local column = 6
        local x, y = 0, 0

        for _, button in ipairs(buttonList) do
            if button:IsShown() then
                if x == column then
                    x = 0
                    y = y + 1
                end

                local opt = buttonOpts[button]

                opt.ClearAllPoints(button)
                opt.SetPoint(button, 'CENTER', CollectFrame, 'TOPLEFT', x * SIZE + HALF_SIZE + MARGIN_LEFT,
                             -y * SIZE - HALF_SIZE - MARGIN_TOP)

                x = x + 1
            end
        end

        if y == 0 then
            column = x
        end

        if x > 0 then
            y = y + 1
        end

        CollectFrame:SetSize(column * SIZE + MARGIN_LEFT * 2, y * SIZE + MARGIN_TOP * 2)
    end

    local OnEnter
    do
        local function SetPoint(tip)
            tip:__SetPoint('TOPRIGHT', CollectFrame, 'TOPLEFT', 0, -5)
        end

        local function SetOwner(tip, owner)
            tip:__SetOwner(owner, 'ANCHOR_NONE')
            SetPoint(tip)
        end

        local function HookTip(tip)
            if tip then
                tip.__SetPoint = tip.SetPoint
                tip.__SetOwner = tip.SetOwner

                tip.ClearAllPoints = nop
                tip.SetPoint = SetPoint
                tip.SetOwner = SetOwner
            end
        end

        local function UnhookTip(tip)
            if tip then
                tip.ClearAllPoints = nil
                tip.SetPoint = nil
                tip.SetOwner = nil
            end
        end

        function OnEnter(frame)
            local opt = buttonOpts[frame.__button]
            if opt and opt.collected then
                HookTip(GameTooltip)
                HookTip(LibDBIconTooltip)
                opt.OnEnter(frame)
                UnhookTip(GameTooltip)
                UnhookTip(LibDBIconTooltip)
            end
        end
    end

    local SCRIPTS = {OnEnter = OnEnter, OnDragStart = false, OnDragStop = false}

    local function FindTarget(button)
        if button:GetObjectType() ~= 'Button' then
            for _, child in ipairs {button:GetChildren()} do
                local target = FindTarget(child)
                if target then
                    return target
                end
            end
        else
            return button
        end
    end

    local function SetPoint(button, ...)
        local opt = buttonOpts[button]
        if opt then
            opt.points = {...}
        end
    end

    ---@param button Button
    local function CollectButton(button)
        ---@type tdUIMinimapButtonOpt
        local opt = buttonOpts[button] or {}
        buttonOpts[button] = wipe(opt)

        local target = FindTarget(button) or button
        target.__button = button
        opt.collected = true
        opt.target = target
        opt.SetPoint = button.SetPoint
        opt.ClearAllPoints = button.ClearAllPoints
        opt.points = {button:GetPoint()}
        opt.frameLevelDelta = max(1, MinimapBackdrop:GetFrameLevel() - button:GetFrameLevel())

        button:SetParent(CollectFrame)

        for script, func in pairs(SCRIPTS) do
            opt[script] = target:GetScript(script)
            if opt[script] and func then
                target:SetScript(script, func)
            end
        end

        button.ClearAllPoints = nop
        button.SetPoint = SetPoint
    end

    ---@param button Button
    local function RestoreButton(button)
        local opt = buttonOpts[button] or {}
        if opt.collected then
            button.SetPoint = nil
            button.ClearAllPoints = nil

            button:SetParent(Minimap)
            button:ClearAllPoints()
            button:SetPoint(unpack(opt.points))
            button:SetFrameLevel(MinimapBackdrop:GetFrameLevel() + opt.frameLevelDelta)

            for script in pairs(SCRIPTS) do
                if opt[script] then
                    opt.target:SetScript(script, opt[script])
                end
            end
        end
        buttonOpts[button] = wipe(opt)
    end

    ---@param button Button
    local function GotButton(button)
        if IsIgnore(button) then
            RestoreButton(button)
        else
            CollectButton(button)
        end
        dirty = true
    end

    ---@param button Button
    local function IsCollectable(button)
        if button == ToggleButton then
            return
        end
        local name = button:GetName()
        if not name or BLACK_LIST[name] then
            return
        end
        if WHITE_LIST[name] then
            return true
        end
        return button:GetObjectType() == 'Button' and button:GetNumRegions() >= 3 and button:IsShown()
    end

    local CreateEditButton
    do
        local function OnShow(edit)
            local button = edit:GetParent()
            local isIgnored = IsIgnore(button)

            edit:SetNormalTexture(isIgnored and [[Interface\Minimap\UI-Minimap-ZoomInButton-Up]] or
                                      [[Interface\Minimap\UI-Minimap-ZoomOutButton-Up]])
            edit:SetPushedTexture(isIgnored and [[Interface\Minimap\UI-Minimap-ZoomInButton-Down]] or
                                      [[Interface\Minimap\UI-Minimap-ZoomOutButton-Down]])
        end

        local function OnClick(edit)
            local button = edit:GetParent()
            local name = button:GetName()

            SetIgnore(button, not IsIgnore(button))
            GotButton(button)
            LayoutButton()
            OnShow(edit)
        end

        function CreateEditButton(button)
            local edit = CreateFrame('Button', nil, button, 'tdUICollectEditButtonTemplate')
            edit:Hide()
            edit:SetAllPoints(true)
            edit:SetFrameLevel(button:GetFrameLevel() + 20)
            edit:SetScript('OnClick', OnClick)
            edit:SetScript('OnShow', OnShow)

            buttonEdit[button] = edit
            return edit
        end
    end

    local function LayoutEdit()
        for button, opt in pairs(buttonOpts) do
            local edit = buttonEdit[button]
            if CollectFrame.Edit:IsShown() then
                edit = edit or CreateEditButton(button)
                edit:Show()
            elseif edit then
                edit:Hide()
            end
        end
    end

    local function Collect()
        local found
        for i, child in ipairs {Minimap:GetChildren()} do
            if IsCollectable(child) and not buttonOpts[child] then
                print(child)
                GotButton(child)
                found = true
            end
        end

        if found then
            LayoutButton()
            LayoutEdit()
        end
    end

    do
        local LDB = LibStub('LibDataBroker-1.1')
        local LDBIcon = LibStub('LibDBIcon-1.0')

        local obj = LDB:NewDataObject(ADDON, {
            type = 'data source',
            icon = [[Interface\MacroFrame\MacroFrame-Icon]],
            OnEnter = function(button)
                GameTooltip:SetOwner(button, 'ANCHOR_NONE')
                GameTooltip:SetPoint('BOTTOMRIGHT', button, 'TOPLEFT')
                GameTooltip:SetText('tdUI')
                GameTooltip:Show()
            end,
            OnLeave = GameTooltip_Hide,
            OnClick = function(_, clicked)
                if clicked == 'LeftButton' then
                    CollectFrame:SetShown(not CollectFrame:IsShown())
                else
                    CollectFrame:Show()
                    CollectFrame.Edit:SetShown(not CollectFrame.Edit:IsShown())
                end
            end,
        })

        LDBIcon:Register(ADDON, obj, ns.profile.window.minimap)

        ToggleButton = LDBIcon:GetMinimapButton(ADDON)
    end

    do
        CollectFrame = CreateFrame('Frame', nil, ToggleButton, 'tdUICollectFrameTemplate')
        CollectFrame:Hide()
        CollectFrame:EnableMouse(true)
        CollectFrame:SetPoint('TOPRIGHT', ToggleButton, 'CENTER', 5, 5)
        CollectFrame:SetFrameLevel(ToggleButton:GetFrameLevel() - 1)
        CollectFrame:SetScript('OnShow', function()
            LayoutButton()
            LayoutEdit()
        end)

        CollectFrame.Title:SetText('tdUI')
        CollectFrame.Edit.tooltip = 'Exit edit'
        CollectFrame.Edit:SetScript('OnShow', LayoutEdit)
        CollectFrame.Edit:SetScript('OnHide', function(self)
            self:Hide()
            LayoutEdit()
        end)
        CollectFrame.Option:SetScript('OnClick', function()
            ns.OpenOption()
            CollectFrame:Hide()
        end)

        local AutoHide = CreateFrame('Frame', nil, CollectFrame)
        AutoHide:SetPoint('TOPRIGHT', ToggleButton, 'TOPRIGHT')
        AutoHide:SetPoint('BOTTOMLEFT')
        AutoHide:SetScript('OnUpdate', function(self, elapsed)
            if CollectFrame.Edit:IsShown() or self:IsMouseOver() then
                self.timer = nil
            else
                self.timer = (self.timer or 2) - elapsed
                if self.timer < 0 then
                    CollectFrame:Hide()
                end
            end
        end)
    end

    ns.timer(3, Collect)
end)

ns.addon('RecipeRadarClassic', function()
    RecipeRadar_MinimapButton:SetScript('OnLeave', GameTooltip_Hide)
end)
