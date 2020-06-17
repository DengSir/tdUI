-- Retail.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/14/2020, 1:18:17 PM

local select = select

---@type ns
local ns = select(2, ...)

local LARGE_WIDTH = select(2, GetAtlasInfo('hud-MainMenuBar-large'))
local SMALL_WIDTH = select(2, GetAtlasInfo('hud-MainMenuBar-small'))

local GetAtlasInfo = GetAtlasInfo
local GetCVarBool = GetCVarBool
local GetNetStats = GetNetStats

local GameTooltip = GameTooltip
local MainMenuBarPerformanceBar = MainMenuBarPerformanceBar
local MainMenuBarVehicleLeaveButton = MainMenuBarVehicleLeaveButton
local MainMenuExpBar = MainMenuExpBar
local MainMenuMicroButton = MainMenuMicroButton
local MultiBarBottomRight = MultiBarBottomRight
local ReputationWatchBar = ReputationWatchBar
local StanceBarFrame = StanceBarFrame
local StanceButton1 = StanceButton1

local MAINMENUBAR_LATENCY_LABEL = MAINMENUBAR_LATENCY_LABEL
local MILLISECONDS_ABBR = MILLISECONDS_ABBR
local NEWBIE_TOOLTIP_LATENCY = NEWBIE_TOOLTIP_LATENCY

local Hider = CreateFrame('Frame')
Hider:Hide()

local function hide(frame)
    frame:Hide()
    frame:SetParent(Hider)
end

local function point(frame, ...)
    frame:ClearAllPoints()
    frame:SetPoint(...)
end

hide(MainMenuBarTexture0)
hide(MainMenuBarTexture1)
hide(MainMenuBarTexture2)
hide(MainMenuBarTexture3)

hide(MainMenuXPBarTexture0)
hide(MainMenuXPBarTexture1)
hide(MainMenuXPBarTexture2)
hide(MainMenuXPBarTexture3)

hide(MainMenuBarMaxLevelBar)
hide(MainMenuBarPerformanceBarFrameButton)

hide(ReputationWatchBar.StatusBar.WatchBarTexture0)
hide(ReputationWatchBar.StatusBar.WatchBarTexture1)
hide(ReputationWatchBar.StatusBar.WatchBarTexture2)
hide(ReputationWatchBar.StatusBar.WatchBarTexture3)

hide(ReputationWatchBar.StatusBar.XPBarTexture0)
hide(ReputationWatchBar.StatusBar.XPBarTexture1)
hide(ReputationWatchBar.StatusBar.XPBarTexture2)
hide(ReputationWatchBar.StatusBar.XPBarTexture3)

point(MultiBarBottomLeftButton1, 'BOTTOMLEFT', ActionButton1, 'TOPLEFT', 0, 13)
point(MultiBarBottomRightButton1, 'BOTTOMLEFT', ActionButton12, 'BOTTOMRIGHT', 45, 0)
point(MultiBarBottomRightButton7, 'BOTTOMLEFT', MultiBarBottomRightButton1, 'TOPLEFT', 0, 13)
point(PetActionButton1, 'BOTTOMLEFT', PetActionBarFrame, 'BOTTOMLEFT', 36, 12)

point(ActionBarUpButton, 'CENTER', MainMenuBarArtFrame, 'BOTTOMLEFT', 522, 31)
point(ActionBarDownButton, 'CENTER', MainMenuBarArtFrame, 'BOTTOMLEFT', 522, 11)

point(MainMenuBarPageNumber, 'CENTER', MainMenuBarArtFrame, 'BOTTOMLEFT', 540, 53 / 2 - 5)
point(MainMenuBarLeftEndCap, 'BOTTOM', MainMenuBar, 'BOTTOMLEFT', -32, 0)
point(MainMenuBarRightEndCap, 'BOTTOM', MainMenuBar, 'BOTTOMRIGHT', 32, 0)
point(StanceBarLeft, 'BOTTOMLEFT', StanceButton1, 'BOTTOMLEFT', -11, -3)
point(SlidingActionBarTexture0, 'LEFT', PetActionButton1, 'LEFT', -36, 1)

