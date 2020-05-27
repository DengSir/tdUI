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

local WHISPERS = {WHISPER = true, BN_WHISPER = true}

local function UpdateChatType(frame, chatType, tellTarget)
    if tellTarget then
        frame:SetAttribute('')
    end
    frame:SetAttribute('chatType', chatType)
    ChatEdit_UpdateHeader(frame)
end

function ChatEdit_CustomTabPressed(self)
    local chatType = self:GetAttribute('chatType')
    local isWhisper = WHISPERS[chatType]

    if IsControlKeyDown() then
        if isWhisper then
            UpdateChatType(self, 'SAY')
        else
            local target, newChatType = ChatEdit_GetLastToldTarget()
            UpdateChatType(self, newChatType, target)
        end
        return true
    else
        if not isWhisper then
            local text = self.tabCompleteText or self:GetText()
            if text:sub(1, 1) == '/' then
                return false
            end

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

            UpdateChatType(self, CHAT_TYPES[index])
            return true
        end
    end
end
