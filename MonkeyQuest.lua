-- MonkeyQuest.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/6/2019, 2:33:25 AM

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

MonkeyQuestOptions = nop

---- local
local nop = nop

local MonkeyQuestFrame = MonkeyQuestFrame
local MonkeyQuestTitleText = MonkeyQuestTitleText
local MonkeyQuestTitleButton = MonkeyQuestTitleButton
local MonkeyQuestCloseButton = MonkeyQuestCloseButton
local MonkeyQuestMinimizeButton = MonkeyQuestMinimizeButton
local MonkeyQuestShowHiddenCheckButton = MonkeyQuestShowHiddenCheckButton

local MonkeyQuestButton1 = MonkeyQuestButton1

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
    local bg = MonkeyQuestTitleButton:CreateTexture(nil, 'BACKGROUND')
    bg:SetAtlas('Objective-Header', true)
    bg:SetPoint('TOPLEFT', -25, 20)

    MonkeyQuestFrame:HookScript('OnSizeChanged', function(self)
        bg:SetWidth(self:GetWidth() + 20)
    end)

    MonkeyQuestTitleText:SetFontObject('GameFontNormal')
    MonkeyQuestTitleText:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
    MonkeyQuestTitleText.SetTextHeight = nop

    MonkeyQuestButton1:SetPoint('TOPLEFT', MonkeyQuestTitleButton, 'BOTTOMLEFT', 0, -7)
end

do -- minimize button
    MonkeyQuestMinimizeButton:SetPoint(MonkeyQuestCloseButton:GetPoint())
    MonkeyQuestMinimizeButton:SetSize(16, 16)
    MonkeyQuestMinimizeButton:SetNormalTexture([[Interface\Buttons\UI-Panel-QuestHideButton]])
    MonkeyQuestMinimizeButton:SetPushedTexture([[Interface\Buttons\UI-Panel-QuestHideButton]])
    MonkeyQuestMinimizeButton:SetHighlightTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]], 'ADD')
    MonkeyQuestMinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
    MonkeyQuestMinimizeButton:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1)
    MonkeyQuestMinimizeButton.SetNormalTexture = nop

    local MinimizeLabel = MonkeyQuestMinimizeButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    MinimizeLabel:SetPoint('RIGHT', MonkeyQuestMinimizeButton, 'LEFT', -5, 0)
    MinimizeLabel:SetText(QUESTS_LABEL)

    function MonkeyQuestMinimizeButton:Update()
        if MonkeyQuestConfig[MonkeyQuest.m_global].m_bMinimized then
            MonkeyQuestMinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)
            MonkeyQuestMinimizeButton:GetPushedTexture():SetTexCoord(0.5, 1, 0, 0.5)
            MonkeyQuestTitleButton:Hide()
            MinimizeLabel:Show()
        else
            MonkeyQuestMinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
            MonkeyQuestMinimizeButton:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1)
            MonkeyQuestTitleButton:Show()
            MinimizeLabel:Hide()
        end
    end

    MonkeyQuestMinimizeButton:HookScript('OnClick', MonkeyQuestMinimizeButton.Update)
end

local function Hook(name, func)
    local orig = _G[name]
    _G[name] = function(...)
        orig(...)
        func(...)
    end
end

Hook('MonkeyQuest_Resize', function()
    MonkeyQuestFrame:ClearAllPoints()
    MonkeyQuestFrame:SetPoint('TOPRIGHT', QuestWatchFrame, 'TOPRIGHT', 0, 0)
end)

Hook('MonkeyQuestInit_LoadConfig', function()
    local db = MonkeyQuestConfig[MonkeyQuest.m_global]
    if db.__tdloaded then
        return
    end

    db.__tdloaded = true

    local CONFIG = {
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

    for k, v in pairs(CONFIG) do
        db[k] = v
    end

    MonkeyQuestInit_ApplySettings()
end)

Hook('MonkeyQuestInit_ApplySettings', function()
    MonkeyQuestMinimizeButton:Update()
end)

Hook('MonkeyQuest_OnEvent', function(_, event)
    if event == 'QUEST_LOG_UPDATE' then
        local shouldShow = GetNumQuestLogEntries() > 0
        if shouldShow ~= MonkeyQuestFrame:IsShown() then
            MonkeyQuestFrame:SetShown(GetNumQuestLogEntries() > 0)

            if shouldShow then
                MonkeyQuest_Refresh()
            end
        end
    end
end)
