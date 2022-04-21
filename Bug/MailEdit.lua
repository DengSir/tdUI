-- MailEdit.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2022/4/5 14:02:50
--
---@type ns
local ns = select(2, ...)

ns.securehook('SendMailFrame_Update', function()
    local itemRowCount = SendMailFrame.maxRowsShown
    local icony = SendMailAttachment1:GetHeight() + 2
    local gapy1 = 5
    local gapy2 = 6
    local areay = (gapy2 * 2) + (gapy1 * (itemRowCount - 1)) + (icony * itemRowCount)
    local scrollHeight = 242 - areay
    MailEditBox:SetHeight(scrollHeight)
end)
