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

    local function Hide()
        MonkeyQuestConfig[MonkeyQuest.m_global].m_bMinimized = true
        MinimizeButton:Update()
        MonkeyQuest_Refresh()
    end

    local function Apply()
        MonkeyQuestConfig[MonkeyQuest.m_global].m_iFrameWidth = ns.profile.watch.frame.width
        MonkeyQuestInit_ApplySettings()
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

    ns.securehook('MonkeyQuest_OnEvent', function(_, event)
        if event == 'QUEST_LOG_UPDATE' then
            local shouldShow = GetNumQuestLogEntries() > 0
            if shouldShow ~= Window:IsShown() then
                Window:SetShown(shouldShow)

                if shouldShow then
                    MonkeyQuest_Refresh()
                end
            end
        end
    end)

    ns.config('watch.frame.width', Apply)

    ns.load(function()
        MonkeyQuestInit_LoadConfig()
        Apply()
    end)
end)
