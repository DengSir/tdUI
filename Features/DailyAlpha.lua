-- DailyAlpha.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/14/2024, 12:10:09 AM
--
---@type ns
local ns = select(2, ...)

local QUESTS = {83713, 83714}
local TYPE = 2485

local Overlay

local function Ok()
    for _, id in ipairs(QUESTS) do
        if not (C_QuestLog.IsQuestFlaggedCompleted(id) or C_QuestLog.IsOnQuest(id)) then
            return false
        end
    end
    return true
end

local function IsComplete()
    for _, id in ipairs(QUESTS) do
        if not C_QuestLog.IsQuestFlaggedCompleted(id) then
            return false
        end
    end
    return true
end

local function CreateOverlay()
    Overlay = CreateFrame('Frame', nil, LFDQueueFrame)
    Overlay:SetFrameLevel(LFDQueueFrame:GetFrameLevel() + 100)
    Overlay:SetAllPoints(LFDQueueFrameCooldownFrame)
    Overlay:EnableMouse(true)
    Overlay:Show()

    local Background = Overlay:CreateTexture(nil, 'BACKGROUND')
    Background:SetColorTexture(0, 0, 0, 0.93)
    Background:SetAllPoints()

    local Text = Overlay:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    Text:SetPoint('CENTER')
    Text:SetText('请先接取每日任务')
end

local function Run()
    if LFDQueueFrame.type == TYPE and LFDQueueFrame:IsShown() and not LFDQueueFrameCooldownFrame:IsShown() and not Ok() then
        if not Overlay then
            CreateOverlay()
        end
        Overlay:Show()
    elseif Overlay then
        Overlay:Hide()
    end
end

ns.event('UNIT_QUEST_LOG_CHANGED', Run)
ns.securehook('LFDQueueFrame_SetType', Run)
ns.hookscript(LFDQueueFrameCooldownFrame, 'OnShow', Run)
ns.hookscript(LFDQueueFrameCooldownFrame, 'OnHide', Run)
ns.hookscript(LFDQueueFrame, 'OnShow', function()
    if not IsComplete() then
        LFDQueueFrame_SetType(TYPE)
    end
end)
