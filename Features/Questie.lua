-- Questie.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/4/2026, 10:19:29 PM
--
---@type  ns
local ns = select(2, ...)

ns.addon('Questie', function()
    local Questie = _G.Questie
    local TrackerBaseFrame = QuestieLoader:ImportModule('TrackerBaseFrame')
    local TrackerLine = QuestieLoader:ImportModule('TrackerLine')
    local TrackerUtils = QuestieLoader:ImportModule('TrackerUtils')
    local TrackerLinePool = QuestieLoader:ImportModule('TrackerLinePool')
    local TrackerHeaderFrame = QuestieLoader:ImportModule('TrackerHeaderFrame')

    local l10n = QuestieLoader:ImportModule('l10n')
    -- local QuestieOptions = QuestieLoader:CreateModule('QuestieOptions')

    if GetLocale() == 'zhCN' then
        l10n.translations['Questie Tracker'].zhCN = QUESTS_LABEL
        l10n.translations[': '].zhCN = ' '
    end

    ns.hook(TrackerBaseFrame, 'Initialize', function(orig, ...)
        local baseFrame = orig(...)
        baseFrame:SetFrameStrata('LOW')
        return baseFrame
    end)

    local function GenerateControlQuest(func)
        return function(id)
            local lastQuest = GetQuestLogSelection()
            SelectQuestLogEntry(GetQuestLogIndexByID(id))
            func()
            SelectQuestLogEntry(lastQuest)
        end
    end

    local ShareQuest = GenerateControlQuest(QuestLogPushQuest)
    local AbandonQuet = GenerateControlQuest(function()
        SetAbandonQuest()

        local items = GetAbandonQuestItems()
        if items then
            StaticPopup_Hide('ABANDON_QUEST')
            StaticPopup_Show('ABANDON_QUEST_WITH_ITEMS', GetAbandonQuestName(), items)
        else
            StaticPopup_Hide('ABANDON_QUEST_WITH_ITEMS')
            StaticPopup_Show('ABANDON_QUEST', GetAbandonQuestName())
        end
    end)

    local orig_OnClickQuest

    local function OnQuestClick(self, button)
        if TrackerUtils:IsBindTrue('ctrlright', button) then
            AbandonQuet(self.Quest.Id)
        elseif TrackerUtils:IsBindTrue('ctrlleft', button) then
            ShareQuest(self.Quest.Id)
        else
            orig_OnClickQuest(self, button)
        end
    end

    local function SetOnClick(orig, self, onClickMode)
        orig(self, onClickMode)

        if onClickMode == 'quest' then

            if not orig_OnClickQuest then
                orig_OnClickQuest = self:GetScript('OnClick')
            end

            self:SetScript('OnClick', OnQuestClick)
        end
    end

    local function ExpandButtonShow(orig, self)
        orig(self)

        self:ClearAllPoints()
        self:SetPoint('TOPLEFT', self:GetParent(), 'TOPLEFT', 26, 0)
    end

    ns.hook(TrackerLine, 'New', function(orig, ...)
        local line = orig(...)
        ns.hook(line, 'SetOnClick', SetOnClick)
        ns.hook(line.expandZone, 'Show', ExpandButtonShow)
        return line
    end)

    ns.hook(TrackerLinePool, 'GetZoneLine', function(orig, ...)
        local line = orig(...)
        line.label:SetPoint('TOPLEFT', line, 'TOPLEFT', 26, 0)
        return line
    end)

    ns.securehook(TrackerHeaderFrame, 'Update', function()
        local header = _G.Questie_HeaderFrame
        local parent = header:GetParent()
        local icon = header.questieIcon

        local delta = 14

        if Questie.db.profile.trackerHeaderEnabled or (not TrackerUtils.HasQuest()) then
            icon:SetPoint('TOPLEFT', header, 'TOPLEFT', 6 + delta, 0)
            header:SetWidth(header.trackedQuests.label:GetStringWidth() + delta + icon:GetWidth() + 12)
        else
            if Questie.db.profile.moveHeaderToBottom then
                icon:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -4 + delta, 8)
            else
                icon:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', -4 + delta, -8)
            end
        end
    end)
end)
