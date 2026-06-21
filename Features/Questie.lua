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
    local QuestieReputation = QuestieLoader:ImportModule('QuestieReputation')

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

    local function ShowQuestMap(line)
        local quest = line.Quest
        if quest and (quest.isComplete or quest.wasComplete) then
            ns.ShowUIPanel(WorldMapFrame)
            TrackerUtils:ShowFinisherOnMap(quest)
            return
        end

        local objective = line.Objective
        if objective and objective.Description then
            ns.ShowUIPanel(WorldMapFrame)
            TrackerUtils:ShowObjectiveOnMap(objective)
        end
    end

    local orig_OnClickQuest

    local function OnQuestClick(self, button)
        if TrackerUtils:IsBindTrue('altleft', button) then
            ShowQuestMap(self)
        elseif TrackerUtils:IsBindTrue('ctrlright', button) then
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

    ns.securehook(TrackerLinePool, 'OnHighlightEnter', function(line)
        if line.mode ~= 'quest' then
            return
        end
        local quest = line.Quest
        if not quest then
            return
        end

        GameTooltip:SetOwner(Questie_BaseFrame, 'ANCHOR_TOPLEFT', 20, -8)
        GameTooltip:SetText(quest.LocalizedName or quest.name, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g,
                            NORMAL_FONT_COLOR.b)

        local description = quest.Description
        if description then
            for _, v in ipairs(description) do
                GameTooltip:AddLine(v, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true)
            end
        end

        -- local questFlags = quest.questFlags
        -- if bit.band(questFlags, 4096) > 0 then
        --     QuestUtils_AddQuestTagLineToTooltip(GameTooltip, DAILY, 'DAILY', nil, NORMAL_FONT_COLOR)
        -- end
        -- if bit.band(questFlags, 32768) > 0 then
        --     QuestUtils_AddQuestTagLineToTooltip(GameTooltip, WEEKLY, 'WEEKLY', nil, NORMAL_FONT_COLOR)
        -- end
        -- if bit.band(questFlags, 8192) > 0 then
        --     QuestUtils_AddQuestTagLineToTooltip(GameTooltip, Enum.QuestTag.PvP, 'PVP', nil, NORMAL_FONT_COLOR)
        -- end
        -- if bit.band(questFlags, 64) > 0 then
        --     QuestUtils_AddQuestTagLineToTooltip(GameTooltip, Enum.QuestTag.Raid, 'RAID', nil, NORMAL_FONT_COLOR)
        -- end

        local reputationReward = QuestieReputation.GetReputationReward(quest.Id)
        local rewardString = QuestieReputation.GetReputationRewardString(reputationReward)

        if rewardString and rewardString ~= '' then
            GameTooltip:AddLine(rewardString, 0, 1, 1)
            GameTooltip:AddTexture([[Interface\AddOns\Questie\Icons\reputation]])
        end
        GameTooltip:Show()
    end)

    ns.securehook(TrackerLinePool, 'OnHighlightLeave', GameTooltip_Hide)

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

    -- ns.securehook('QuestLog_UpdateQuestDetails', function()
    --     local questId = QuestInfoFrame.questLog and GetQuestLogSelectedID() or GetQuestID()
    --     print(questId)
    --     local reputationReward = QuestieReputation.GetReputationReward(questId)
    --     local rewardString = QuestieReputation.GetReputationRewardString(reputationReward)

    --     print(rewardString)
    -- end)
end)
