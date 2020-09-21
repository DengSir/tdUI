-- MonkeyQuest.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/6/2019, 2:33:25 AM
---@type ns
local ns = select(2, ...)

ns.addonlogin('MonkeyQuest', function()
    if not MonkeyQuestFrame then
        return
    end

    --- fix for quest tag
    QUEST_TAG_GROUP = 1
    QUEST_TAG_PVP = 41
    QUEST_TAG_RAID = 62
    QUEST_TAG_DUNGEON = 81
    QUEST_TAG_LEGENDARY = 83
    QUEST_TAG_HEROIC = 85
    QUEST_TAG_RAID10 = 0
    QUEST_TAG_RAID25 = 0
    QUEST_TAG_SCENARIO = 98
    QUEST_TAG_ACCOUNT = 102

    -- MONKEYQUEST_TITLE = QUESTS_LABEL

    ---- local
    local nop = nop

    local MonkeyQuestFrame = MonkeyQuestFrame
    local MonkeyQuestTitleButton = MonkeyQuestTitleButton
    local MonkeyQuestMinimizeButton = MonkeyQuestMinimizeButton

    local C = MonkeyQuestConfig[MonkeyQuest.m_global]

    local QuestButtons = ns.GetFrames('MonkeyQuestButton%d', MonkeyQuest.m_iNumQuestButtons, 'Text')

    local LSM = LibStub('LibSharedMedia-3.0')

    ns.WatchManager:Register(MonkeyQuestFrame, 4, { --
        minimizeButton = MonkeyQuestMinimizeButton,
        header = MonkeyQuestTitleButton,
    })

    do -- frame
        MonkeyQuestFrame:SetFrameStrata('BACKGROUND')
        MonkeyQuestFrame:EnableMouse(false)
        MonkeyQuestFrame:SetMouseMotionEnabled(true)
        MonkeyQuestFrame:SetMouseClickEnabled(false)
    end

    do -- header buttons
        MonkeyQuestCloseButton:Hide()
        MonkeyQuestCloseButton.Show = nop

        MonkeyQuestShowHiddenCheckButton:Hide()
        MonkeyQuestShowHiddenCheckButton.Show = nop
    end

    do -- title
        MonkeyQuestTitleButton:EnableMouse(false)

        local TitleText = MonkeyQuestTitleText
        TitleText:SetFontObject('GameFontNormal')
        TitleText:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
        TitleText.SetTextHeight = nop

    end

    do -- minimize button
        local MinimizeLabel = MonkeyQuestMinimizeButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        MinimizeLabel:SetPoint('RIGHT', MonkeyQuestMinimizeButton, 'LEFT', -5, 0)
        MinimizeLabel:SetText(QUESTS_LABEL)

        function MonkeyQuestMinimizeButton:Update()
            if C.m_bMinimized then
                self:Fold()
                MonkeyQuestTitleButton:Hide()
                MinimizeLabel:Show()
            else
                self:Unfold()
                MonkeyQuestTitleButton:Show()
                MinimizeLabel:Hide()
            end
        end

        ns.securehook('MonkeyQuestMinimizeButton_OnClick', function()
            return MonkeyQuestMinimizeButton:Update()
        end)
    end

    local FoldButton = CreateFrame('Button', nil, MonkeyQuestFrame)
    do
        FoldButton:SetSize(16, 16)
        FoldButton:SetPoint('RIGHT', MonkeyQuestMinimizeButton, 'LEFT')
        FoldButton:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]], 'ADD')

        function FoldButton:Fold()
            FoldButton:SetNormalTexture([[Interface\Buttons\UI-PlusButton-UP]])
            FoldButton:SetPushedTexture([[Interface\Buttons\UI-PlusButton-Down]])
            FoldButton:SetDisabledTexture([[Interface\Buttons\UI-PlusButton-Disabled]])
        end

        function FoldButton:Unfold()
            FoldButton:SetNormalTexture([[Interface\Buttons\UI-MinusButton-UP]])
            FoldButton:SetPushedTexture([[Interface\Buttons\UI-MinusButton-Down]])
            FoldButton:SetDisabledTexture([[Interface\Buttons\UI-MinusButton-Disabled]])
        end

        local function IsAllHeaderFold()
            local P = MonkeyQuestConfig[MonkeyQuest.m_strPlayer]
            for k, v in pairs(P.m_aQuestList) do
                if k:find('true$') and v.m_bChecked then
                    return false
                end
            end
            return true
        end

        FoldButton:SetScript('OnClick', function()
            local P = MonkeyQuestConfig[MonkeyQuest.m_strPlayer]
            local unfold = IsAllHeaderFold()

            for k, v in pairs(P.m_aQuestList) do
                if k:find('true$') then
                    v.m_bChecked = unfold
                end
            end

            MonkeyQuest_Refresh()
        end)

        ns.securehook('MonkeyQuest_Refresh', function()
            if not MonkeyQuest.m_bLoaded then
                return
            end

            FoldButton:SetShown(not C.m_bMinimized)

            if IsAllHeaderFold() then
                FoldButton:Fold()
            else
                FoldButton:Unfold()
            end
        end)
    end

    local ScrollFrame = CreateFrame('ScrollFrame', nil, MonkeyQuestFrame)
    local ScrollChild = CreateFrame('Frame', nil, ScrollFrame)

    ScrollChild:SetPoint('TOPLEFT')
    ScrollChild:SetSize(1, 1)

    ScrollFrame:SetPoint('TOPLEFT', MonkeyQuestFrame, 'TOPLEFT', 0, -32)
    ScrollFrame:SetScrollChild(ScrollChild)

    -- local ScrollBar = CreateFrame('Slider', nil, ScrollFrame)
    -- ScrollBar:SetPoint('TOPRIGHT', -5, 0)
    -- ScrollBar:SetPoint('BOTTOMRIGHT', -5, 0)
    -- ScrollBar:SetWidth(10)
    -- ScrollBar:SetThumbTexture([[Interface\BUTTONS\WHITE8X8]])
    -- ScrollBar:SetValue(0)
    -- ScrollBar:SetScript('OnEnter', function(self)
    --     self:SetAlpha(1)
    -- end)
    -- ScrollBar:SetScript('OnLeave', function(self)
    --     self:SetAlpha(0)
    -- end)

    -- ScrollFrame:SetScript('OnScrollRangeChanged', function(self, xrange, yrange)
    --     ScrollBar:SetMinMaxValues(0, yrange)
    -- end)
    ScrollFrame:SetScript('OnMouseWheel', function(self, delta)
        local scroll = self:GetVerticalScroll() - delta * 100
        local maxScroll = self:GetVerticalScrollRange()
        if scroll < 0 then
            scroll = 0
        elseif scroll > maxScroll then
            scroll = maxScroll
        end
        self:SetVerticalScroll(scroll)
    end)
    -- ScrollBar:SetScript('OnValueChanged', function(self, value)
    --     ScrollFrame:SetVerticalScroll(value)
    -- end)

    MonkeyQuestButton1:ClearAllPoints()
    MonkeyQuestButton1:SetPoint('TOPLEFT', ScrollChild, 'TOPLEFT')
    MonkeyQuestButton1:SetPoint('TOPRIGHT', ScrollChild, 'TOPRIGHT')
    MonkeyQuestButton1.ClearAllPoints = nop
    MonkeyQuestButton1.SetPoint = nop

    for _, button in ipairs(QuestButtons) do
        button:SetParent(ScrollChild)
    end

    local function Apply()
        MonkeyQuestInit_ApplySettings()
        MonkeyQuestFrame:SetWidth(ns.profile.watch.frame.width)
        ScrollFrame:SetWidth(ns.profile.watch.frame.width)
        ScrollChild:SetWidth(ns.profile.watch.frame.width)
    end

    local function Reset()
        local defaults = {
            m_bAllowRightClick = false,
            m_bAlwaysHeaders = true,
            m_bColourDoneOrFailed = false,
            m_bColourSubObjectivesByProgress = false,
            m_bColourTitle = true,
            m_bCrashBorder = false,
            m_bDisplay = true,
            m_bGrowUp = false,
            m_bHideCompletedObjectives = true,
            m_bHideCompletedQuests = false,
            m_bHideHeader = false,
            m_bHideQuestsEnabled = false,
            m_bHideTitle = true,
            m_bHideTitleButtons = false,
            m_bItemsEnabled = false,
            m_bItemsOnLeft = false,
            m_bLocked = true,
            m_bNoBorder = true,
            m_bNoHeaders = false,
            m_bObjectives = false,
            m_bShowDailyNumQuests = false,
            m_bShowHidden = false,
            m_bShowNoobTips = false,
            m_bShowNumQuests = true,
            m_bShowQuestLevel = true,
            m_bShowQuestTextTooltip = false,
            m_bShowTooltipObjectives = true,
            m_bShowZoneHighlight = false,
            m_bWorkComplete = false,
            m_iAlpha = 0,
            m_iFont = 2,
            m_iFontHeight = 15,
            m_iFrameAlpha = 1,
            m_iHighlightAlpha = 1,
            m_iQuestPadding = 2,
        }

        for k, v in pairs(defaults) do
            C[k] = v
        end
    end

    local function UpdateShown()
        local shouldShow = GetNumQuestLogEntries() > 0
        if shouldShow ~= MonkeyQuestFrame:IsShown() then
            MonkeyQuestFrame:SetShown(shouldShow)

            if shouldShow then
                MonkeyQuest_Refresh()
            end
        end
    end

    local function UpdateHeight()
        local visibleHeight = MonkeyQuestFrame:GetTop() - 32 -
                                  (ns.profile.actionbar.micro.position == 'RIGHT' and 88 or 20)
        local totalHeight = 0

        for _, button in ipairs(QuestButtons) do
            if button:IsShown() then
                totalHeight = totalHeight + button.Text:GetHeight() + C.m_iQuestPadding
            end
        end

        ScrollChild:SetHeight(totalHeight)
        ScrollFrame:SetHeight(min(visibleHeight, totalHeight))
        MonkeyQuestFrame:SetHeight(min(visibleHeight, totalHeight) + 32)
    end

    local function ResetAndApply()
        Reset()
        Apply()
    end

    local function Init()
        if not C._tdui then
            C._tdui = true
            Reset()
        end
    end

    ns.securehook('MonkeyQuest_Resize', function()
        ns.WatchManager:Refresh()
    end)

    ns.override('MonkeyQuestInit_ResetConfig', ResetAndApply)
    ns.override('MonkeyQuestInit_ResetConfigToBlizzardStyle', ResetAndApply)
    ns.securehook('MonkeyQuestInit_LoadConfig', Init)
    ns.securehook('MonkeyQuestInit_ApplySettings', function()
        MonkeyQuestMinimizeButton:Update()
    end)

    ns.event('QUEST_LOG_UPDATE', UpdateShown)
    ns.config('watch.frame.width', Apply)
    ns.config('actionbar.micro.position', UpdateHeight)

    ns.event('!WATCH_LAYOUT', function()
        ns.pending(MonkeyQuestFrame, UpdateHeight)
    end)

    ns.hook('MonkeyQuestButton_OnClick', function(orig, self, button, down)
        if IsShiftKeyDown() and button == 'LeftButton' then
            local title, level, _, isHeader, _, _, _, questId = GetQuestLogTitle(self.m_iQuestIndex);
            if not isHeader then
                local activeWindow = ChatEdit_GetActiveWindow()
                if activeWindow and activeWindow:HasFocus() then
                    return activeWindow:Insert(format('[%s (%d)]', title, questId))
                end
            end
        end
        return orig(self, button, down)
    end)

    ns.login(function()
        Init()
        Apply()
        UpdateShown()
    end)
end)
