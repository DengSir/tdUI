-- Port.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/7/2021, 5:15:24 PM

SLASH_PORT1 = '/port'
SlashCmdList.PORT = function(arg)
    local text = format('z-"%s" %s', arg, C_CreatureInfo.GetClassInfo(9).className)
    C_FriendList.SendWho(text)
    WhoFrameEditBox:SetText(text)
end
