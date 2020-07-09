-- Visible.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/23/2020, 2:45:43 PM

local Visible = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
Visible:SetAttribute('_onstate-showhide', [[
    local PlayerFrame = self:GetFrameRef('PlayerFrame')
    if newstate == 1 then
        PlayerFrame:Show()
    end
]])
Visible:SetFrameRef('PlayerFrame', PlayerFrame)
RegisterStateDriver(Visible, 'showhide', '[combat]1;[@target,exists]1;0')

---@type ns
local ns = select(2, ...)

Visible:RegisterUnitEvent('UNIT_HEALTH', 'player')
Visible:RegisterUnitEvent('UNIT_POWER_UPDATE', 'player')
Visible:RegisterUnitEvent('UNIT_POWER_FREQUENT', 'player')
Visible:RegisterEvent('PLAYER_TARGET_CHANGED')

local function NeedShown()
    if UnitExists('target') then
        return true
    end

    if UnitHealth('player') < UnitHealthMax('player') then
        return true
    end

    local powerType = UnitPowerType('player')
    return UnitPower('player', powerType) < UnitPowerMax('player', powerType)
end

local function CheckShown()
    if not InCombatLockdown() then
        PlayerFrame:SetShown(NeedShown())
    end
end

Visible:SetScript('OnEvent', CheckShown)
CheckShown()
