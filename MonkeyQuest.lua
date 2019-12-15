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

MonkeyQuestFrame:SetFrameStrata('BACKGROUND')
