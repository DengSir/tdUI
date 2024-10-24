-- ButtonCollect.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/21/2020, 12:56:07 PM
---@type ns
local ADDON, ns = ...

local pairs, ipairs = pairs, ipairs
local max, abs = math.max, math.abs
local wipe = table.wipe or wipe
local sort = table.sort or sort
local unpack = table.unpack or unpack
local tinsert = table.insert

local Minimap = Minimap
local MinimapBackdrop = MinimapBackdrop
local GameTooltip = GameTooltip

---@class tdUICollectFrame
local Collect = CreateFrame('Frame', nil, UIParent, 'tdUICollectFrameTemplate')

local BLACK_LIST = { --
    -- ['MinimapBackdrop'] = true,
    -- ['BattlefieldMinimap'] = true,
    ['MiniMapTrackingFrame'] = true,
    ['MiniMapBattlefieldFrame'] = true,
    ['MiniMapMailFrame'] = true,
    ['EKMinimapDungeonIcon'] = true,
    -- ['TimeManagerClockButton'] = true,
}

local NONAME_BUTTONS = {
    MTSL = function()
        return MTSLUI_MINIMAP and MTSLUI_MINIMAP.ui_frame
    end,
}

local UNKNOWN_BUTTONS = {}

local Button = {}
local EditButton = ns.class('Button')

local methods = {'SetParent', 'SetPoint', 'ClearAllPoints', 'SetFrameStrata'}
local scripts = {'OnDragStart', 'OnDragStop', 'OnMouseDown', 'OnMouseUp', 'OnEnter'}

function Collect:OnLoad()
    self.buttonEnv = {}
    self.buttonList = {}
    self.buttonEdits = {}

    self:InitMinimap()
    self:InitFrame()
    self:InitEnter()

    -- self:OnLeaveMinimap()

    ns.timer(3, function()
        return self:Collect()
    end)

    self.OnLoad = nil
    self.InitMinimap = nil
    self.InitFrame = nil
    self.InitEnter = nil
end

function Collect:InitMinimap()
    local LDB = LibStub('LibDataBroker-1.1')
    local LDBIcon = LibStub('LibDBIcon-1.0')

    local obj = LDB:NewDataObject(ADDON, {
        type = 'data source',
        icon = C_AddOns.GetAddOnMetadata(ADDON, 'IconTexture'),
        OnEnter = function(button)
            GameTooltip:SetOwner(button, 'ANCHOR_LEFT')
            GameTooltip:SetText('tdUI')
        end,
        OnLeave = GameTooltip_Hide,
        OnClick = function(_, clicked)
            if clicked == 'LeftButton' then
                self:SetShown(not self:IsShown())
            else
                self:Show()
                self.Edit:SetShown(not self.Edit:IsShown())
            end
        end,
    })

    LDBIcon:Register(ADDON, obj, ns.profile.window.minimap)

    local button = LDBIcon:GetMinimapButton(ADDON)
    self.ToggleButton = button
end

function Collect:InitFrame()
    self:SetParent(self.ToggleButton)
    self:SetPoint('TOPRIGHT', self.ToggleButton, 'CENTER', 5, 5)
    self:SetFrameLevel(self.ToggleButton:GetFrameLevel() - 1)

    local function UpdateEdit()
        return self:UpdateEdit()
    end

    self.AutoHide:SetPoint('TOPRIGHT', self.ToggleButton, 'TOPRIGHT')
    self.Title:SetText('tdUI')
    self.Edit.tooltip = 'Exit edit'
    self.Edit:SetScript('OnShow', UpdateEdit)
    self.Edit:SetScript('OnHide', UpdateEdit)

    self.Option:SetScript('OnClick', function()
        return ns.OpenOption()
    end)

    self:SetScript('OnShow', self.Refresh)
end

function Collect:InitEnter()
    local EnterListener = CreateFrame('Frame', nil, Minimap)
    local LeaveListener = CreateFrame('Frame', nil, Minimap)

    EnterListener:SetFrameStrata('TOOLTIP')
    EnterListener:SetPoint('TOPLEFT', -20, 20)
    EnterListener:SetPoint('BOTTOMRIGHT', 20, -20)
    EnterListener:SetFrameLevel(MinimapBackdrop:GetFrameLevel() + 100)
    EnterListener:SetScript('OnEnter', function()
        return LeaveListener:Show()
    end)

    local timer

    LeaveListener:SetScript('OnShow', function()
        timer = nil
        EnterListener:Hide()
        self:OnEnterMinimap()
    end)
    LeaveListener:SetScript('OnHide', function()
        EnterListener:Show()
        self:OnLeaveMinimap()
    end)
    LeaveListener:SetScript('OnUpdate', function(_, elapsed)
        if EnterListener:IsMouseOver() or self:IsInEdit() or (self.AutoHide:IsShown() and self.AutoHide:IsMouseOver()) then
            timer = nil
        else
            timer = (timer or 2) - elapsed
            if timer < 0 then
                LeaveListener:Hide()
            end
        end
    end)
