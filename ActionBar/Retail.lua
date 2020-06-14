-- Retail.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/14/2020, 1:18:17 PM

---@type ns
local ns = select(2, ...)

---@type Frame
local MainMenuBar, MainMenuExpBar, ReputationWatchBar, MainMenuBarArtFrame = MainMenuBar, MainMenuExpBar,
                                                                             ReputationWatchBar, MainMenuBarArtFrame

local Hider = CreateFrame('Frame')
Hider:Hide()

local function Hide(frame)
    frame:Hide()
    frame:SetParent(Hider)
end

Hide(MainMenuBarTexture0)
Hide(MainMenuBarTexture1)
Hide(MainMenuBarTexture2)
Hide(MainMenuBarTexture3)

Hide(MainMenuXPBarTexture0)
Hide(MainMenuXPBarTexture1)
Hide(MainMenuXPBarTexture2)
Hide(MainMenuXPBarTexture3)

Hide(MainMenuBarMaxLevelBar)
Hide(MainMenuBarPerformanceBarFrame)

Hide(ReputationWatchBar.StatusBar.WatchBarTexture0)
Hide(ReputationWatchBar.StatusBar.WatchBarTexture1)
Hide(ReputationWatchBar.StatusBar.WatchBarTexture2)
Hide(ReputationWatchBar.StatusBar.WatchBarTexture3)

Hide(ReputationWatchBar.StatusBar.XPBarTexture0)
Hide(ReputationWatchBar.StatusBar.XPBarTexture1)
Hide(ReputationWatchBar.StatusBar.XPBarTexture2)
Hide(ReputationWatchBar.StatusBar.XPBarTexture3)

CharacterMicroButton:ClearAllPoints()
CharacterMicroButton:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT')

MultiBarBottomLeftButton1:ClearAllPoints()
MultiBarBottomLeftButton1:SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 0, 13)

MultiBarBottomRightButton1:ClearAllPoints()
MultiBarBottomRightButton1:SetPoint('BOTTOMLEFT', ActionButton12, 'BOTTOMRIGHT', 45, 0)

MultiBarBottomRightButton7:ClearAllPoints()
MultiBarBottomRightButton7:SetPoint('BOTTOMLEFT', MultiBarBottomRightButton1, 'TOPLEFT', 0, 13)

StanceButton1:ClearAllPoints()
StanceButton1:SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 33, 11)

ActionBarUpButton:ClearAllPoints()
ActionBarUpButton:SetPoint('CENTER', MainMenuBarArtFrame, 'BOTTOMLEFT', 522, 31)

ActionBarDownButton:ClearAllPoints()
ActionBarDownButton:SetPoint('CENTER', MainMenuBarArtFrame, 'BOTTOMLEFT', 522, 11)

MainMenuBarPageNumber:ClearAllPoints()
MainMenuBarPageNumber:SetPoint('CENTER', MainMenuBarArtFrame, 'BOTTOMLEFT', 540, 53 / 2 - 5)

MainMenuBarLeftEndCap:ClearAllPoints()
MainMenuBarLeftEndCap:SetPoint('BOTTOM', MainMenuBar, 'BOTTOMLEFT', -32, 0)

MainMenuBarRightEndCap:ClearAllPoints()
MainMenuBarRightEndCap:SetPoint('BOTTOM', MainMenuBar, 'BOTTOMRIGHT', 32, 0)

StanceBarLeft:ClearAllPoints()
StanceBarLeft:SetPoint('BOTTOMLEFT', StanceButton1, 'BOTTOMLEFT', -11, -3)

SlidingActionBarTexture0:ClearAllPoints()
SlidingActionBarTexture0:SetPoint('LEFT', PetActionButton1, 'LEFT', -36, 1)

MainMenuExpBar:ClearAllPoints()
MainMenuExpBar:SetPoint('BOTTOM', MainMenuBar, 'BOTTOM')

local MainMenuBarArtLarge = MainMenuBarArtFrame:CreateTexture(nil, 'BACKGROUND')
MainMenuBarArtLarge:SetAtlas('hud-MainMenuBar-large', true)
MainMenuBarArtLarge:SetPoint('BOTTOM')

