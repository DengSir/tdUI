-- idTip.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/30/2026, 6:55:53 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('idTip', '!!!tdDevTools', function()
    local parent = tdDevToolsFrame

    local function Update()
        if idTipConfig then
            idTipConfig.enabled = parent:IsShown()
        end
    end

    local f = CreateFrame('Frame', nil, parent)
    f:SetScript('OnShow', Update)
    f:SetScript('OnHide', Update)

    Update()
end)
