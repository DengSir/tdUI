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

local ACTIONS = { --
    'ACTIONBUTTON1',
    'ACTIONBUTTON2',
    'ACTIONBUTTON3',
    'ACTIONBUTTON4',
    'ACTIONBUTTON5',
    'ACTIONBUTTON6',
    'VEHICLEEXIT',
    'VEHICLEAIMINCREMENT',
    'VEHICLEAIMDECREMENT',
    'VEHICLEPREVSEAT',
    'VEHICLENEXTSEAT',
}

local ACTIONS_UI = {
    ACTIONBUTTON1 = 'OverrideActionBarButton1',
    ACTIONBUTTON2 = 'OverrideActionBarButton2',
    ACTIONBUTTON3 = 'OverrideActionBarButton3',
    ACTIONBUTTON4 = 'OverrideActionBarButton4',
    ACTIONBUTTON5 = 'OverrideActionBarButton5',
    ACTIONBUTTON6 = 'OverrideActionBarButton6',
}

Action:Execute([[ACTIONS = newtable()]])
for _, binding in ipairs(ACTIONS) do
    Action:Execute(format([[tinsert(ACTIONS, '%s')]], binding))
end

Action:Execute [[
    SetupHotkeys = [=[
        for _, binding in ipairs(ACTIONS) do
            for _, hotkey in ipairs(table.new(GetBindingKey(binding))) do
                self:SetBindingClick(true, hotkey, 'tdUIOverrideDonothing')
            end
        end

        for _, binding in ipairs(ACTIONS) do
            local hotkey = self:GetAttribute(binding)
            print(binding, hotkey)
            if hotkey then
                self:SetBinding(true, hotkey, binding)
            end

            self:CallMethod('Update', binding)
        end
    ]=]

    Update = [=[
        if self:GetAttribute('state-usable') == 1 then
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

function Action:ResolveHotkey(binding)
    local hotkey = ns.profile.keybindings.vehicle[binding]
    local key1, key2 = GetBindingKey(binding)
    if not hotkey then
        if key1 and not self:IsHotkeyInUse(key1) then
            return key1
        end
        if key2 and not self:IsHotkeyInUse(key2) then
            return key2
        end
    end
    if hotkey then
        return hotkey
    end
    if binding:sub(1, 12) == 'ACTIONBUTTON' then
         self:ResolveHotkey('action' .. binding:sub(13))
    end
end

function Action:UpdateConfig()
    UnregisterStateDriver(self, 'usable')

    self:SetAttribute('state-usable', nil)

    for _, binding in ipairs(ACTIONS) do
        local hotkey = self:ResolveHotkey(binding)
        if hotkey then
            self:SetAttribute(binding, hotkey)
        else
            self:SetAttribute(binding, nil)
        end
    end

    RegisterStateDriver(self, 'usable', '[vehicleui] 1; 0')
end

function Action:Update(binding)
    local ui = ACTIONS_UI[binding]
    local button = _G[ui]
    local hotkey = button and button.HotKey
    if hotkey then
        hotkey:SetText(self:ResolveHotkey(binding))
    end
end

function Action:OnLoad()
    local UpdateConfig = ns.nocombated(function()
        return Action:UpdateConfig()
    end)

    for _, binding in ipairs(ACTIONS) do
        ns.config('keybindings.vehicle.' .. binding, UpdateConfig)
    end

    ns.event('UPDATE_BINDINGS', UpdateConfig)

    self:UpdateConfig()
end

Action:OnLoad()
