-- Roll.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/9/2025, 4:53:31 PM
--
---@class ns
local ns = select(2, ...)

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local frames = {}
local rolls = {}
local buttonKeys = {
    -- [0] = 'PassButton',
    [1] = 'NeedButton',
    [2] = 'GreedButton',
    -- [3] = 'DisenchantButton',
}

local function AddRollPlayer(rollId, rollType, name, class)
    local playerName = format('|c%s%s|r', RAID_CLASS_COLORS[class or 'PRIEST'].colorStr, name)
    rolls[rollId] = rolls[rollId] or {}
    rolls[rollId][playerName] = rollType
end

local function ClearRoll(rollId)
    rolls[rollId] = nil
end

local function ButtonOnEnter(self)
    local rollId = self:GetParent().rollID
    local rollType = self:GetID()
    local roll = rolls[rollId]
    if not roll then
        return
    end

    for playerName, playerRollType in pairs(roll) do
        if rollType == playerRollType then
            GameTooltip:AddLine(playerName)
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

local function FrameOnHide(frame)
    ClearRoll(frame.rollID)
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

    frame:HookScript('OnShow', FrameOnShow)
    frame:HookScript('OnHide', FrameOnHide)

    tinsert(frames, frame)
end

for i = 1, NUM_GROUP_LOOT_FRAMES do
    SetupFrame(_G['GroupLootFrame' .. i])
end

local function FindFrame(rollId)
    for _, frame in ipairs(frames) do
        if frame.rollID == rollId then
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

local function GetRollPlayerCount(rollId, rollType)
    if not rolls[rollId] then
        return 0
    end
    local count = 0
    for _, playerRollType in pairs(rolls[rollId]) do
        if playerRollType == rollType then
            count = count + 1
        end
    end
    return count
end

local function UpdateRoll(rollId, rollType)
    local frame = FindFrame(rollId)
    if not frame then
        return
    end

    local button = GetRollTypeButton(frame, rollType)
    if not button then
        return
    end

    button:SetText(GetRollPlayerCount(rollId, rollType))
end

ns.event('LOOT_HISTORY_ROLL_CHANGED', function(itemIdx, playerIdx)
    local roleId, _, _, isDone = C_LootHistory.GetItem(itemIdx)
    if isDone then
        ClearRoll(roleId)
        return
    end

    local name, class, rollType = C_LootHistory.GetPlayerInfo(itemIdx, playerIdx)

    AddRollPlayer(roleId, rollType, name, class)
    UpdateRoll(roleId, rollType)
end)
