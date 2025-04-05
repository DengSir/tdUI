-- Who.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/8/2020, 5:55:19 PM
---@type ns
local ns = select(2, ...)

local ipairs = ipairs

local GetClassColor = GetClassColor
local GetGuildInfo = GetGuildInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealZoneText = GetRealZoneText
local GetWhoInfo = C_FriendList.GetWhoInfo

local WhoFrameDropdown = WhoFrameDropdown

C_Timer.After(0, function()
    WhoFrameDropdown:SetPoint('TOPLEFT', 1, 0)
    WhoFrameDropdown:SetPoint('TOPRIGHT', -1, 0)
end)

local WhoButons = ns.GetFrames('WhoFrameButton%d', WHOS_TO_DISPLAY, 'Name', 'Level', 'Variable')

local whoStatus, whoVariable

local function GetWhoVariableColor(info)
    if (whoStatus == 1 and whoVariable == info.area) or (whoStatus == 2 and whoVariable == info.fullGuildName) or
        (whoStatus == 3 and whoVariable == info.raceStr) then
        return 0, 1, 0
    else
        return 1, 1, 1
    end
end

local WhoVariables = {[ZONE] = 1, [GUILD] = 2, [RACE] = 3}

ns.securehook('WhoList_Update', ns.spawned(function()
    whoStatus = WhoVariables[WhoFrameDropdown.text]
    if whoStatus == 1 then
        whoVariable = GetRealZoneText()
    elseif whoStatus == 2 then
        whoVariable = GetGuildInfo('player')
    elseif whoStatus == 3 then
        whoVariable = UnitRace('player')
    end

    for _, button in ipairs(WhoButons) do
        local info = GetWhoInfo(button.whoIndex)
        if info then
            ns.SetTextColor(button.Name, GetClassColor(info.filename))
            ns.SetTextColor(button.Level, GetQuestDifficultyColor(info.level))
            ns.SetTextColor(button.Variable, GetWhoVariableColor(info))
        end
    end
end))