point(MainMenuExpBar, 'BOTTOM', MainMenuBar, 'BOTTOM')
point(MainMenuBarExpText, 'CENTER', MainMenuExpBar, 'CENTER')

local Background = select(2, MainMenuExpBar:GetRegions())
Background:SetTexture([[Interface\Buttons\WHITE8X8]])
Background:SetVertexColor(0, 0, 0, 0.8)

local MainMenuBarArtLarge = MainMenuBarArtFrame:CreateTexture(nil, 'BACKGROUND')
MainMenuBarArtLarge:SetAtlas('hud-MainMenuBar-large', true)
MainMenuBarArtLarge:SetPoint('BOTTOM')

local MainMenuBarArtSmall = MainMenuBarArtFrame:CreateTexture(nil, 'BACKGROUND')
MainMenuBarArtSmall:SetAtlas('hud-MainMenuBar-small', true)
MainMenuBarArtSmall:SetPoint('BOTTOM')

local ExpBarArtLarge = MainMenuExpBar:CreateTexture(nil, 'OVERLAY')
ExpBarArtLarge:SetAtlas('hud-MainMenuBar-experiencebar-large-single')
ExpBarArtLarge:SetAllPoints(true)

local ExpBarArtSmall = MainMenuExpBar:CreateTexture(nil, 'OVERLAY')
ExpBarArtSmall:SetAtlas('hud-MainMenuBar-experiencebar-small-single')
ExpBarArtSmall:SetAllPoints(true)

local ReputationBarArtLarge = ReputationWatchBar.StatusBar:CreateTexture(nil, 'OVERLAY')
ReputationBarArtLarge:SetAtlas('hud-MainMenuBar-experiencebar-large-single')
ReputationBarArtLarge:SetAllPoints(true)

local ReputationBarArtSmall = ReputationWatchBar.StatusBar:CreateTexture(nil, 'OVERLAY')
ReputationBarArtSmall:SetAtlas('hud-MainMenuBar-experiencebar-small-single')
ReputationBarArtSmall:SetAllPoints(true)

local ReputationWatchBarDelegate = CreateFrame('Frame', nil, ReputationWatchBar)
ReputationWatchBarDelegate:SetHeight(13)

ReputationWatchBar:EnableMouse(false)
ReputationWatchBar.StatusBar:EnableMouse(false)
ReputationWatchBar.StatusBar:SetParent(ReputationWatchBarDelegate)
ReputationWatchBar.StatusBar:ClearAllPoints()
ReputationWatchBar.StatusBar:SetAllPoints(true)
ReputationWatchBar.StatusBar.Background:SetTexture([[Interface\Buttons\WHITE8X8]])
ReputationWatchBar.StatusBar.Background:SetVertexColor(0, 0, 0, 0.8)
ReputationWatchBar.OverlayFrame:SetParent(ReputationWatchBarDelegate)
ReputationWatchBar.OverlayFrame:ClearAllPoints()
ReputationWatchBar.OverlayFrame:SetAllPoints(ReputationWatchBar.StatusBar)
ReputationWatchBar.OverlayFrame:EnableMouse(false)

local OnEnter = ReputationWatchBar:GetScript('OnEnter')
local OnLeave = ReputationWatchBar:GetScript('OnLeave')

ReputationWatchBarDelegate:SetScript('OnEnter', function()
    return OnEnter(ReputationWatchBar)
end)
ReputationWatchBarDelegate:SetScript('OnLeave', function()
    return OnLeave(ReputationWatchBar)
end)

ns.securehook('MultiActionBar_Update', function()
    if MultiBarBottomRight:IsShown() then
        ReputationWatchBarDelegate:SetWidth(LARGE_WIDTH)

        MainMenuBarArtLarge:Show()
        MainMenuBarArtSmall:Hide()

        ExpBarArtLarge:Show()
        ExpBarArtSmall:Hide()

        ReputationBarArtLarge:Show()
        ReputationBarArtSmall:Hide()
    else
        ReputationWatchBarDelegate:SetWidth(SMALL_WIDTH)

        MainMenuBarArtLarge:Hide()
        MainMenuBarArtSmall:Show()

        ExpBarArtLarge:Hide()
        ExpBarArtSmall:Show()

        ReputationBarArtLarge:Hide()
        ReputationBarArtSmall:Show()
    end
end)

