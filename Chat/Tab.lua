-- Tab.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/14/2020, 11:40:43 PM

---@type ns
local ns = select(2, ...)

local tIndexOf = tIndexOf

local IsShiftKeyDown = IsShiftKeyDown
local ChatEdit_UpdateHeader = ChatEdit_UpdateHeader

local CHAT_TYPES = {'SAY', 'YELL', 'GUILD', 'PARTY', 'RAID'}

ns.securehook('ChatEdit_SecureTabPressed', function(self)
    if self.tabCompleteText and self.tabCompleteText:sub(1, 1) == '/' then
        return
    end

    local chatType = self:GetAttribute('chatType')
    if chatType ~= 'WHISPER' and chatType ~= 'BN_WHISPER' then
        local index = tIndexOf(CHAT_TYPES, chatType)
        if not index then
            index = 1
        else
            index = index + (IsShiftKeyDown() and -1 or 1)
        end

        if index == 0 then
            index = #CHAT_TYPES
        elseif index > #CHAT_TYPES then
            index = 1
        end

        self:SetAttribute('chatType', CHAT_TYPES[index])
        ChatEdit_UpdateHeader(self)
        return true
    end
end)
