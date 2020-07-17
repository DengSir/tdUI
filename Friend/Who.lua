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

local UIDropDownMenu_GetSelectedID = UIDropDownMenu_GetSelectedID

local WhoFrameDropDown = WhoFrameDropDown

local WhoButons = ns.GetFrames('WhoFrameButton%d', WHOS_TO_DISPLAY, 'Name', 'Level', 'Variable')

local whoStatus, whoVariable

local function GetWhoVariableColor(info)
    if (whoStatus == 1 and whoVariable == info.area) or (whoStatus == 2 and whoVariable == info.fullGuildName) then
        return 0, 1, 0
    else
        return 1, 1, 1
    end
end

ns.securehook('WhoList_Update', function()
    whoStatus = UIDropDownMenu_GetSelectedID(WhoFrameDropDown)
    if whoStatus == 1 then
        whoVariable = GetRealZoneText()
    elseif whoStatus == 2 then
        whoVariable = GetGuildInfo('player')
    end

    for _, button in ipairs(WhoButons) do
        local info = GetWhoInfo(button.whoIndex)
        if info then
            ns.SetTextColor(button.Name, GetClassColor(info.filename))
            ns.SetTextColor(button.Level, GetQuestDifficultyColor(info.level))
            ns.SetTextColor(button.Variable, GetWhoVariableColor(info))
        end
    end
end)
