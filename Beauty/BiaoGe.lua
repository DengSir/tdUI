-- BiaoGe.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/19/2026, 2:00:02 AM
--
local ns = select(2, ...)

ns.addon('BiaoGe', function()
    local function ResetCursorPosition(frame)
        frame:SetCursorPosition(0)
    end

    local function OnTextChanged(frame)
        if not frame:HasFocus() then
            ResetCursorPosition(frame)
        end
    end

    function BiaoGe_InputBoxTemplate_OnLoad(self)
        local font = ChatFontNormal:GetFont()
        local size = BiaoGe.options.editFontSize or 14
        self:SetFont(font, size, '')

        C_Timer.After(0.1, function()
            self:HookScript('OnEditFocusLost', ResetCursorPosition)
            self:HookScript('OnTextChanged', OnTextChanged)
        end)
    end

    ---@param frame Frame
    local function ApplyAll(frame)
        if not frame then
            return
        end
        if frame:GetObjectType() == 'EditBox' then
            BiaoGe_InputBoxTemplate_OnLoad(frame)
            ResetCursorPosition(frame)
        end

        for _, v in ipairs({frame:GetChildren()}) do
            ApplyAll(v)
        end
    end

    ApplyAll(BG.MainFrame)
end)
