-- DailyAlpha.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/14/2024, 12:10:09 AM
--
---@type ns
local ns = select(2, ...)

local TYPES = {2447, 2470, 2485}
local QUESTS = { --
    [2447] = {78752, 78753},
    [2470] = {83717, 87379},
    [2485] = {83713, 83714},
}

local function Ok(id)
    for _, quest in ipairs(QUESTS[id]) do
        if not (C_QuestLog.IsQuestFlaggedCompleted(quest) or C_QuestLog.IsOnQuest(quest)) then
            return false
        end
    end
    return true
end

local function IsComplete(id)
    for _, quest in ipairs(QUESTS[id]) do
        if not C_QuestLog.IsQuestFlaggedCompleted(quest) then
            return false
        end
    end
    return true
end

local Overlaies = {}

local function GetOverlay(parent)
    return Overlaies[parent]
end

local function CreateOverlay(parent)
    local overlay = CreateFrame('Frame', nil, parent)
    overlay:SetFrameLevel(parent:GetFrameLevel() + 100)
    overlay:EnableMouse(true)
    overlay:Show()

    if parent == LFDQueueFrame then
        overlay:SetAllPoints(LFDQueueFrameCooldownFrame)
    else
        overlay:SetPoint('TOPLEFT', 10, -10)
        overlay:SetPoint('BOTTOMRIGHT', -10, 10)
    end

    local Background = overlay:CreateTexture(nil, 'BACKGROUND')
    Background:SetColorTexture(0, 0, 0, 0.93)
    Background:SetAllPoints()

    local Text = overlay:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    Text:SetPoint('CENTER')
    Text:SetText('请先接取每日任务')

    Overlaies[parent] = overlay
    return overlay
end

local function ToggleOverlay(parent, shown)
    if shown then
        local overlay = GetOverlay(parent) or CreateOverlay(parent)
        overlay:Show()
    else
        local overlay = GetOverlay(parent)
        if overlay then
            overlay:Hide()
        end
    end
end

local usable = {}
local function Resolve()
    wipe(usable)

    for i = 1, GetNumRandomDungeons() do
        local id = GetLFGRandomDungeonInfo(i)
        local isAvailableForAll, isAvailableForPlayer, hideIfNotJoinable = IsLFGDungeonJoinable(id)
        if isAvailableForPlayer and not hideIfNotJoinable then
            usable[id] = true
        end
    end

    for _, id in ipairs(TYPES) do
        if usable[id] then
            return id
        end
    end
end

local function ForQueueFrame()
    local parent = LFDQueueFrame
    local id = Resolve()
    ToggleOverlay(parent, id and parent:IsShown() and not LFDQueueFrameCooldownFrame:IsShown() and not Ok(id))
end

local function ForReadyDialog()
    local parent = LFGDungeonReadyDialog
    local id = Resolve()
    ToggleOverlay(parent, id and parent:IsShown() and not Ok(id))
end

ns.event('UNIT_QUEST_LOG_CHANGED', function()
    ForQueueFrame()
    ForReadyDialog()
end)

ns.securehook('LFDQueueFrame_SetType', ForQueueFrame)
ns.hookscript(LFDQueueFrameCooldownFrame, 'OnShow', ForQueueFrame)
ns.hookscript(LFDQueueFrameCooldownFrame, 'OnHide', ForQueueFrame)
ns.hookscript(LFGDungeonReadyDialog, 'OnShow', ForReadyDialog)

ns.hookscript(LFDQueueFrame, 'OnShow', function()
    local id = Resolve()
    if id and not IsComplete(id) then
        LFDQueueFrame_SetType(id)
    end
end)