local NO_GRID_BUTTONS = {
    MultiBarBottomRightButton1, MultiBarBottomRightButton2, MultiBarBottomRightButton3, MultiBarBottomRightButton4,
    MultiBarBottomRightButton5, MultiBarBottomRightButton6,
}

for _, button in ipairs(NO_GRID_BUTTONS) do
    _G[button:GetName() .. 'FloatingBG']:Hide()
end

local function HideGrid()
    for _, button in ipairs(NO_GRID_BUTTONS) do
        if not HasAction(button.action) then
            button:SetAlpha(0)
        else
            button:SetAlpha(1)
        end
    end
end

ns.event('ACTIONBAR_SHOWGRID', function()
    for _, button in ipairs(NO_GRID_BUTTONS) do
        button:SetAlpha(1)
    end
end)
ns.event('ACTIONBAR_HIDEGRID', ns.spawned(HideGrid))

ns.securehook('MainMenuTrackingBar_Configure', function(ReputationWatchBar)
    ReputationWatchBar.OverlayFrame.Text:SetPoint('CENTER')
    ReputationWatchBarDelegate:SetPoint('BOTTOM', MainMenuExpBar, 'BOTTOM', 0, MainMenuExpBar:IsShown() and 10 or 0)
end)

ns.securehook('MainMenuBarVehicleLeaveButton_Update', function()
    local button = MainMenuBarVehicleLeaveButton
    if not button:IsShown() then
        return
    end

    local _, relativeTo = button:GetPoint()
    if relativeTo == StanceBarFrame then
        button:SetPoint('LEFT', StanceButton1, 'LEFT')
    end
end)

local Ref = CreateFrame('Frame', nil, UIParent, 'SecureHandlerBaseTemplate')
do
    local Frames = {
        ActionButton1,
        MainMenuBar,
        MainMenuBarArtFrame,
        MainMenuExpBar,
        MultiBarBottomLeft,
        MultiBarBottomRight,
        PetActionButton1,
        PetActionBarFrame,
        ReputationWatchBar,
        StanceButton1,
        ReputationWatchBarDelegate = ReputationWatchBarDelegate,
    }

    for k, v in pairs(Frames) do
        local name
        if type(k) == 'number' then
            name = v:GetName()
        else
            name = k
        end

        assert(name)
        Ref:SetFrameRef(name, v)
    end
end

local function SetupShowHide(frame, onShowHide)
    local handle = CreateFrame('Frame', nil, frame, 'SecureHandlerShowHideTemplate')
    handle:SetAttribute('_onshow', onShowHide)
    handle:SetAttribute('_onhide', onShowHide)
    handle:SetFrameRef('ref', Ref)
    ns.runattribute(handle, '_onshow')
    return handle
end

local LayoutMainMenuBar = format([[
local ref = self:GetFrameRef('ref')
local MultiBarBottomRight = ref:GetFrameRef('MultiBarBottomRight')
local MainMenuExpBar = ref:GetFrameRef('MainMenuExpBar')
local MainMenuBar = ref:GetFrameRef('MainMenuBar')

local width = MultiBarBottomRight:IsShown() and %d or %d

MainMenuBar:SetWidth(width)
MainMenuExpBar:SetWidth(width)
]], LARGE_WIDTH, SMALL_WIDTH)

