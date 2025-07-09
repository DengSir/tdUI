-- Roll.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/9/2025, 4:53:31 PM
--
---@class ns
local ns = select(2, ...)

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local frames = {}
local buttonKeys = {
    -- [0] = 'PassButton',
    [1] = 'NeedButton',
    [2] = 'GreedButton',
    -- [3] = 'DisenchantButton',
}

local function ButtonOnEnter(self)
    local rollId = self:GetParent().rollID
    local rollType = self:GetID()
    local _, _, numPlayers = C_LootHistory.GetItem(rollId)

    for i = 1, numPlayers do
        local name, class, playerRollType = C_LootHistory.GetPlayerInfo(rollId, i)
        if playerRollType == rollType then
            local color = RAID_CLASS_COLORS[class or 'PRIEST']
            GameTooltip:AddLine(name, color.r, color.g, color.b)
        end
    end

    GameTooltip:Show()
end

local function ButtonOnClick(self)
    local rollId = self:GetParent().rollID
    local rollType = self:GetID()

    if IsShiftKeyDown() or IsControlKeyDown() then
        ConfirmLootRoll(rollId, rollType)
    else
        RollOnLoot(rollId, rollType)
    end
end

local function FrameOnShow(frame)
    for _, v in pairs(buttonKeys) do
        frame[v]:SetText('0')
    end
end

local function SetupFrame(frame)
    if not frame then
        return
    end

    for _, v in pairs(buttonKeys) do
        local button = frame[v]
        if button then
            button:SetNormalFontObject('GameFontHighlightOutline')
            button:SetDisabledFontObject('GameFontHighlightOutline')
            button:HookScript('OnEnter', ButtonOnEnter)
            button:SetScript('OnClick', ButtonOnClick)
        end
    end

    frame:SetScript('OnShow', FrameOnShow)

    tinsert(frames, frame)
end

for i = 1, NUM_GROUP_LOOT_FRAMES do
    SetupFrame(_G['GroupLootFrame' .. i])
end

local function FindFrame(rollId)
    for _, frame in ipairs(frames) do
        if frame:IsVisible() and frame.rollID == rollId then
            return frame
        end
    end
end

local function GetRollTypeButton(frame, rollType)
    local buttonKey = buttonKeys[rollType]
    if not buttonKey then
        return
    end

    local button = frame[buttonKey]
    if not button then
        return
    end
    return button
end

local function UpdateRoll(rollId, rollType)
    local id, _, numPlayers, isDone = C_LootHistory.GetItem(rollId)
    if not id or isDone or not numPlayers then
        return
    end

    local frame = FindFrame(rollId)
    if not frame then
        return
    end

    local button = GetRollTypeButton(frame, rollType)
    if not button then
        return
    end

    local count = 0
    for i = 1, numPlayers do
        local _, _, playerRollType = C_LootHistory.GetPlayerInfo(rollId, i)
        if rollType == playerRollType then
            count = count + 1
        end
    end

    button:SetText(count)
end

ns.event('LOOT_HISTORY_ROLL_CHANGED', function(rollId, playerIdx)
    local _, _, rollType = C_LootHistory.GetPlayerInfo(rollId, playerIdx)
    UpdateRoll(rollId, rollType)
end)
