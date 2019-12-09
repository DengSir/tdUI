-- Guild.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2019, 3:23:10 PM

local _G = _G
local select = select
local format = string.format
local hooksecurefunc = hooksecurefunc

local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetGuildRosterInfo = GetGuildRosterInfo
local GetRealZoneText = GetRealZoneText
local GetGuildInfo = GetGuildInfo
local GetWhoInfo = C_FriendList.GetWhoInfo
local GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local GuildControlGetNumRanks = GuildControlGetNumRanks
local UnitFactionGroup = UnitFactionGroup
local BNGetGameAccountInfo = BNGetGameAccountInfo
local BNGetFriendInfo = BNGetFriendInfo
local WrapTextInColorCode = WrapTextInColorCode
local UIDropDownMenu_GetSelectedID = UIDropDownMenu_GetSelectedID
local FriendsFrameTooltip_SetLine = FriendsFrameTooltip_SetLine

local FriendsFrame = FriendsFrame
local WhoFrameDropDown = WhoFrameDropDown
local FriendsTooltipGameAccount1Name = FriendsTooltipGameAccount1Name

local WHOS_TO_DISPLAY = WHOS_TO_DISPLAY
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local GUILDMEMBERS_TO_DISPLAY = GUILDMEMBERS_TO_DISPLAY
local FRIENDS_BUTTON_TYPE_WOW = FRIENDS_BUTTON_TYPE_WOW
local FRIENDS_BUTTON_TYPE_BNET = FRIENDS_BUTTON_TYPE_BNET
local BNET_CLIENT_WOW = BNET_CLIENT_WOW
local FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE = FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE

local CLASS_FILENAMES = tInvert(FillLocalizedClassList({}))
local BNET_NAME_FORMATTER = '%s ' .. FRIENDS_OTHER_NAME_COLOR_CODE .. '(' .. FONT_COLOR_CODE_CLOSE .. '%s' ..
                                FRIENDS_OTHER_NAME_COLOR_CODE .. ')' .. FONT_COLOR_CODE_CLOSE

local function ColorStr(text, color)
    if color.colorStr then
        return WrapTextInColorCode(text, color.colorStr)
    else
        return format('|cff%02x%02x%02x%s|r', color.r * 255, color.g * 255, color.b * 255, text)
    end
end

local function GetClassColor(localeClass)
    return RAID_CLASS_COLORS[CLASS_FILENAMES[localeClass]]
end

local function GetRankColor(rank)
    local max = GuildControlGetNumRanks()
    local value = rank / max
    local r, g, b

    if value > 0.5 then
        r = (1 - value) * 2
        g = 1
    else
        r = 1
        g = value * 2
    end
    b = 0
    return r, g, b
end

local function GenerateUpdateList(args)
    local nameTemplate = args.nameTemplate
    local count = args.count
    local updateItem = args.updateItem
    local global = args.global

    return function()
        local a1, a2, a3, a4, a5
        if global then
            a1, a2, a3, a4, a5 = global()
        end
        for i = 1, count do
            local button = _G[nameTemplate .. i]
            if button and button:IsShown() then
                updateItem(button, a1, a2, a3, a4, a5)
            end
        end
    end
end

local UpdateGuildMembers = GenerateUpdateList{
    nameTemplate = 'GuildFrameButton',
    count = GUILDMEMBERS_TO_DISPLAY,
    global = GetRealZoneText,
    updateItem = function(button, myZone)
        local level, _, zone, _, _, online, _, class = select(4, GetGuildRosterInfo(button.guildIndex))
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

            if zone == myZone then
                _G[name .. 'Zone']:SetTextColor(0, 1, 0)
            end
        end
    end,
}

