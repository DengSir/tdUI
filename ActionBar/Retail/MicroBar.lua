-- Micro.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/18/2020, 9:46:28 AM
--
---@type ns
local ns = select(2, ...)

local pairs, ipairs = pairs, ipairs
local tinsert = table.insert
local unpack = table.unpack or unpack

local GetCVarBool = GetCVarBool
local GetNetStats = GetNetStats

local MicroButtonTooltipText = MicroButtonTooltipText

local UIParent = UIParent
local CharacterBag0Slot = CharacterBag0Slot
local CharacterMicroButton = CharacterMicroButton
local GameTooltip = GameTooltip
local KeyRingButton = KeyRingButton
local MainMenuBarBackpackButton = MainMenuBarBackpackButton
local MainMenuBarPerformanceBar = MainMenuBarPerformanceBar
local MainMenuMicroButton = MainMenuMicroButton

local MAINMENUBAR_LATENCY_LABEL = MAINMENUBAR_LATENCY_LABEL
local MILLISECONDS_ABBR = MILLISECONDS_ABBR
local NEWBIE_TOOLTIP_LATENCY = NEWBIE_TOOLTIP_LATENCY

local MICRO_LEFT_COORDS = {309 / 1024, 339 / 1024, 212 / 256, 255 / 256}
local MICRO_RIGHT_COORDS = {577 / 1024, 607 / 1024, 212 / 256, 255 / 256}
local MICRO_MIDDLE_COORDS = {339 / 1024, 577 / 1024, 212 / 256, 255 / 256}
local BAG_BG_COORDS = {423 / 1024, 607 / 1024, 167 / 256, 212 / 256}
local KEYRING_BG_COORDS = {423 / 1024, (423 + 24) / 1024, 167 / 256, 212 / 256}

local point = ns.RePoint

local MicroButton = ns.class('Button')
local Bar = CreateFrame('Frame', 'MicroButtonAndBagsBar', MainMenuBarArtFrame, 'tdUIMicroButtonAndBagsBarTemplate')

local MICRO_BUTTONS = (function()
    local t = {}
    for _, name in ipairs(MICRO_BUTTONS) do
        tinsert(t, _G[name])
    end
    return t
end)()

local BAGSLOTS = ns.GetFrames('CharacterBag%dSlot', 3)
do
    BAGSLOTS[0] = CharacterBag0Slot

    for i, button in pairs(BAGSLOTS) do
        button:SetSize(30, 30)
        button.IconBorder:SetSize(30, 30)
        button:GetNormalTexture():SetSize(50, 50)
    end

    KeyRingButton:SetSize(14, 30)
    BAGSLOTS[4] = KeyRingButton
end

local function coords(coords)
    local left, right, top, bottom = unpack(coords)
    if ns.profile.actionbar.micro.position == 'LEFT' then
        return right, left, top, bottom
    end
    return left, right, top, bottom
end

local function coord(region, db)
    return region:SetTexCoord(coords(db))
end

for _, button in ipairs(MICRO_BUTTONS) do
    button:SetParent(Bar)
end

for _, button in pairs(BAGSLOTS) do
    button:SetParent(Bar)
end

HelpOpenWebTicketButton:ClearAllPoints()
HelpOpenWebTicketButton:SetPoint('CENTER', MainMenuMicroButton, 'TOPRIGHT', -3, -8)

MainMenuBarBackpackButton:SetParent(Bar)

MainMenuBarPerformanceBar:ClearAllPoints()
MainMenuBarPerformanceBar:SetParent(MainMenuMicroButton)
MainMenuBarPerformanceBar:SetSize(9.0625, 4.5)
MainMenuBarPerformanceBar:SetDrawLayer('OVERLAY')
MainMenuBarPerformanceBar:SetTexture([[Interface\Buttons\WHITE8X8]])
MainMenuBarPerformanceBar:SetAlpha(0.6)
MainMenuBarPerformanceBarFrame:EnableMouse(false)

ns.hookscript(QueueStatusFrame, 'OnShow', function(self)
    self:ClearAllPoints()
    self:SetPoint('BOTTOMLEFT', MiniMapLFGFrame, 'TOPLEFT')
end)

-- MiniMapLFGFrame:SetSize(45, 45)
-- MiniMapLFGFrameIcon:SetSize(45, 45)
-- MiniMapLFGFrameBorder:SetSize(96, 96)
-- MiniMapLFGFrameBorder:SetAtlas('groupfinder-eye-single')