local LayoutWatchBars = [[
local ref = self:GetFrameRef('ref')
local MainMenuExpBar = ref:GetFrameRef('MainMenuExpBar')
local ReputationWatchBar = ref:GetFrameRef('ReputationWatchBar')
local MainMenuBarArtFrame = ref:GetFrameRef('MainMenuBarArtFrame')
local MultiBarBottomLeft = ref:GetFrameRef('MultiBarBottomLeft')
local PetActionButton1 = ref:GetFrameRef('PetActionButton1')
local ReputationWatchBarDelegate = ref:GetFrameRef('ReputationWatchBarDelegate')

local y = 0

local expBarShown = MainMenuExpBar:IsShown()
local repBarShown = ReputationWatchBar:IsShown()

MainMenuExpBar:SetHeight(repBarShown and 10 or 13)
ReputationWatchBarDelegate:SetHeight(expBarShown and 10 or 13)

if expBarShown then
    y = y + MainMenuExpBar:GetHeight()
end

if repBarShown then
    y = y + ReputationWatchBarDelegate:GetHeight()
end

MainMenuBarArtFrame:SetPoint('BOTTOM', '$parent', 'BOTTOM', 0, y)
]]

local LayoutStanceBar = [[
local ref = self:GetFrameRef('ref')
local StanceButton1 = ref:GetFrameRef('StanceButton1')
local ActionButton1 = ref:GetFrameRef('ActionButton1')
local MultiBarBottomLeft = ref:GetFrameRef('MultiBarBottomLeft')

StanceButton1:ClearAllPoints()
StanceButton1:SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 33, MultiBarBottomLeft:IsShown() and 54 or 11)
]]

local LayoutPetActionBar = [[
local ref = self:GetFrameRef('ref')
local PetActionButton1 = ref:GetFrameRef('PetActionButton1')
local ReputationWatchBar = ref:GetFrameRef('ReputationWatchBar')
local MainMenuExpBar = ref:GetFrameRef('MainMenuExpBar')

local repShown = ReputationWatchBar:IsShown()
local expShown = MainMenuExpBar:IsShown()

local y = 9
if repShown and expShown then
    y = y + 2
elseif repShown or expShown then
    y = y + 4
else
    y = y - 4
end

PetActionButton1:ClearAllPoints()
PetActionButton1:SetPoint('BOTTOMLEFT', '$parent', 'BOTTOMLEFT', 36, y)
]]

SetupShowHide(MultiBarBottomRight, LayoutMainMenuBar)
SetupShowHide(MainMenuExpBar, LayoutWatchBars .. LayoutPetActionBar)
SetupShowHide(ReputationWatchBar, LayoutWatchBars .. LayoutPetActionBar)
SetupShowHide(MultiBarBottomLeft, LayoutStanceBar .. LayoutPetActionBar)
SetupShowHide(PetActionBarFrame, LayoutPetActionBar)

local MicroButtonAndBagsBar = CreateFrame('Frame', nil, MainMenuBar)
MicroButtonAndBagsBar:SetSize(26 * 8 + 12, 87)

local MICRO_LEFT_COORDS = {309 / 1024, 339 / 1024, 212 / 256, 255 / 256}
local MICRO_RIGHT_COORDS = {577 / 1024, 607 / 1024, 212 / 256, 255 / 256}
local MICRO_MIDDLE_COORDS = {339 / 1024, 577 / 1024, 212 / 256, 255 / 256}
local BAG_BG_COORDS = {423 / 1024, 607 / 1024, 167 / 256, 212 / 256}
local KEYRING_BG_COORDS = {423 / 1024, (423 + 24) / 1024, 167 / 256, 212 / 256}

local function GetCoords(coords, style)
    local left, right, top, bottom = unpack(coords)
    if style == 'LEFT' then
        return right, left, top, bottom
    end
    return left, right, top, bottom
end

local MicroLeft = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
MicroLeft:SetPoint('BOTTOMLEFT')
MicroLeft:SetTexture(1721259)
MicroLeft:SetSize(30, 43)

local MicroMiddle = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
MicroMiddle:SetPoint('LEFT', MicroLeft, 'RIGHT')
MicroMiddle:SetTexture(1721259)
MicroMiddle:SetSize(26 * 8 - 48, 43)

local MicroRight = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
MicroRight:SetPoint('LEFT', MicroMiddle, 'RIGHT')
MicroRight:SetTexture(1721259)
MicroRight:SetSize(30, 43)

