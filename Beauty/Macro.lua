-- Macro.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/5/2025, 5:00:08 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_MacroUI', function()
    ---@type Frame
    local MacroFrame = MacroFrame
    local anyInput = -1

    -- 修复选择时会保存一下，导致跳转到最上面的问题
    -- MacroFrameText:HookScript('OnTextChanged', function(_, userInput)
    --     if userInput then
    --         anyInput = MacroFrame:GetSelectedIndex()
    --     elseif anyInput ~= MacroFrame:GetSelectedIndex() then
    --         MacroFrame.textChanged = nil
    --     end
    -- end)

    -- 取消
    -- MacroCancelButton:HookScript('PreClick', function(self)
    --     MacroFrame.textChanged = nil

    --     print(MacroFrame:GetSelectedIndex())
    -- end)

    MacroFrame:SetWidth(MacroFrame:GetWidth() * 2)

    MacroHorizontalBarLeft:Hide()

    for _, region in ipairs({MacroFrame:GetRegions()}) do
        if region:GetObjectType() == 'Texture' and select(2, region:GetPoint()) == MacroHorizontalBarLeft then
            region:Hide()
            break
        end
    end

    MacroFrame.MacroSelector:SetHeight(MacroFrame:GetHeight() - 98)

    MacroFrameSelectedMacroBackground:ClearAllPoints()
    MacroFrameSelectedMacroBackground:SetPoint('TOPLEFT', MacroFrame.MacroSelector, 'TOPRIGHT', 3, 5)

    MacroFrameScrollFrame:SetHeight(242)

    MacroFrameTextBackground:ClearAllPoints()
    MacroFrameTextBackground:SetPoint('TOPLEFT', MacroFrameScrollFrame, 'TOPLEFT', -5, 5)
    MacroFrameTextBackground:SetPoint('BOTTOMRIGHT', MacroFrameScrollFrame, 'BOTTOMRIGHT', 26, -5)

    MacroFrameCharLimitText:ClearAllPoints();
    MacroFrameCharLimitText:SetPoint('TOP', MacroFrameTextBackground, 'BOTTOM')

    UIPanelWindows['MacroFrame'] = nil

    MacroFrame:SetAttribute('UIPanelLayout-enabled', true)
    MacroFrame:SetAttribute('UIPanelLayout-defined', true)
    MacroFrame:SetAttribute('UIPanelLayout-whileDead', true)
    MacroFrame:SetAttribute('UIPanelLayout-area', 'left')
    MacroFrame:SetAttribute('UIPanelLayout-pushable', 1)
end)