local UpdateGuildStatus = GenerateUpdateList{
    nameTemplate = 'GuildFrameGuildStatusButton',
    count = GUILDMEMBERS_TO_DISPLAY,
    updateItem = function(button)
        local rankIndex, level, _, zone, _, _, online, _, class = select(3, GetGuildRosterInfo(button.guildIndex))
        if online then
            local name = button:GetName()
            local classColor = RAID_CLASS_COLORS[class]
            if classColor then
                local r, g, b = classColor.r, classColor.g, classColor.b
                _G[name .. 'Name']:SetTextColor(r, g, b)
            end

            local r, g, b = GetRankColor(rankIndex)
            _G[name .. 'Rank']:SetTextColor(r, g, b)
        end
    end,
}

hooksecurefunc('GuildStatus_Update', function()
    if FriendsFrame.playerStatusFrame then
        UpdateGuildMembers()
    else
        UpdateGuildStatus()
    end
end)

hooksecurefunc('WhoList_Update', GenerateUpdateList{
    nameTemplate = 'WhoFrameButton',
    count = WHOS_TO_DISPLAY,
    global = function()
        local variable = UIDropDownMenu_GetSelectedID(WhoFrameDropDown)
        if variable == 1 then
            return variable, GetRealZoneText()
        elseif variable == 2 then
            return variable, GetGuildInfo('player')
        end
        return variable
    end,
    updateItem = function(button, variable, value)
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

            if (variable == 1 and info.area == value) or (variable == 2 and info.fullGuildName == value) then
                _G[name .. 'Variable']:SetTextColor(0, 1, 0)
            else
                _G[name .. 'Variable']:SetTextColor(1, 1, 1)
            end
        end
    end,
})

local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub('%%d', '%%s')

hooksecurefunc('FriendsFrame_UpdateFriendButton', function(button)
    local nameText
    if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        local info = GetFriendInfoByIndex(button.id)
        if info.connected then
            local classColor = GetClassColor(info.className)

            nameText = ColorStr(info.name, classColor) .. ', ' ..
                           format(FRIENDS_LEVEL_TEMPLATE, ColorStr(info.level, GetQuestDifficultyColor(info.level)),
                                  ColorStr(info.className, classColor))
        end
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local bnetIDAccount, accountName, _, _, _, bnetIDGameAccount, client, online = BNGetFriendInfo(button.id)

        if online and accountName and bnetIDGameAccount and client == BNET_CLIENT_WOW then
            local _, characterName, client, _, realmID, faction, _, class, _, _, level =
                BNGetGameAccountInfo(bnetIDGameAccount)

            if characterName and class and realmID and realmID > 0 and faction == UnitFactionGroup('player') then
                nameText = format(BNET_NAME_FORMATTER, accountName, ColorStr(characterName, GetClassColor(class)))
            end
        end
    end

    if nameText then
        button.name:SetText(nameText)
    end
end)

local function FriendsFrameTooltip_Show(button)
    if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        local info = GetFriendInfoByIndex(button.id)
        if info.connected then
            FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Name, nil,
                                        format(FRIENDS_LEVEL_TEMPLATE,
                                               ColorStr(info.level, GetQuestDifficultyColor(info.level)),
                                               ColorStr(info.className, GetClassColor(info.className))))
        end
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local bnetIDAccount, accountName, _, _, characterName, bnetIDGameAccount, client, online =
            BNGetFriendInfo(button.id)
        if online and accountName and bnetIDGameAccount and client == BNET_CLIENT_WOW then
            local hasFocus, characterName, client, realmName, realmID, faction, race, class, _, zoneName, level =
                BNGetGameAccountInfo(bnetIDGameAccount)

            if characterName and class and realmID and realmID > 0 and faction == UnitFactionGroup('player') then
                local classColor = GetClassColor(class)

                FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Name, nil,
                                            format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE,
                                                   ColorStr(characterName, classColor),
                                                   ColorStr(level, GetQuestDifficultyColor(level)), race,
                                                   ColorStr(class, GetClassColor(class))))
            end
        end
    end
end

for i, button in ipairs(FriendsFrameFriendsScrollFrame.buttons) do
    button:HookScript('OnEnter', FriendsFrameTooltip_Show)
end

hooksecurefunc('FriendsFrameTooltip_Show', FriendsFrameTooltip_Show)
