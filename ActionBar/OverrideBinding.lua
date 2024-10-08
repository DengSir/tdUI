-- OverrideBinding.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/8/2024, 4:46:23 PM
--
---@type ns
local ns = select(2, ...)

local Action = CreateFrame('Frame', 'tdUIOverrideButton', UIParent, 'SecureHandlerStateTemplate')
local Donothing = CreateFrame('Button', 'tdUIOverrideDonothing', UIParent, 'SecureHandlerClickTemplate')

Action:Execute [[
    hotkeys = newtable()
    state = 0

    SetupHotkeys = [=[
        for i = 1, 6 do
            for _, key in ipairs(table.new(GetBindingKey('ACTIONBUTTON' .. i))) do
                self:SetBindingClick(true, key, 'tdUIOverrideDonothing')
            end
        end

        for i = 1, 6 do
            local hotkey = hotkeys[i]
            if hotkey then
                self:SetBindingClick(true, hotkey, 'OverrideActionBarButton' .. i)
            end

            self:CallMethod('Update', i)
        end
    ]=]

    Update = [=[
        if state == 1 then
            self:Run(SetupHotkeys)
        else
            self:ClearBindings()
        end
    ]=]
]]

Action:SetAttribute('_onstate-usable', [[
    state = newstate
    self:Run(Update)
]])

local function IsInUse(key)
    local keys = ns.config('keybindings.vehicle')
    for _, v in pairs(keys) do
        if v == key then
            return true
        end
    end
end

local function ResolveKey(index)
    local key = ns.config('keybindings.vehicle.action' .. index)
    local key1, key2 = GetBindingKey('ACTIONBUTTON' .. index)

    if not key then
        if key1 and not IsInUse(key1) then
            return key1
        end
        if key2 and not IsInUse(key2) then
            return key2
        end
    end
    return key
end

local function UpdateConfig()
    Action:Execute([[wipe(hotkeys)]])

    for i = 1, 6 do
        local key = ResolveKey(i)
        if key then
            Action:Execute(format('hotkeys[%d] = %q', i, key))
        end
    end
    Action:Execute([[self:Run(Update)]])
end

function Action:Update(index)
    local hotkey = _G['OverrideActionBarButton' .. index].HotKey
    hotkey:SetText(ResolveKey(index))
end

for i = 1, 6 do
    ns.config('keybindings.vehicle.action' .. i, UpdateConfig)
end

ns.load(function()
    UpdateConfig()
    RegisterStateDriver(Action, 'usable', '[vehicleui][overridebar] 1; 0')
end)