if not LFGParentFrame and PVEFrame then
    local function Update()
        if PVEFrame:IsShown() then
            LFGMicroButton:SetButtonState('PUSHED', true)
        else
            LFGMicroButton:SetButtonState('NORMAL')
        end
    end
    ns.securehook('UpdateMicroButtons', Update)
end

local function UpdatePerformanceBarPushed(self)
    if self:GetButtonState() == 'PUSHED' then
        MainMenuBarPerformanceBar:SetPoint('TOPLEFT', 9.0625, -17.34375)
        MainMenuBarPerformanceBar:SetAlpha(0.4)
    else
        MainMenuBarPerformanceBar:SetPoint('TOPLEFT', 9.96875, -15.53125)
        MainMenuBarPerformanceBar:SetAlpha(0.6)
    end
end

ns.securehook(MainMenuMicroButton, 'SetButtonState', UpdatePerformanceBarPushed)
ns.hookscript(MainMenuMicroButton, 'OnMouseDown', UpdatePerformanceBarPushed)
ns.hookscript(MainMenuMicroButton, 'OnMouseUp', UpdatePerformanceBarPushed)
-- @build<3@
ns.securehook('MicroButton_OnEnter', function(self)
    if not GameTooltip:IsOwned(self) then
        return
    end
    if self == MainMenuMicroButton then
        local newbie = GetCVarBool('showNewbieTips')
        local bandwidthIn, bandwidthOut, latency = GetNetStats()

        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(MAINMENUBAR_LATENCY_LABEL .. ' ' .. latency .. MILLISECONDS_ABBR, 1, 1, 1)
        if newbie then
            GameTooltip:AddLine(NEWBIE_TOOLTIP_LATENCY, 1, 0.82, 0, true)
        end
        GameTooltip:Show()
    end
end)
-- @end-build<3@

-- @build>3@
function PVPMicroButton:OnMouseDown()
    self.texture:SetPoint('TOP', 5, -14)
    self.texture:SetAlpha(0.6)
end

function PVPMicroButton:OnMouseUp()
    if self:GetButtonState() == 'PUSHED' then
        return
    end
    self.texture:SetPoint('TOP', 6, -12)
    self.texture:SetAlpha(1)
end

function PVPMicroButton:OnButtonStateChanged(state)
    if state and state:upper() == 'PUSHED' then
        self:OnMouseDown()
    else
        self:OnMouseUp()
    end
end

ns.securehook(PVPMicroButton, 'SetButtonState', PVPMicroButton.OnButtonStateChanged)
PVPMicroButton:HookScript('OnMouseDown', PVPMicroButton.OnMouseDown)
PVPMicroButton:HookScript('OnMouseUp', PVPMicroButton.OnMouseUp)
-- @end-build>3@

if MainMenuBarDownload then
    ns.securehook(MainMenuBarDownload, 'Show', function()
        MainMenuBarPerformanceBar:Hide()
    end)
    ns.securehook(MainMenuBarDownload, 'Hide', function()
        MainMenuBarPerformanceBar:Show()
    end)
end

ns.securehook('SetLookingForGroupUIAvailable', function()
    if WorldMapMicroButton then
        WorldMapMicroButton:Show()
    end
    MiniMapWorldMapButton:Hide()
end)

Bar.BgKeyring:SetParent(KeyRingButton)

local LFGButtons = {MiniMapLFGFrame, MiniMapBattlefieldFrame}

MiniMapLFGFrameBorder:SetPoint('TOPLEFT')

local function LayoutLFGButtons()
    local prev
    local point, rpoint, xDelta
    if ns.profile.actionbar.micro.position == 'LEFT' then
        point = 'BOTTOMLEFT'
        rpoint = 'BOTTOMRIGHT'
        xDelta = 5
    else
        point = 'BOTTOMRIGHT'
        rpoint = 'BOTTOMLEFT'
        xDelta = -5
    end
    for _, v in ipairs(LFGButtons) do
        if v:IsShown() then
            v:ClearAllPoints()
            if prev then
                v:SetPoint(point, prev, rpoint, 0, 0)
            else
                v:SetPoint(point, Bar, rpoint, xDelta, 5)
            end
            prev = v
        end
    end
end

