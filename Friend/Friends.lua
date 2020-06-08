-- Guild.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2019, 3:23:10 PM

---@type ns
local ns = select(2, ...)

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
local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub('%%d', '%%s')

local function rgb(r, g, b)
    if b then
        return r, g, b
    elseif r.r then
        return r.r, r.g, r.b
    else
        return unpack(r)
    end
end

local function ColorStr(text, r, g, b)
    r, g, b = rgb(r, g, b)
    return format('|cff%02x%02x%02x%s|r', r * 255, g * 255, b * 255, text)
end

local function GetBNFriendInfo(id)
    local _, accountName, _, _, _, bnetIdGameAccount, client, online = BNGetFriendInfo(id)

    if not online or not accountName or client ~= BNET_CLIENT_WOW then
        return
    end

    local _, characterName, _, _, realmId, faction, race, class, _, _, level, _, _, _, _, _, _, _, _, _, wowProjectId =
        BNGetGameAccountInfo(bnetIdGameAccount)

    if not characterName or not class or not CLASS_FILENAMES[class] --[[or wowProjectId ~= WOW_PROJECT_ID or not realmId or
        realmId < 0 or realmId ~= GetRealmID() or faction ~= UnitFactionGroup('player')]] then
        return
    end

    local classFileName = CLASS_FILENAMES[class]

    return accountName, characterName, class, classFileName, level, race
end

ns.securehook('FriendsFrame_UpdateFriendButton', function(button)
    local nameText
    if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        local info = GetFriendInfoByIndex(button.id)
        if info.connected then
            local r, g, b = GetClassColor(CLASS_FILENAMES[info.className])

            nameText = ColorStr(info.name, r, g, b) .. ', ' ..
                           format(FRIENDS_LEVEL_TEMPLATE, ColorStr(info.level, GetQuestDifficultyColor(info.level)),
                                  ColorStr(info.className, r, g, b))
        end
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local accountName, characterName, class, classFileName, level, race = GetBNFriendInfo(button.id)
        if accountName then
            nameText = format('%s %s', accountName, ColorStr('(' .. characterName .. ')', GetClassColor(classFileName)))
        end
    end

    if nameText then
        button.name:SetText(nameText)
    end
end)

local function FriendsFrameTooltip_Show(button)
    if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
        local info = GetFriendInfoByIndex(button.id)
        dump(info)
        if info.connected then
            FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Name, nil,
                                        format(FRIENDS_LEVEL_TEMPLATE,
                                               ColorStr(info.level, GetQuestDifficultyColor(info.level)),
                                               ColorStr(info.className, GetClassColor(info.className))))
        end
    elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
        local accountName, characterName, class, classFileName, level, race = GetBNFriendInfo(button.id)
        if accountName then
            local r, g, b = GetClassColor(classFileName)
            print(r, g, b)

            FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Name, nil,
                                        format(FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE, ColorStr(characterName, r, g, b),
                                               ColorStr(level, GetQuestDifficultyColor(level)), race,
                                               ColorStr(class, r, g, b)))
        end
    end
end

for i, button in ipairs(FriendsFrameFriendsScrollFrame.buttons) do
    button:HookScript('OnEnter', FriendsFrameTooltip_Show)
end

hooksecurefunc('FriendsFrameTooltip_Show', FriendsFrameTooltip_Show)
