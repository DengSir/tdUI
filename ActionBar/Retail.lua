-- Retail.lua
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

local NO_GRID_BUTTONS = ns.GetButtons('MultiBarBottomRightButton%d', 6)

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

ns.login(HideGrid)

local function UpdateScale()
    print('UpdateScale')
    local screenWidth = UIParent:GetWidth()
    local barScale = 1
    local barWidth = MainMenuBar:GetWidth()
    local barMargin = MAIN_MENU_BAR_MARGIN or 75
    local bagsWidth = MicroButtonAndBagsBar:GetWidth()
    local contentsWidth = barWidth + bagsWidth
    if contentsWidth > screenWidth then
        barScale = screenWidth / contentsWidth
        barWidth = barWidth * barScale
        bagsWidth = bagsWidth * barScale
        barMargin = barMargin * barScale

        print(barScale)
    end
    MainMenuBar:SetScale(barScale)
    MainMenuBar:ClearAllPoints()
    -- if there's no overlap with between action bar and bag bar while it's in the center, use center anchor
    local roomLeft = screenWidth - barWidth - barMargin * 2
    if roomLeft >= bagsWidth * 2 then
        MainMenuBar:SetPoint('BOTTOM', UIParent, 0, 0)
    else
        local xOffset = 0
        -- if both bars can fit without overlap, move the action bar to the left
        -- otherwise sacrifice the art for more room
        if roomLeft >= bagsWidth then
            xOffset = roomLeft - bagsWidth + barMargin
        else
            xOffset = math.max((roomLeft - bagsWidth) / 2 + barMargin, 0)
        end

        if ns.profile.actionbar.micro.position == 'LEFT' then
            MainMenuBar:SetPoint('BOTTOMRIGHT', UIParent, -xOffset / barScale, 0)
        else
            MainMenuBar:SetPoint('BOTTOMLEFT', UIParent, xOffset / barScale, 0)
        end
    end
end

local function Scale()
    return ns.nocombat(UpdateScale)
end

ns.event('DISPLAY_SIZE_CHANGED', Scale)
ns.event('UI_SCALE_CHANGED', Scale)
ns.config('actionbar.micro.position', Scale)
ns.login(Scale)
