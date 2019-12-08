-- Guild.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2019, 3:23:10 PM

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetGuildRosterInfo = GetGuildRosterInfo
local GetWhoInfo = C_FriendList.GetWhoInfo

local FriendsFrame = FriendsFrame

local WHOS_TO_DISPLAY = WHOS_TO_DISPLAY
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local GUILDMEMBERS_TO_DISPLAY = GUILDMEMBERS_TO_DISPLAY

local function GenerateUpdateList(nameTemplate, count, updateItem)
    return function()
        for i = 1, count do
            local button = _G[nameTemplate .. i]
            if button and button:IsShown() then
                updateItem(button)
            end
        end
    end
end

local UpdateGuildMembers = GenerateUpdateList('GuildFrameButton', GUILDMEMBERS_TO_DISPLAY, function(button)
    local level, _, _, _, _, online, _, class = select(4, GetGuildRosterInfo(button.guildIndex))
    if online then
        local name = button:GetName()
        local classColor = RAID_CLASS_COLORS[class]
        if classColor then
            local r, g, b = classColor.r, classColor.g, classColor.b
            _G[name .. 'Name']:SetTextColor(r, g, b)
            _G[name .. 'Class']:SetTextColor(r, g, b)
        end

        local levelColor = GetQuestDifficultyColor(level)
        if levelColor then
            _G[name .. 'Level']:SetTextColor(levelColor.r, levelColor.g, levelColor.b)
        end
    end
end)

local UpdateGuildStatus = GenerateUpdateList('GuildFrameGuildStatusButton', GUILDMEMBERS_TO_DISPLAY, function(button)
    local online, _, class = select(9, GetGuildRosterInfo(button.guildIndex))
    if online then
        local name = button:GetName()
        local classColor = RAID_CLASS_COLORS[class]
        if classColor then
            local r, g, b = classColor.r, classColor.g, classColor.b
            _G[name .. 'Name']:SetTextColor(r, g, b)
        end
    end
end)

hooksecurefunc('GuildStatus_Update', function()
    if FriendsFrame.playerStatusFrame then
        UpdateGuildMembers()
    else
        UpdateGuildStatus()
    end
end)

hooksecurefunc('WhoList_Update', GenerateUpdateList('WhoFrameButton', WHOS_TO_DISPLAY, function(button)
    local info = GetWhoInfo(button.whoIndex)
    if info then
        local name = button:GetName()
        local classColor = RAID_CLASS_COLORS[info.filename]
        if classColor then
            _G[name .. 'Name']:SetTextColor(classColor.r, classColor.g, classColor.b)
        end

        local levelColor = GetQuestDifficultyColor(info.level)
        if levelColor then
            _G[name .. 'Level']:SetTextColor(levelColor.r, levelColor.g, levelColor.b)
        end
    end
end))

local CLASS_FILENAMES = tInvert(FillLocalizedClassList({}))

hooksecurefunc('FriendsFrame_UpdateFriendButton', function(button)
    if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        local info = C_FriendList.GetFriendInfoByIndex(button.id)
        if info.connected then
            local class = info.className and CLASS_FILENAMES[info.className]
            local color = class and RAID_CLASS_COLORS[class]
            if color then
                local colorStr = color.colorStr
                local nameText = info.name .. ', ' ..
                                     format(FRIENDS_LEVEL_TEMPLATE, info.level,
                                            WrapTextInColorCode(info.className, colorStr))
                button.name:SetText(nameText)
            end
        end
    end
end)