end

function Collect:OnEnterMinimap()
    ns.FadeIn(self.ToggleButton)

    for button, env in pairs(self.buttonEnv) do
        if not env.collected then
            ns.FadeIn(button)
        end
    end
end

function Collect:OnLeaveMinimap()
    ns.FadeOut(self.ToggleButton)

    for button, env in pairs(self.buttonEnv) do
        if not env.collected then
            ns.FadeOut(button)
        end
    end
end

function Collect:Refresh()
    self:SetScript('OnUpdate', self.OnUpdate)
end

function Collect:OnUpdate()
    self:Update()
    self:SetScript('OnUpdate', nil)
end

function Collect:Collect()
    local found
    for _, child in ipairs({Minimap:GetChildren()}) do
        if self:CheckButton(child) then
            self:GotButton(child)
            found = true
        end
    end

    if found then
        self:UpdateEdit()
        self:Refresh()
    end
end

function Collect:CheckButton(button)
    if self.buttonEnv[button] then
        return
    end
    if UNKNOWN_BUTTONS[button] then
        return
    end

    if self:IsCollectable(button) then
        return true
    end

    UNKNOWN_BUTTONS[button] = true
end

function Collect:IsCollectable(button)
    if button == self.ToggleButton then
        return false
    end
    local name = button:GetName()
    if not name then
        for k, v in pairs(NONAME_BUTTONS) do
            if v() == button then
                button.__tdname = k
                return true
            end
        end
    end
    if not name or BLACK_LIST[name] then
        return false
    end
    if not button:IsShown() then
        return false
    end

    local width, height = button:GetSize()
    if width < 30 or height < 30 then
        return false
    end
    if width > 50 or height > 50 then
        return false
    end

    if abs(width - height) > 2 then
        return false
    end
    return true
end

function Collect:GetButtonKey(button)
    return button.__tdname or button:GetName()
end

---@param button Button
function Collect:IsIgnored(button)
    return ns.profile.minimap.buttons.ignores[self:GetButtonKey(button)]
end

---@param button Button
---@param flag boolean
function Collect:SetIgnored(button, flag)
    ns.profile.minimap.buttons.ignores[self:GetButtonKey(button)] = flag or nil
end

function Collect:InitButton(button)
    button.showOnMouseover = nil

    if not self.buttonEnv[button] then
        self.buttonEnv[button] = {}
    end
end

---@param button Button
function Collect:GotButton(button)
    self:InitButton(button)
    self:UpdateButton(button)
end

---@param button Button
function Collect:OnLostButton(button)
    self:RestoreButton(button)
    self.buttonEnv[button] = nil

    if self.buttonEdits[button] then
        self.buttonEdits[button]:Hide()
    end
end

---@param button Button
function Collect:UpdateButton(button)
    if self:IsIgnored(button) then
        self:RestoreButton(button)
    else
        self:CollectButton(button)
    end
end

function Collect:OnButtonSetParent(button, parent)
    local env = self.buttonEnv[button]
    if env then
        if parent == Minimap or parent == self then
            env.SetParent(button, self)
            self:Refresh()
        else
            env.parent = parent
            self:OnLostButton(button)
        end
    end
end

function Collect:OnButtonSetPoint(button, ...)
    local env = self.buttonEnv[button]
    if env then
        env.points = {...}
    end
end

---@param button Button
function Collect:CollectButton(button, noSetParent)
    local env = self.buttonEnv[button]
    if env and not env.collected then
        local scriptWidget = self:FindButton(button) or button
        local parent = button:GetParent()
        button:SetParent(self)

        for _, method in ipairs(methods) do
            env[method], button[method] = button[method], Button[method]
        end

        for _, script in ipairs(scripts) do
            env[script] = scriptWidget:GetScript(script)
            if env[script] then
                scriptWidget:SetScript(script, Button[script] or nil)
            end
        end

        if scriptWidget ~= button then
            scriptWidget.__tdbutton = button
        end

        env.scriptWidget = scriptWidget
        env.parent = parent
        env.points = {button:GetPoint()}
        env.frameLevelDelta = max(1, button:GetFrameLevel() - MinimapBackdrop:GetFrameLevel())
        env.collected = true
    end

    self.isDirty = true
    self:Refresh()
end

---@param button Button
function Collect:RestoreButton(button)
    local env = self.buttonEnv[button]
    if env and env.collected then
        for _, method in ipairs(methods) do
            button[method] = nil

            if button[method] ~= env[method] then
                button[method] = env[method]
            end
        end

        for _, script in ipairs(scripts) do
            if env[script] then
                env.scriptWidget:SetScript(script, env[script])
            end
        end

        button:SetParent(env.parent)
        button:ClearAllPoints()
        button:SetPoint(unpack(env.points))
        button:SetFrameLevel(MinimapBackdrop:GetFrameLevel() + env.frameLevelDelta)
        -- button:SetAlpha(0)
    end
    wipe(env)

    self.isDirty = true
    self:Refresh()
