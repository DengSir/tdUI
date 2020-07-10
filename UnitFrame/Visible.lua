-- Visible.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/23/2020, 2:45:43 PM
--
---@type ns
local ns = select(2, ...)

local InCombatLockdown = InCombatLockdown
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType

local PlayerFrame = PlayerFrame

local Controller = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
Controller:SetAttribute('_onstate-showhide', [[
    local PlayerFrame = self:GetFrameRef('PlayerFrame')
    if newstate == 1 then
        PlayerFrame:Show()
    end
]])
Controller:SetFrameRef('PlayerFrame', PlayerFrame)
Controller:RegisterUnitEvent('UNIT_HEALTH', 'player')
Controller:RegisterUnitEvent('UNIT_POWER_UPDATE', 'player')
Controller:RegisterUnitEvent('UNIT_POWER_FREQUENT', 'player')
Controller:RegisterEvent('PLAYER_TARGET_CHANGED')
RegisterStateDriver(Controller, 'showhide', '[combat]1;[@target,exists]1;0')

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

Controller:SetScript('OnEvent', CheckShown)
CheckShown()
