-- MonkeyQuest.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/6/2019, 2:33:25 AM

if not MonkeyQuestFrame then
    return
end

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

MONKEYQUEST_TITLE = QUESTS_LABEL

MonkeyQuestFrame:EnableMouse(false)
MonkeyQuestFrame:SetMouseMotionEnabled(true)
MonkeyQuestFrame:SetMouseClickEnabled(false)
MonkeyQuestFrame:SetFrameStrata('BACKGROUND')

MonkeyQuestCloseButton:Hide()
MonkeyQuestCloseButton.Show = nop

MonkeyQuestShowHiddenCheckButton:Hide()
MonkeyQuestShowHiddenCheckButton.Show = nop

MonkeyQuestTitleButton:EnableMouse(false)
local bg = MonkeyQuestTitleButton:CreateTexture(nil, 'BACKGROUND')
bg:SetAtlas('Objective-Header', true)
bg:SetPoint('TOPLEFT', -15, 20)
bg:SetWidth(280)

MonkeyQuestTitleText:SetFontObject('GameFontNormal')
MonkeyQuestTitleText:SetPoint('TOPLEFT', 10, 0)
MonkeyQuestTitleText:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
MonkeyQuestTitleText.SetTextHeight = nop

MonkeyQuestButton1:SetPoint('TOPLEFT', MonkeyQuestTitleButton, 'BOTTOMLEFT', 0, -10)

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

hooksecurefunc('MonkeyQuest_Refresh', function()
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
end)

hooksecurefunc('MonkeyQuest_Resize', function()
    MonkeyQuestFrame:ClearAllPoints()
    MonkeyQuestFrame:SetPoint('TOPRIGHT', QuestWatchFrame, 'TOPRIGHT', 0, 10)
end)

hooksecurefunc('MonkeyQuestInit_LoadConfig', function()
    local db = MonkeyQuestConfig[MonkeyQuest.m_global]
    if db.__tdloaded then
        return
    end

    db.__tdloaded = true

    local CONFIG = {
        ['m_bAllowRightClick'] = true,
        ['m_bAlwaysHeaders'] = true,
        ['m_bColourDoneOrFailed'] = false,
        ['m_bColourSubObjectivesByProgress'] = false,
        ['m_bColourTitle'] = true,
        ['m_bCrashBorder'] = false,
        ['m_bDisplay'] = true,
        ['m_bGrowUp'] = false,
        ['m_bHideCompletedObjectives'] = false,
        ['m_bHideCompletedQuests'] = false,
        ['m_bHideHeader'] = false,
        ['m_bHideQuestsEnabled'] = false,
        ['m_bHideTitle'] = false,
        ['m_bHideTitleButtons'] = false,
        ['m_bItemsEnabled'] = false,
        ['m_bItemsOnLeft'] = false,
        ['m_bLocked'] = true,
        ['m_bNoBorder'] = true,
        ['m_bNoHeaders'] = false,
        ['m_bObjectives'] = false,
        ['m_bShowDailyNumQuests'] = false,
        ['m_bShowHidden'] = false,
        ['m_bShowNoobTips'] = false,
        ['m_bShowNumQuests'] = true,
        ['m_bShowQuestLevel'] = true,
        ['m_bShowQuestTextTooltip'] = false,
        ['m_bShowTooltipObjectives'] = true,
        ['m_bShowZoneHighlight'] = false,
        ['m_bWorkComplete'] = false,
        ['m_iAlpha'] = 0,
        ['m_iFont'] = 2,
        ['m_iFontHeight'] = 15,
        ['m_iFrameAlpha'] = 1,
        ['m_iHighlightAlpha'] = 1,
        ['m_iQuestPadding'] = 2,
    }

    for k, v in pairs(CONFIG) do
        db[k] = v
    end

    MonkeyQuestInit_ApplySettings()
end)