end

local function comp(a, b)
    -- return a:GetName() < b:GetName()
    return Collect:GetButtonKey(a) < Collect:GetButtonKey(b)
end

function Collect:Update()
    if self.isDirty then
        self.isDirty = nil

        wipe(self.buttonList)

        for button, env in pairs(self.buttonEnv) do
            if env.collected then
                tinsert(self.buttonList, button)
            end
        end

        sort(self.buttonList, comp)
    end

    local SIZE = 33
    local HALF_SIZE = SIZE / 2
    local MARGIN_TOP = 15
    local MARGIN_LEFT = 15

    local column = 6
    local x, y = 0, 0

    for _, button in ipairs(self.buttonList) do
        if button:IsShown() then
            if x == column then
                x = 0
                y = y + 1
            end

            local env = self.buttonEnv[button]

            env.ClearAllPoints(button)
            env.SetPoint(button, 'CENTER', self, 'TOPLEFT', x * SIZE + HALF_SIZE + MARGIN_LEFT,
                         -y * SIZE - HALF_SIZE - MARGIN_TOP)
            env.SetFrameStrata(button, self:GetFrameStrata())
            button:SetFrameLevel(self:GetFrameLevel() + 5)

            x = x + 1
        end
    end

    if y == 0 then
        column = x
    end

    if x > 0 then
        y = y + 1
    end

    self:SetSize(column * SIZE + MARGIN_LEFT * 2, y * SIZE + MARGIN_TOP * 2)
end

function Collect:IsInEdit()
    return self.Edit:IsVisible()
end

function Collect:UpdateEdit()
    for button, edit in pairs(self.buttonEdits) do
        edit:Hide()
    end

    if self:IsInEdit() then
        for button, env in pairs(self.buttonEnv) do
            local edit = self:GetEditButton(button)
            edit:Show()
        end
    else
        self.Edit:Hide()
    end
end

function Collect:FindButton(button)
    if button:GetObjectType() == 'Button' then
        return button
    end

    for _, child in ipairs({button:GetChildren()}) do
        local b = self:FindButton(child)
        if b then
            return b
        end
    end
end

function Collect:GetEditButton(button)
    local edit = self.buttonEdits[button]
    if not edit then
        edit = EditButton:Create(button)
        self.buttonEdits[button] = edit
    end
    return edit
end

---- Button

Button.ClearAllPoints = nop
Button.SetFrameStrata = nop

function Button:SetParent(parent)
    return Collect:OnButtonSetParent(self, parent)
end

function Button:SetPoint(...)
    return Collect:OnButtonSetPoint(self, ...)
end

local function AnchorTip(tip, owner)
    if tip and tip:IsVisible() and tip:IsOwned(owner) then
        tip:SetAnchorType('ANCHOR_NONE')
        tip:SetPoint('TOPRIGHT', Collect, 'TOPLEFT', -2, 0)
    end
end

local function AnchorFrame(frame, owner)
    if frame and frame:IsVisible() then
        frame:ClearAllPoints()
        frame:SetPoint('TOPRIGHT', Collect, 'TOPLEFT', -2, 0)
    end
end

function Button:OnEnter()
    local button = self.__tdbutton or self
    local env = Collect.buttonEnv[button]
    if env then
        env.OnEnter(self)
        AnchorTip(GameTooltip, self)
        AnchorTip(LibDBIconTooltip, self)
        AnchorFrame(BG and BG.FBCDFrame, self)
    end
end

---- EditButton

function EditButton:Constructor(parent)
    self:SetScript('OnShow', self.Update)
    self:SetScript('OnClick', self.OnClick)
end

function EditButton:Create(parent)
    return self:Bind(CreateFrame('Button', nil, parent, 'tdUICollectEditButtonTemplate'))
end

function EditButton:Update()
    local button = self:GetParent()
    local isIgnored = Collect:IsIgnored(button)

    self:SetNormalTexture(isIgnored and [[Interface\Minimap\UI-Minimap-ZoomInButton-Up]] or
                              [[Interface\Minimap\UI-Minimap-ZoomOutButton-Up]])
    self:SetPushedTexture(isIgnored and [[Interface\Minimap\UI-Minimap-ZoomInButton-Down]] or
                              [[Interface\Minimap\UI-Minimap-ZoomOutButton-Down]])
end

function EditButton:OnClick()
    local button = self:GetParent()

    Collect:SetIgnored(button, not Collect:IsIgnored(button))
    Collect:UpdateButton(button)
    Collect:Refresh()
    self:Update()
end

---- INIT

-- ns.load(function()
    Collect:OnLoad()
-- end)

ns.addon('RecipeRadarClassic', function()
    RecipeRadar_MinimapButton:SetScript('OnLeave', GameTooltip_Hide)
end)
