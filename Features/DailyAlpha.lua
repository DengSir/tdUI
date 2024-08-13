-- DailyAlpha.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/14/2024, 12:10:09 AM
--
---@type ns
local ns = select(2, ...)

local QUESTS = {83713, 83714}
local TYPE = 2485

local Frame

local function Ok()
    for _, id in ipairs(QUESTS) do
        if not (C_QuestLog.IsQuestFlaggedCompleted(id) or C_QuestLog.IsOnQuest(id)) then
            return false
        end
    end
    return true
end

local function Run()
    if LFDQueueFrame.type == TYPE and not Ok() then
        Frame = Frame or CreateFrame('Frame')
        Frame:SetParent(LFDQueueFrame)
        Frame:SetFrameLevel(LFDQueueFrame:GetFrameLevel() + 100)
        Frame:SetPoint('TOPLEFT', LFDQueueFrame, 'TOPLEFT', 3, -148)
        Frame:SetPoint('BOTTOMRIGHT', LFDQueueFrame, 'BOTTOMRIGHT', -7, 26)
        Frame:EnableMouse(true)
        Frame:Show()
        Frame.Background = Frame.Background or Frame:CreateTexture(nil, 'BACKGROUND')
        Frame.Background:SetColorTexture(0, 0, 0, 0.95)
        Frame.Background:SetAllPoints()
        Frame.Text = Frame.Text or Frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        Frame.Text:SetPoint('CENTER', Frame, 'CENTER')
        Frame.Text:SetText('请先接取每日任务')
    elseif Frame then
        Frame:Hide()
    end
end

ns.securehook('LFDQueueFrame_SetType', Run)
ns.event('UNIT_QUEST_LOG_CHANGED', Run)
ns.login(function()
    if not Ok() then
        LFDQueueFrame_SetType(TYPE)
    end
end)