for _, button in ipairs(LFGButtons) do
    ns.hookscript(button, 'OnShow', LayoutLFGButtons)
    ns.hookscript(button, 'OnHide', LayoutLFGButtons)
end

local UpdatePosition = ns.pend(function()
    local style = ns.profile.actionbar.micro.position
    if style == 'LEFT' then
        coord(Bar.BgLeft, MICRO_RIGHT_COORDS)
        coord(Bar.BgMiddle, MICRO_MIDDLE_COORDS)
        coord(Bar.BgRight, MICRO_LEFT_COORDS)
        coord(Bar.BgBag, BAG_BG_COORDS)
        coord(Bar.BgKeyring, KEYRING_BG_COORDS)

        point(Bar, 'BOTTOMLEFT', UIParent, 'BOTTOMLEFT')
        point(Bar.BgBag, 'TOPLEFT')
        point(Bar.BgKeyring, 'BOTTOMLEFT', Bar.BgBag, 'BOTTOMRIGHT', -8, 0)
        point(MainMenuBarBackpackButton, 'TOPLEFT', Bar, 'TOPLEFT', 6, -4)
        point(CharacterBag0Slot, 'LEFT', MainMenuBarBackpackButton, 'RIGHT', 4, -5)

        for i, button in ipairs(BAGSLOTS) do
            point(button, 'LEFT', BAGSLOTS[i - 1], 'RIGHT', 2.5, 0)
        end

        Bar:Show()
    elseif style == 'RIGHT' then
        coord(Bar.BgLeft, MICRO_LEFT_COORDS)
        coord(Bar.BgMiddle, MICRO_MIDDLE_COORDS)
        coord(Bar.BgRight, MICRO_RIGHT_COORDS)
        coord(Bar.BgBag, BAG_BG_COORDS)
        coord(Bar.BgKeyring, KEYRING_BG_COORDS)

        point(Bar, 'BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT')
        point(Bar.BgBag, 'TOPRIGHT')
        point(Bar.BgKeyring, 'BOTTOMRIGHT', Bar.BgBag, 'BOTTOMLEFT', 8, 0)
        point(MainMenuBarBackpackButton, 'TOPRIGHT', Bar, 'TOPRIGHT', -6, -4)
        point(CharacterBag0Slot, 'RIGHT', MainMenuBarBackpackButton, 'LEFT', -4, -5)

        for i, button in ipairs(BAGSLOTS) do
            point(button, 'RIGHT', BAGSLOTS[i - 1], 'LEFT', -2.5, 0)
        end

        Bar:Show()
    elseif style == 'HIDE' then
        Bar:Hide()
    end

    LayoutLFGButtons()
end)


local LayoutMicroBar = ns.pend(function()
    local inOverride = false
    -- @build>3@
    inOverride = ActionBarController_GetCurrentActionBarState() == LE_ACTIONBAR_STATE_OVERRIDE
    -- @end-build>3@
    local prev
    local count = 0

    if inOverride then
        local buttons = {}
        for _, button in ipairs(MICRO_BUTTONS) do
            if button.hideInOverrideBar then
                button:Hide()
            else
                button:Show()
                button:SetParent(OverrideActionBar)

                if count == 0 then
                elseif count % 6 == 0 then
                    button:ClearAllPoints()
                    button:SetPoint('TOPLEFT', buttons[count - 5], 'BOTTOMLEFT', 0, 0)
                else
                    button:ClearAllPoints()
                    button:SetPoint('BOTTOMLEFT', prev, 'BOTTOMRIGHT', -3, 0)
                end

                tinsert(buttons, button)
                count = count + 1
                prev = button
            end

        end
    else
        for _, button in ipairs(MICRO_BUTTONS) do
            if button:IsShown() then
                button:SetParent(Bar)
                button:ClearAllPoints()
                if prev then
                    button:SetPoint('BOTTOMLEFT', prev, 'BOTTOMRIGHT', -3, 0)
                else
                    button:SetPoint('BOTTOMLEFT', Bar, 5, 3)
                end

                count = count + 1
                prev = button
            end
        end
    end

    -- @build<3@
    Bar:SetWidth(26 * count + 12)
    -- @end-build<3@
    -- @build>3@
    Bar:SetWidth(26 * count + 2)
    -- @end-build>3@
end)

ns.config('actionbar.micro.position', UpdatePosition)
ns.load(UpdatePosition)
ns.load(LayoutMicroBar)
-- @build>3@
ns.securehook('MoveMicroButtons', LayoutMicroBar)
-- @end-build>3@

