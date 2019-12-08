-- QuestVendo.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/5/2019, 3:47:59 PM

local select = select
local QuestInfoFrame = QuestInfoFrame

local GetItemInfo = GetItemInfo
local GetNumQuestChoices = GetNumQuestChoices
local GetQuestItemInfo = GetQuestItemInfo
local GetQuestItemLink = GetQuestItemLink
local QuestInfo_GetRewardButton = QuestInfo_GetRewardButton

local QuestVendo = CreateFrame('Frame', nil, QuestRewardScrollChildFrame)
QuestVendo:Hide()
QuestVendo:SetSize(18, 18)
QuestVendo:RegisterEvent('QUEST_COMPLETE')
QuestVendo:RegisterEvent('QUEST_ITEM_UPDATE')
QuestVendo:RegisterEvent('GET_ITEM_INFO_RECEIVED')
QuestVendo:SetScript('OnEvent', function(self)
    self:Hide()

    local choice = GetNumQuestChoices()
    if choice <= 1 then
        return
    end

    local bestPrice, index = 0
    for i = 1, choice do
        local link = GetQuestItemLink('choice', i)
        local count = select(3, GetQuestItemInfo('choice', i))
        if not link then
            return
        end

        local price = (link and select(11, GetItemInfo(link)) or 0) * (count or 1)
        if price > bestPrice then
            bestPrice = price
            index = i
        end
    end

    if index then
        local button = QuestInfo_GetRewardButton(QuestInfoFrame.rewardsFrame, index)
        self:ClearAllPoints()
        self:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -5, 0)
        self:SetFrameLevel(button:GetFrameLevel() + 10)
        self:Show()
    end
end)