local MainMenuBarArtSmall = MainMenuBarArtFrame:CreateTexture(nil, 'BACKGROUND')
MainMenuBarArtSmall:SetAtlas('hud-MainMenuBar-small', true)
MainMenuBarArtSmall:SetPoint('BOTTOM')

local ExpBarArtLarge = MainMenuExpBar:CreateTexture(nil, 'OVERLAY')
ExpBarArtLarge:SetAtlas('hud-MainMenuBar-experiencebar-large-single', true)
ExpBarArtLarge:SetPoint('CENTER')

local ExpBarArtSmall = MainMenuExpBar:CreateTexture(nil, 'OVERLAY')
ExpBarArtSmall:SetAtlas('hud-MainMenuBar-experiencebar-small-single', true)
ExpBarArtSmall:SetPoint('CENTER')

local ReputationBarArtLarge = ReputationWatchBar.StatusBar:CreateTexture(nil, 'OVERLAY')
ReputationBarArtLarge:SetAtlas('hud-MainMenuBar-experiencebar-large-single')
ReputationBarArtLarge:SetAllPoints(true)

local ReputationBarArtSmall = ReputationWatchBar.StatusBar:CreateTexture(nil, 'OVERLAY')
ReputationBarArtSmall:SetAtlas('hud-MainMenuBar-experiencebar-small-single')
ReputationBarArtSmall:SetAllPoints(true)

local ReputationWatchBarDelegate = CreateFrame('Frame', nil, MainMenuBar)
ReputationWatchBarDelegate:SetHeight(13)
print(ReputationWatchBarDelegate)

local function UpdateWidth(width)
    -- MainMenuExpBar:SetWidth(width)
    -- ReputationWatchBar:SetWidth(width)
    ReputationWatchBarDelegate:SetWidth(width)
end

local function UpdateTexture(isLarge)
    if isLarge then
        MainMenuBarArtLarge:Show()
        MainMenuBarArtSmall:Hide()

        ExpBarArtLarge:Show()
        ExpBarArtSmall:Hide()

        ReputationBarArtLarge:Show()
        ReputationBarArtSmall:Hide()
    else
        MainMenuBarArtLarge:Hide()
        MainMenuBarArtSmall:Show()

        ExpBarArtLarge:Hide()
        ExpBarArtSmall:Show()

        ReputationBarArtLarge:Hide()
        ReputationBarArtSmall:Show()
    end
end

local LARGE_WIDTH = select(2, GetAtlasInfo('hud-MainMenuBar-large'))
local SMALL_WIDTH = select(2, GetAtlasInfo('hud-MainMenuBar-small'))

ReputationWatchBar:EnableMouse(false)
ReputationWatchBar.StatusBar:EnableMouse(false)
ReputationWatchBar.StatusBar:SetParent(ReputationWatchBarDelegate)
ReputationWatchBar.StatusBar:ClearAllPoints()
ReputationWatchBar.StatusBar:SetPoint('BOTTOMLEFT')
ReputationWatchBar.StatusBar:SetPoint('BOTTOMRIGHT')
ReputationWatchBar.OverlayFrame:SetParent(ReputationWatchBarDelegate)
ReputationWatchBar.OverlayFrame:ClearAllPoints()
ReputationWatchBar.OverlayFrame:SetAllPoints(ReputationWatchBar.StatusBar)
ReputationWatchBar.OverlayFrame:EnableMouse(false)

ReputationWatchBarDelegate:SetScript('OnEnter', function()
    return ReputationWatchBar:GetScript('OnEnter')(ReputationWatchBar)
end)
ReputationWatchBarDelegate:SetScript('OnLeave', function()
    return ReputationWatchBar:GetScript('OnLeave')(ReputationWatchBar)
end)

ns.securehook(ReputationWatchBar, 'Hide', function()
    ReputationWatchBarDelegate:Hide()
end)

ns.securehook(ReputationWatchBar, 'Show', function()
    ReputationWatchBarDelegate:Show()
end)

ns.securehook('MultiActionBar_Update', function()
    local isLarge = MultiBarBottomRight:IsShown()
    UpdateWidth(isLarge and LARGE_WIDTH or SMALL_WIDTH)
    UpdateTexture(isLarge)
end)