local BagBg = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
BagBg:SetTexture(1721259)
BagBg:SetSize(607 - 423, 212 - 167)
BagBg:SetPoint('TOPRIGHT')

local KeyringBg = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND', nil, -1)
KeyringBg:SetTexture(1721259)
KeyringBg:SetSize(24, 212 - 167)

for i = 0, 3 do
    local frame = _G['CharacterBag' .. i .. 'Slot']
    frame:SetSize(30, 30)
    frame.IconBorder:SetSize(30, 30)
    frame:GetNormalTexture():SetSize(50, 50)
    frame:ClearAllPoints()
    if i == 0 then
        frame:SetPoint('RIGHT', MainMenuBarBackpackButton, 'LEFT', -4, -5)
    else
        frame:SetPoint('RIGHT', _G['CharacterBag' .. (i - 1) .. 'Slot'], 'LEFT', -2.5, 0)
    end
end

KeyRingButton:SetSize(14, 30)

MainMenuBarPerformanceBar:ClearAllPoints()
MainMenuBarPerformanceBar:SetParent(MainMenuMicroButton)
MainMenuBarPerformanceBar:SetSize((21 - 11) * 29 / 32, (42 - 37) * 58 / 64)
MainMenuBarPerformanceBar:SetDrawLayer('OVERLAY')
MainMenuBarPerformanceBar:SetTexture([[Interface\BUTTONS\white8x8]])
MainMenuBarPerformanceBar:SetAlpha(0.6)
MainMenuBarPerformanceBarFrame:EnableMouse(false)

local function UpdatePerformanceBarPushed(self)
    if self:GetButtonState() == 'PUSHED' then
        MainMenuBarPerformanceBar:SetPoint('TOPLEFT', 10 * 29 / 32, -39 * 58 / 64)
        MainMenuBarPerformanceBar:SetAlpha(0.4)
    else
        MainMenuBarPerformanceBar:SetPoint('TOPLEFT', 11 * 29 / 32, -37 * 58 / 64)
        MainMenuBarPerformanceBar:SetAlpha(0.6)
    end
end

MainMenuMicroButton:HookScript('OnMouseDown', UpdatePerformanceBarPushed)
MainMenuMicroButton:HookScript('OnMouseUp', UpdatePerformanceBarPushed)
ns.securehook(MainMenuMicroButton, 'SetButtonState', UpdatePerformanceBarPushed)
ns.securehook('MicroButton_OnEnter', function(self)
    if self == MainMenuMicroButton then
        local newbie = GetCVarBool('showNewbieTips')
        local bandwidthIn, bandwidthOut, latency = GetNetStats()

        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(MAINMENUBAR_LATENCY_LABEL .. ' ' .. latency .. MILLISECONDS_ABBR, 1, 1, 1)
        if newbie then
            GameTooltip:AddLine(NEWBIE_TOOLTIP_LATENCY, 1, 0.82, 0, true)
        end
    end
end)

local buttons = {
    CharacterMicroButton, SpellbookMicroButton, TalentMicroButton, QuestLogMicroButton, SocialsMicroButton,
    WorldMapMicroButton, MainMenuMicroButton, HelpMicroButton,
}

