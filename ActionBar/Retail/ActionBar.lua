-- ActionBar.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/14/2020, 1:18:17 PM
local select = select
local ipairs = ipairs

---@type ns
local ns = select(2, ...)

local GetAtlasInfo = GetAtlasInfo
local GetCVarBool = GetCVarBool
local GetNetStats = GetNetStats
local HasAction = HasAction

local GameTooltip = GameTooltip
local MainMenuBarVehicleLeaveButton = MainMenuBarVehicleLeaveButton
local MainMenuExpBar = MainMenuExpBar
local MainMenuMicroButton = MainMenuMicroButton
local MultiBarBottomRight = MultiBarBottomRight
local ReputationWatchBar = ReputationWatchBar
local StanceBarFrame = StanceBarFrame
local StanceButton1 = StanceButton1

local LARGE_WIDTH = select(2, GetAtlasInfo('hud-MainMenuBar-large'))
local SMALL_WIDTH = select(2, GetAtlasInfo('hud-MainMenuBar-small'))

local NO_GRID_BUTTONS = ns.GetButtons('MultiBarBottomRightButton%d', 6)

local Controller = CreateFrame('Frame', nil, nil, 'SecureHandlerAttributeTemplate')

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

for _, button in ipairs(NO_GRID_BUTTONS) do
    local FloatingBG = _G[button:GetName() .. 'FloatingBG']
    FloatingBG:Hide()
end

ns.securehook('MultiActionBar_Update', function()
    if Controller:GetAttribute('hasBottomRight') then
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

do
    local Frames = {
        ActionButton1,
        MainMenuBar,
        MainMenuBarArtFrame,
        MainMenuExpBar,
        PetActionButton1,
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
        Controller:SetFrameRef(name, v)
    end
end

Controller:SetAttribute('_layoutMainMenuBar', [[
local width = self:GetAttribute('hasBottomRight')
                and ]] .. LARGE_WIDTH .. [[
                or ]] .. SMALL_WIDTH .. [[

self:GetFrameRef('MainMenuBar'):SetWidth(width)
self:GetFrameRef('MainMenuExpBar'):SetWidth(width)
]])

Controller:SetAttribute('_layoutWatchBars', [[
local y = 0
local hasExp = self:GetAttribute('hasExp')
local hasRep = self:GetAttribute('hasRep')

if hasExp then
    local height = hasRep and 10 or 13
    y = y + height
    self:GetFrameRef('MainMenuExpBar'):SetHeight(height)
end

if hasRep then
    local height = hasExp and 10 or 13
    y = y + height
    self:GetFrameRef('ReputationWatchBarDelegate'):SetHeight(height)
end

self:GetFrameRef('MainMenuBarArtFrame'):SetPoint('BOTTOM', '$parent', 'BOTTOM', 0, y)
]])

Controller:SetAttribute('_layoutPetBar', [[
local hasExp = self:GetAttribute('hasExp')
local hasRep = self:GetAttribute('hasRep')

local y = 9
if hasRep and hasExp then
    y = y + 2
elseif hasRep or hasExp then
    y = y + 4
else
    y = y - 4
end

local PetActionButton1 = self:GetFrameRef('PetActionButton1')
PetActionButton1:ClearAllPoints()
PetActionButton1:SetPoint('BOTTOMLEFT', '$parent', 'BOTTOMLEFT', 36, y)
]])

Controller:SetAttribute('_layoutStanceBar', [[
local StanceButton1 = self:GetFrameRef('StanceButton1')
StanceButton1:ClearAllPoints()
StanceButton1:SetPoint('BOTTOMLEFT', self:GetFrameRef('ActionButton1'), 'TOPLEFT',
    33, self:GetAttribute('hasBottomLeft') and 54 or 11)
]])

Controller:SetAttribute('_onattributechanged', [[
    if name == 'hasbottomright' then
        self:RunAttribute('_layoutMainMenuBar')
    elseif name == 'hasexp' or name == 'hasrep' then
        self:RunAttribute('_layoutWatchBars')
        self:RunAttribute('_layoutPetBar')
    elseif name == 'hasbottomleft' then
        self:RunAttribute('_layoutStanceBar')
        self:RunAttribute('_layoutPetBar')
    elseif name == 'haspetbar' then
        self:RunAttribute('_layoutPetBar')
    end
]])

local function SetupShowHide(frame, key)
    local handle = CreateFrame('Frame', nil, frame, 'SecureHandlerShowHideTemplate')
    handle:SetAttribute('_onshow', format([[self:GetFrameRef('controller'):SetAttribute('%s', true)]], key))
    handle:SetAttribute('_onhide', format([[self:GetFrameRef('controller'):SetAttribute('%s', false)]], key))
    handle:SetFrameRef('controller', Controller)
    ns.runattribute(handle, handle:IsVisible() and '_onshow' or '_onhide')
    return handle
end

SetupShowHide(MultiBarBottomRight, 'hasBottomRight')
SetupShowHide(MainMenuExpBar, 'hasExp')
SetupShowHide(ReputationWatchBar, 'hasRep')
SetupShowHide(MultiBarBottomLeft, 'hasBottomLeft')
SetupShowHide(PetActionBarFrame, 'hasPetBar')

ns.login(HideGrid)
