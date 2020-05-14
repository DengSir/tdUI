-- Link.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/14/2020, 11:36:55 PM

local select = select
local format = string.format

local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor

local LINK_PATTERN = '(|H([^:|]+):([^|]-)|h(.-)|h)'

local FIXES = {
    item = function(text, type, link)
        local quality = select(3, GetItemInfo(link:match('^(%d+)')))
        if quality then
            local r, g, b = GetItemQualityColor(quality)
            return format('|cff%02x%02x%02x%s|r', r * 255, g * 255, b * 255, text)
        end
    end,

    enchant = function(text)
        return '|cffffffff' .. text .. '|r'
    end,
}

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