local function UpdateMicroBar(style)
    style = style or ns.profile.actionbar.micro.position
    if style == 'LEFT' then
        MicroLeft:SetTexCoord(GetCoords(MICRO_RIGHT_COORDS, style))
        MicroMiddle:SetTexCoord(GetCoords(MICRO_MIDDLE_COORDS, style))
        MicroRight:SetTexCoord(GetCoords(MICRO_LEFT_COORDS, style))
        BagBg:SetTexCoord(GetCoords(BAG_BG_COORDS, style))
        KeyringBg:SetTexCoord(GetCoords(KEYRING_BG_COORDS, style))
        point(BagBg, 'TOPLEFT')
        point(KeyringBg, 'BOTTOMLEFT', BagBg, 'BOTTOMRIGHT', -(24 - 16), 0)

        point(CharacterMicroButton, 'BOTTOMLEFT', MicroButtonAndBagsBar, 'BOTTOMLEFT', 4, 3)
        point(MainMenuBarBackpackButton, 'TOPLEFT', MicroButtonAndBagsBar, 'TOPLEFT', 6, -4)
        point(CharacterBag0Slot, 'LEFT', MainMenuBarBackpackButton, 'RIGHT', 4, -5)
        for i = 1, 3 do
            point(_G['CharacterBag' .. i .. 'Slot'], 'LEFT', _G['CharacterBag' .. (i - 1) .. 'Slot'], 'RIGHT', 2.5, 0)
        end
        point(KeyRingButton, 'LEFT', CharacterBag3Slot, 'RIGHT', 2.5, 0)

        point(MicroButtonAndBagsBar, 'BOTTOMLEFT', UIParent, 'BOTTOMLEFT')
    else
        MicroLeft:SetTexCoord(GetCoords(MICRO_LEFT_COORDS, style))
        MicroMiddle:SetTexCoord(GetCoords(MICRO_MIDDLE_COORDS, style))
        MicroRight:SetTexCoord(GetCoords(MICRO_RIGHT_COORDS, style))
        BagBg:SetTexCoord(GetCoords(BAG_BG_COORDS, style))
        KeyringBg:SetTexCoord(GetCoords(KEYRING_BG_COORDS, style))
        point(BagBg, 'TOPRIGHT')
        point(KeyringBg, 'BOTTOMRIGHT', BagBg, 'BOTTOMLEFT', 24 - 16, 0)

        point(CharacterMicroButton, 'BOTTOMLEFT', MicroButtonAndBagsBar, 'BOTTOMLEFT', 6, 3)
        point(MainMenuBarBackpackButton, 'TOPRIGHT', MicroButtonAndBagsBar, 'TOPRIGHT', -6, -4)
        point(CharacterBag0Slot, 'RIGHT', MainMenuBarBackpackButton, 'LEFT', -4, -5)
        for i = 1, 3 do
            point(_G['CharacterBag' .. i .. 'Slot'], 'RIGHT', _G['CharacterBag' .. (i - 1) .. 'Slot'], 'LEFT', -2.5, 0)
        end
        point(KeyRingButton, 'RIGHT', CharacterBag3Slot, 'LEFT', -2.5, 0)

        point(MicroButtonAndBagsBar, 'BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT')
    end
end

local function UpdateMicroWidth()
    local count = #buttons
    MicroButtonAndBagsBar:SetWidth(26 * count + 12)
    MicroMiddle:SetWidth(26 * count - 48)
end

local function OnEvent(self, event)
    if event == 'UPDATE_BINDINGS' then
        self.tooltipText = MicroButtonTooltipText(self.text, self.keybinding)
    end
end

ns.config('actionbar.micro.position', UpdateMicroBar)
ns.login(function()
    HideGrid()
    UpdateMicroBar()
end)

function ns.CreateMicroButton(after, text, keybinding, frame)
    local button = CreateFrame('Button', nil, MainMenuBar, 'MainMenuBarMicroButton')

    local index = tIndexOf(buttons, after)
    local anchorTo = buttons[index]

    if keybinding then
        button.text = text
        button.keybinding = keybinding
        button.tooltipText = MicroButtonTooltipText(text, keybinding)
        button:RegisterEvent('UPDATE_BINDINGS')
        button:SetScript('OnEvent', OnEvent)
    else
        button.tooltipText = text
    end

    button:SetPoint('BOTTOMLEFT', anchorTo, 'BOTTOMRIGHT', -3, 0)
    if buttons[index + 1] then
        buttons[index + 1]:SetPoint('BOTTOMLEFT', button, 'BOTTOMRIGHT', -3, 0)
    end

    if frame then
        frame:HookScript('OnShow', function()
            button:SetButtonState('PUSHED', true)
        end)
        frame:HookScript('OnHide', function()
            button:SetButtonState('NORMAL')
        end)
    end

    tinsert(buttons, index + 1, button)
    UpdateMicroWidth()
    return button
end
