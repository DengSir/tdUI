-- Link.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/14/2020, 11:36:55 PM
local select = select
local format = string.format

local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor

local LINK_PATTERN = '(|H([^:|]+):([^|]-)|h(.-)|h)'

local function Colorful(color)
    return function(text)
        return '|cff' .. color .. text .. '|r'
    end
end

local FIXES = {
    item = function(text, type, link)
        local quality = select(3, GetItemInfo(link:match('^(%d+)')))
        if quality then
            local r, g, b = GetItemQualityColor(quality)
            return format('|cff%02x%02x%02x%s|r', r * 255, g * 255, b * 255, text)
        end
    end,

    talent = Colorful('4e96f7'),
    spell = Colorful('71d5ff'),
}

-- @classic@
FIXES.enchant = Colorful('ffffff')
-- @end-classic@
-- @bcc@
FIXES.enchant = Colorful('ffd000')
-- @end-bcc@

local function FixLinkColor(frame, event, msg, ...)
    msg = msg:gsub(LINK_PATTERN, function(text, type, link, ...)
        local method = FIXES[type]
        if method then
            return method(text, type, link, ...)
        end
    end)
    return false, msg, ...
end

ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_WHISPER', FixLinkColor)
ChatFrame_AddMessageEventFilter('CHAT_MSG_BN_WHISPER_INFORM', FixLinkColor)

local function GetPlayerClass(name)
    for i = 1, GetNumGuildMembers() do
        local member, _, _, _, _, _, _, _, _, _, class = GetGuildRosterInfo(i)
        if Ambiguate(member, 'none') == name then
            return class
        end
    end

    for i = 1, C_FriendList.GetNumFriends() do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info.name == name then
            local _, class = GetPlayerInfoByGUID(info.guid)
            return class
        end
    end
    -- GetFriendInfo
end

ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', function(frame, event, msg, ...)
    local name = msg:match('|Hplayer:([^:|]+)|h%[([^%]]+)%]|h')
    local class = name and GetPlayerClass(name)
    if class then
        local color = RAID_CLASS_COLORS[class]
        if color then
            msg = msg:gsub('|h%[([^%]]+)%]|h', format('|h[%s]|h', color:WrapTextInColorCode(name)))
        end
    end
    return false, msg, ...
end)
