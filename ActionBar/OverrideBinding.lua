-- OverrideBinding.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/8/2024, 4:46:23 PM
--
---@type ns
local ns = select(2, ...)

local MAX_ACTIONS = 6

local Action = CreateFrame('Frame', 'tdUIOverrideButton', UIParent, 'SecureHandlerStateTemplate')
local Donothing = CreateFrame('Button', 'tdUIOverrideDonothing', UIParent, 'SecureHandlerClickTemplate')

Action:Execute(format([[MAX_ACTIONS = %d]], MAX_ACTIONS))
Action:Execute [[
    SetupHotkeys = [=[
        for i = 1, MAX_ACTIONS do
            for _, key in ipairs(table.new(GetBindingKey('ACTIONBUTTON' .. i))) do
                self:SetBindingClick(true, key, 'tdUIOverrideDonothing')
            end
        end

        for i = 1, MAX_ACTIONS do
            local hotkey = self:GetAttribute('action' .. i)
            if hotkey then
                self:SetBindingClick(true, hotkey, 'OverrideActionBarButton' .. i)
            end

            self:CallMethod('Update', i)
        end
    ]=]

    Update = [=[
        if self:SetAttribute('state-usable') == 1 then
            self:Run(SetupHotkeys)
        else
            self:ClearBindings()
        end
    ]=]
]]

Action:SetAttribute('_onstate-usable', [[
    self:Run(Update)
]])

function Action:IsHotkeyInUse(hotkey)
    local keys = ns.profile.keybindings.vehicle
    for _, v in pairs(keys) do
        if v == hotkey then
            return true
        end
    end
end

function Action:ResolveHotkey(index)
    local hotkey = ns.profile.keybindings.vehicle['action' .. index]
    local key1, key2 = GetBindingKey('ACTIONBUTTON' .. index)
    if not hotkey then
        if key1 and not self:IsHotkeyInUse(key1) then
            return key1
        end
        if key2 and not self:IsHotkeyInUse(key2) then
            return key2
        end
    end
    return hotkey
end

function Action:UpdateConfig()
    UnregisterStateDriver(self, 'usable')

    self:SetAttribute('state-usable', nil)

    if next(ns.profile.keybindings.vehicle) then
        for i = 1, 6 do
            local hotkey = self:ResolveHotkey(i)
            if hotkey then
                self:SetAttribute('action' .. i, hotkey)
            else
                self:SetAttribute('action' .. i, nil)
            end
        end

        RegisterStateDriver(self, 'usable', '[vehicleui][overridebar] 1; 0')
    end
end

function Action:Update(index)
    local hotkey = _G['OverrideActionBarButton' .. index].HotKey
    hotkey:SetText(self:ResolveKey(index))
end

function Action:OnLoad()
    local UpdateConfig = ns.nocombated(function()
        return Action:UpdateConfig()
    end)

    for i = 1, MAX_ACTIONS do
        ns.config('keybindings.vehicle.action' .. i, UpdateConfig)
    end

    ns.event('UPDATE_BINDINGS', UpdateConfig)
    ns.event('VARIABLES_LOADED', UpdateConfig)

    self:UpdateConfig()
end

ns.load(function()
    Action:OnLoad()
end)