ns.securehook('MainMenuTrackingBar_Configure', function(ReputationWatchBar)
    if MainMenuExpBar:IsShown() then
        ReputationWatchBarDelegate:ClearAllPoints()
        ReputationWatchBarDelegate:SetPoint('BOTTOM', MainMenuBar, 'BOTTOM', 0, MainMenuExpBar:GetHeight())
    else
        ReputationWatchBarDelegate:ClearAllPoints()
        ReputationWatchBarDelegate:SetPoint('BOTTOM', MainMenuBar, 'BOTTOM', 0, 0)
    end
end)

ns.securehook('MainMenuBarVehicleLeaveButton_Update', function()
    local button = MainMenuBarVehicleLeaveButton
    -- button:Show()
    if not button:IsShown() then
        return
    end

    local _, relativeTo = button:GetPoint()
    if relativeTo == StanceBarFrame then
        button:SetPoint('LEFT', StanceButton1, 'LEFT')
    end
end)

local function SetupShowHide(frame, onShowHide, refs)
    local handle = CreateFrame('Frame', nil, frame, 'SecureHandlerShowHideTemplate')
    handle:SetAttribute('_onshow', onShowHide)
    handle:SetAttribute('_onhide', onShowHide)

    for k, v in pairs(refs) do
        local name
        if type(k) == 'number' then
            name = v:GetName()
        else
            name = k
        end

        assert(name)
        handle:SetFrameRef(name, v)
    end

    ns.runattribute(handle, '_onshow')

    return handle
end

local LayoutMainMenuBar = format([[
local MultiBarBottomRight = self:GetFrameRef('MultiBarBottomRight')
local MainMenuExpBar = self:GetFrameRef('MainMenuExpBar')
local MainMenuBar = self:GetFrameRef('MainMenuBar')

local width = MultiBarBottomRight:IsShown() and %d or %d

MainMenuBar:SetWidth(width)
MainMenuExpBar:SetWidth(width)
]], LARGE_WIDTH, SMALL_WIDTH)

local LayoutWatchBars = [[
local MainMenuExpBar = self:GetFrameRef('MainMenuExpBar')
local ReputationWatchBar = self:GetFrameRef('ReputationWatchBar')
local MainMenuBarArtFrame = self:GetFrameRef('MainMenuBarArtFrame')
local MultiBarBottomLeft = self:GetFrameRef('MultiBarBottomLeft')

local y = 0

local expBar = MainMenuExpBar:IsShown()
local repBar = ReputationWatchBar:IsShown()

if repBar then
    if not expBar then
        y = y + 13
    else
        y = y + 8
    end
end

if expBar then
    y = y + MainMenuExpBar:GetHeight()
end

MainMenuBarArtFrame:SetPoint('BOTTOM', '$parent', 'BOTTOM', 0, y)
]]

local LayoutStanceBar = [[
local StanceButton1 = self:GetFrameRef('StanceButton1')
local ActionButton1 = self:GetFrameRef('ActionButton1')
local MultiBarBottomLeft = self:GetFrameRef('MultiBarBottomLeft')

StanceButton1:ClearAllPoints()
StanceButton1:SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 33, MultiBarBottomLeft:IsShown() and 54 or 11)
]]

local LayoutPetActionBar = [[
local PetActionButton1 = self:GetFrameRef('PetActionButton1')
local ActionButton1 = self:GetFrameRef('ActionButton1')
local MultiBarBottomLeft = self:GetFrameRef('MultiBarBottomLeft')

PetActionButton1:ClearAllPoints()
PetActionButton1:SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 68, MultiBarBottomLeft:IsShown() and 54 or 11)
]]

SetupShowHide(MultiBarBottomLeft, LayoutStanceBar .. LayoutPetActionBar,
              {PetActionButton1, StanceButton1, ActionButton1, MultiBarBottomLeft})
SetupShowHide(MultiBarBottomRight, LayoutMainMenuBar, {MultiBarBottomRight, MainMenuBar, MainMenuExpBar})
SetupShowHide(MainMenuExpBar, LayoutWatchBars,
              {ReputationWatchBar, MainMenuExpBar, MainMenuBarArtFrame, MultiBarBottomLeft})
SetupShowHide(ReputationWatchBar, LayoutWatchBars,
              {ReputationWatchBar, MainMenuExpBar, MainMenuBarArtFrame, MultiBarBottomLeft})
