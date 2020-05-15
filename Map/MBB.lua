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

    local origSetOwner = GameTooltip.SetOwner
    local origMBB_PrepareButton = MBB_PrepareButton

    local function getAnchors(frame)
        local x, y = frame:GetCenter()
        if not x or not y then
            return 'CENTER'
        end
        local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
        local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
        return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
    end

    local function SetOwner(tip, owner)
        origSetOwner(tip, owner, 'ANCHOR_NONE')
        tip:SetPoint(getAnchors(owner))
    end

    local function OnEnter(button, ...)
        GameTooltip.SetOwner = SetOwner
        button.oenter(button, ...)
        GameTooltip.SetOwner = nil

        if (not MBB_IsInArray(MBB_Exclude, name)) then
            MBB_ShowTimeout = -1
        end
    end

    function MBB_PrepareButton(name)
        local button = _G[name]
        button.RegisterForClicks = nop
        origMBB_PrepareButton(name)
        button.RegisterForClicks = nil

        if button.oenter then
            button:SetScript('OnEnter', OnEnter)
        end
    end
end)
