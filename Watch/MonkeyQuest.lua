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

    -- MonkeyQuestFrame:SetClipsChildren(true)

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

    local Window = MonkeyQuestFrame
    local TitleButton = MonkeyQuestTitleButton
    local MinimizeButton = MonkeyQuestMinimizeButton

    ns.WatchManager:Register(MonkeyQuestFrame, 4, { --
        minimizeButton = MinimizeButton,
        header = TitleButton,
    })

    do -- frame
        Window:SetFrameStrata('BACKGROUND')
        Window:EnableMouse(false)
        Window:SetMouseMotionEnabled(true)
        Window:SetMouseClickEnabled(false)
    end

    do -- header buttons
        MonkeyQuestCloseButton:Hide()
        MonkeyQuestCloseButton.Show = nop

        MonkeyQuestShowHiddenCheckButton:Hide()
        MonkeyQuestShowHiddenCheckButton.Show = nop
    end

    do -- title
        TitleButton:EnableMouse(false)

        local TitleText = MonkeyQuestTitleText
        TitleText:SetFontObject('GameFontNormal')
        TitleText:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
        TitleText.SetTextHeight = nop

        MonkeyQuestButton1:SetPoint('TOPLEFT', Window, 'TOPLEFT', 0, -32)
    end

    do -- minimize button
        local MinimizeLabel = MinimizeButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        MinimizeLabel:SetPoint('RIGHT', MinimizeButton, 'LEFT', -5, 0)
        MinimizeLabel:SetText(QUESTS_LABEL)

        function MinimizeButton:Update()
            if MonkeyQuestConfig[MonkeyQuest.m_global].m_bMinimized then
                self:Fold()
                TitleButton:Hide()
                MinimizeLabel:Show()
            else
                self:Unfold()
                TitleButton:Show()
                MinimizeLabel:Hide()
            end
        end

        MinimizeButton:HookScript('OnClick', MinimizeButton.Update)
    end

    local ScrollFrame = CreateFrame('ScrollFrame', nil, MonkeyQuestFrame)
    local ScrollChild = CreateFrame('Frame', nil, ScrollFrame)

    ScrollChild:SetPoint('TOPLEFT')
    ScrollChild:SetSize(1, 1)

    ScrollFrame:SetScrollChild(ScrollChild)
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

    for i = 1, MonkeyQuestButton1:GetNumPoints() do
        ScrollFrame:SetPoint(MonkeyQuestButton1:GetPoint(i))
    end

    MonkeyQuestButton1:ClearAllPoints()
    MonkeyQuestButton1:SetPoint('TOPLEFT', ScrollChild, 'TOPLEFT')
    MonkeyQuestButton1:SetPoint('TOPRIGHT', ScrollChild, 'TOPRIGHT')
    MonkeyQuestButton1.ClearAllPoints = nop
    MonkeyQuestButton1.SetPoint = nop

    local function Hide()
        MonkeyQuestConfig[MonkeyQuest.m_global].m_bMinimized = true
        MinimizeButton:Update()
        MonkeyQuest_Refresh()
    end

    local function Apply()
        MonkeyQuestConfig[MonkeyQuest.m_global].m_iFrameWidth = ns.profile.watch.frame.width
        MonkeyQuestInit_ApplySettings()

        ScrollFrame:SetWidth(ns.profile.watch.frame.width)
        ScrollChild:SetWidth(ns.profile.watch.frame.width)
    end

    local function Reset()
        local db = MonkeyQuestConfig[MonkeyQuest.m_global]
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
            m_iQuestPadding = 0,
        }

        for k, v in pairs(defaults) do
            db[k] = v
        end
    end

    local function Update()
        local shouldShow = GetNumQuestLogEntries() > 0
        if shouldShow ~= Window:IsShown() then
            Window:SetShown(shouldShow)

            if shouldShow then
                MonkeyQuest_Refresh()
            end
        end
    end

    for i = 1, MonkeyQuest.m_iNumQuestButtons do
        local button = _G['MonkeyQuestButton' .. i]
        local text = _G['MonkeyQuestButton' .. i .. 'Text']

        text:ClearAllPoints()
        text:SetPoint('BOTTOMLEFT')

        button:SetParent(ScrollChild)
    end

    local function UpdateHeight()
        local visibleHeight = MonkeyQuestFrame:GetTop() - 32 -
                                  (ns.profile.actionbar.micro.position == 'RIGHT' and 88 or 20)
        local totalHeight = 0

        for i = 1, MonkeyQuest.m_iNumQuestButtons do
            local button = _G['MonkeyQuestButton' .. i]
            if button:IsShown() then
                local text = _G['MonkeyQuestButton' .. i .. 'Text']
                local height = text:GetHeight() + 2

                button:SetHeight(height)
                totalHeight = totalHeight + height
            end
        end

        ScrollChild:SetHeight(totalHeight)
        ScrollFrame:SetHeight(min(visibleHeight, totalHeight))
        MonkeyQuestFrame:SetHeight(min(visibleHeight, totalHeight) + 32)
    end

    ns.securehook('MonkeyQuest_Resize', function()
        ns.WatchManager:Refresh()
    end)

    ns.override('MonkeyQuestInit_ResetConfig', function()
        Reset()
        Apply()
    end)

    ns.securehook('MonkeyQuestInit_LoadConfig', function()
        local db = MonkeyQuestConfig[MonkeyQuest.m_global]
        if not db._tdui then
            db._tdui = true
            Reset()
        end
    end)

    ns.securehook('MonkeyQuestInit_ApplySettings', function()
        MinimizeButton:Update()
    end)

    ns.event('QUEST_LOG_UPDATE', Update)
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
        MonkeyQuestInit_LoadConfig()
        Apply()
        Update()
    end)
end)
