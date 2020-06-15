-- MBB.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/15/2020, 3:56:36 PM

---@type ns
local ns = select(2, ...)

ns.addon('MBB', function()
    local UIParent = UIParent
    local GameTooltip = GameTooltip

    local nop = nop

    local function getAnchors(frame)
        local x, y = frame:GetCenter()
        if not x or not y then
            return 'CENTER'
        end
        local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
        local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
        return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
    end

    local function SetOwner(orig, tip, owner)
        orig(tip, owner, 'ANCHOR_NONE')
        tip:SetPoint(getAnchors(owner))
    end

    ns.hook('MBB_PrepareButton', function(orig, name)
        local button = _G[name]

        button.RegisterForClicks = nop
        orig(name)
        button.RegisterForClicks = nil

        local onenter = button:GetScript('OnEnter')
        button:SetScript('OnEnter', function(button, ...)
            ns.hook(GameTooltip, 'SetOwner', SetOwner)
            onenter(button)
            GameTooltip.SetOwner = nil
        end)
    end)
end)
