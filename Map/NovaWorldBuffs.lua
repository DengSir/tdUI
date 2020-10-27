-- NovaWorldBuffs.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/27/2020, 4:29:35 PM
---@type ns
local ns = select(2, ...)

ns.addon('NovaWorldBuffs', function()
    MinimapLayerFrameLeft:Hide()
    MinimapLayerFrameRight:Hide()
    MinimapLayerFrameMiddle:Hide()

    MinimapLayerFrame:SetScript('OnEnter', nil)
    MinimapLayerFrame:SetScript('OnLeave', nil)

    MinimapLayerFrameFS:SetFont(STANDARD_TEXT_FONT, 13, 'OUTLINE')
    MinimapLayerFrameFS.SetFont = nop

    local NWB = NWB or LibStub('AceAddon-3.0'):GetAddon('NovaWorldBuffs')

    NWB:setMmColor(nil, 1, 0.82, 0)
    NWB.options.args.mmColor.disabled = true
end)