---- MicroButton

function MicroButton:Create(opts)
    return self:Bind(CreateFrame('Button', nil, Bar, 'MainMenuBarMicroButton'), opts)
end

function MicroButton:Constructor(_, opts)
    assert(opts.icon or opts.template)
    assert(not (opts.icon and opts.template))

    if opts.template then
        LoadMicroButtonTextures(self, opts.template)
    elseif opts.icon then
        self:SetNormalTexture([[Interface\Buttons\UI-MicroButtonCharacter-Up]])
        self:SetPushedTexture([[Interface\Buttons\UI-MicroButtonCharacter-Down]])
        self:SetDisabledTexture([[Interface\Buttons\UI-MicroButtonCharacter-Disabled]])
        self:SetHighlightTexture([[Interface\Buttons\UI-MicroButton-Hilight]])

        local icon = self:CreateTexture(nil, 'OVERLAY')
        icon:SetTexture(opts.icon)
        icon:SetSize(18, 25)
        icon:SetPoint('TOP', 0, -28)
        self.icon = icon

        self:SetScript('OnMouseDown', self.OnMouseDown)
        self:SetScript('OnMouseUp', self.OnMouseUp)
        self:OnMouseUp()
    end

    self.hideInOverrideBar = opts.hideInOverrideBar
    self.addon = true

    self:Style()

    if opts.keybinding then
        self.text = opts.text
        self.keybinding = opts.keybinding
        self.tooltipText = MicroButtonTooltipText(opts.text, opts.keybinding)
        self:RegisterEvent('UPDATE_BINDINGS')
        self:SetScript('OnEvent', self.OnEvent)
    else
        self.text = opts.text
        self.tooltipText = opts.text
    end

    if opts.frame then
        opts.frame:HookScript('OnShow', function()
            self:SetButtonState('PUSHED', true)
        end)
        opts.frame:HookScript('OnHide', function()
            self:SetButtonState('NORMAL')
        end)
    end

    if opts.onClick then
        self:SetScript('OnClick', opts.onClick)
    end

    local after = opts.after
    if type(after) == 'string' then
        after = _G[after]
    end

    if not after then
        after = MICRO_BUTTONS[#MICRO_BUTTONS]
    end

    local index = tIndexOf(MICRO_BUTTONS, after)
    local anchorTo = MICRO_BUTTONS[index]

    tinsert(MICRO_BUTTONS, index + 1, self)
    LayoutMicroBar()
end

function MicroButton:Style()
    self:SetHitRectInsets(0, 0, 3, 0)
    self:SetHeight(58 - 18)
    self:SetScript('OnShow', LayoutMicroBar)
    self:SetScript('OnHide', LayoutMicroBar)

    local function region(t)
        if t then
            t:SetTexCoord(0, 1, 18 / 58, 1)
        end
    end

    local function point(t)
        if t then
            local p, r, rp, x, y = t:GetPoint()
            t:SetPoint(p, r, rp, x, y + 18)
        end
    end

    region(self:GetNormalTexture())
    region(self:GetPushedTexture())
    region(self:GetDisabledTexture())
    region(self:GetHighlightTexture())

    point(self.Flash)
    point(self.icon or self.texture)
end

function MicroButton:OnMouseDown()
    self.icon:SetTexCoord(0.2666, 0.8666, 0, 0.8333)
    self.icon:SetAlpha(0.5)
end

function MicroButton:OnMouseUp()
    self.icon:SetTexCoord(0.2, 0.8, 0.0666, 0.9)
    self.icon:SetAlpha(1.0)
end

function MicroButton:SetButtonState(state, lock)
    self:SuperCall('SetButtonState', state, lock)

    if not self.icon then
        return
    end

    if state and state:upper() == 'PUSHED' then
        self:OnMouseDown()
    else
        self:OnMouseUp()
    end
end

function MicroButton:OnEvent(event)
    if event == 'UPDATE_BINDINGS' then
        self.tooltipText = MicroButtonTooltipText(self.text, self.keybinding)
    end
end

CharacterMicroButton.icon = MicroButtonPortrait
for _, button in ipairs(MICRO_BUTTONS) do
    MicroButton.Style(button)
end
CharacterMicroButton.icon = nil

function ns.CreateMicroButton(opts)
    return MicroButton:Create(opts)
end
