-- ChatBlock.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/11/2025, 9:55:01 PM

ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', function(frame, event, msg, ...)
    if msg:find('进入艾泽拉斯！') then
        return true
    end
    return false, msg, ...
end)