SetupShowHide(PetActionBarFrame, LayoutPetActionBar, {PetActionButton1, ActionButton1, MultiBarBottomLeft})

do -- bags and micro buttons
    local count = 8

    local MicroButtonAndBagsBar = CreateFrame('Frame', nil, MainMenuBar)
    MicroButtonAndBagsBar:SetSize(26 * count + 12, 87)
    MicroButtonAndBagsBar:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT')

    local MicroLeft = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
    MicroLeft:SetPoint('BOTTOMLEFT')
    MicroLeft:SetTexture(1721259)
    MicroLeft:SetSize(30, 43)
    MicroLeft:SetTexCoord(309 / 1024, 339 / 1024, 212 / 256, 255 / 256)

    local MicroMiddle = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
    MicroMiddle:SetPoint('LEFT', MicroLeft, 'RIGHT')
    MicroMiddle:SetTexture(1721259)
    MicroMiddle:SetSize(26 * count - 48, 43)
    MicroMiddle:SetTexCoord(339 / 1024, 577 / 1024, 212 / 256, 255 / 256)

    local MicroRight = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
    MicroRight:SetPoint('LEFT', MicroMiddle, 'RIGHT')
    MicroRight:SetTexture(1721259)
    MicroRight:SetSize(30, 43)
    MicroRight:SetTexCoord(577 / 1024, 607 / 1024, 212 / 256, 255 / 256)

    local BagBg = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND')
    BagBg:SetTexture(1721259)
    BagBg:SetTexCoord(423 / 1024, 607 / 1024, 167 / 256, 212 / 256)
    BagBg:SetSize(607 - 423, 212 - 167)
    BagBg:SetPoint('TOPRIGHT')

    local KeyringBg = MicroButtonAndBagsBar:CreateTexture(nil, 'BACKGROUND', nil, -1)
    KeyringBg:SetTexture(1721259)
    KeyringBg:SetTexCoord(423 / 1024, (423 + 24) / 1024, 167 / 256, 212 / 256)
    KeyringBg:SetSize(24, 212 - 167)
    KeyringBg:SetPoint('BOTTOMRIGHT', BagBg, 'BOTTOMLEFT', 24 - 16, 0)

    MainMenuBarBackpackButton:ClearAllPoints()
    MainMenuBarBackpackButton:SetPoint('TOPRIGHT', MicroButtonAndBagsBar, 'TOPRIGHT', -6, -4)

    for i = 0, 3 do
        local name = 'CharacterBag' .. i .. 'Slot'
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
    KeyRingButton:ClearAllPoints()
    KeyRingButton:SetPoint('RIGHT', CharacterBag3Slot, 'LEFT', -2.5, 0)

    CharacterMicroButton:ClearAllPoints()
    CharacterMicroButton:SetPoint('BOTTOMLEFT', MicroButtonAndBagsBar, 'BOTTOMLEFT', 6, 3)

    -- MainMenuBarPerformanceBarFrame:ClearAllPoints()
    -- MainMenuBarPerformanceBarFrame:SetPoint('TOP', UIParent, 'BOTTOM', 0, -20)

    -- MainMenuBarPerformanceBar:ClearAllPoints()
    -- MainMenuBarPerformanceBar:SetParent(MainMenuMicroButton)
    -- MainMenuBarPerformanceBar:SetSize(28, 8)
    -- MainMenuBarPerformanceBar:SetPoint('CENTER', 0, -5)
    -- MainMenuBarPerformanceBar:SetDrawLayer('OVERLAY')

    -- print(MainMenuBarPerformanceBar)

    -- local MicroButtons = {}

    -- local function UpdateMicroFrame()
    --     local count = 0
    --     for i, v in ipairs(MicroButtons) do
    --         if v:IsShown() then
    --             count = count + 1
    --         end
    --     end

    --     MicroButtonAndBagsBar:SetSize(26 * count + 12, 87)
    --     MicroMiddle:SetSize(26 * count - 48, 43)
    -- end

    -- for i, v in ipairs(MICRO_BUTTONS) do
    --     local button = _G[v]
    --     button:HookScript('OnShow', UpdateMicroFrame)
    --     button:HookScript('OnHide', UpdateMicroFrame)
    --     tinsert(MicroButtons, button)
    -- end
end
