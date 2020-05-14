-- Api.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/9/2020, 1:02:09 PM

local next = next
local type = type
local assert = assert
local ipairs = ipairs
local select = select
local unpack = unpack
local tinsert = table.insert

local IsAddOnLoaded = IsAddOnLoaded
local GetAddOnInfo = GetAddOnInfo
local After = C_Timer.After

---@class ns
local ADDON, ns = ...

local events = CreateFrame('Frame')

local addonCallbacks = {}
local eventCallbacks = {}
local onceEventCallbacks = {}

local function append(t, k, v)
    t[k] = t[k] or {}
    tinsert(t[k], v)
end

local function call(t, k, ...)
    if not t[k] then
        return
    end
    for i, v in ipairs(t[k]) do
        v(...)
    end
end

events:SetScript('OnEvent', function(self, event, ...)
    if event == 'ADDON_LOADED' then
        local addon = ...
        call(addonCallbacks, addon)

        addonCallbacks[addon] = nil
        if not next(addonCallbacks) then
            events:UnregisterEvent('ADDON_LOADED')
        end
    else
        call(onceEventCallbacks, event, ...)
        onceEventCallbacks[event] = nil
        call(eventCallbacks, event, ...)

        if not onceEventCallbacks[event] and not eventCallbacks[event] then
            events:UnregisterEvent(event)
        end
    end
end)

function ns.onceevent(event, func)
    assert(type(func) == 'function')

    append(onceEventCallbacks, event, func)
    events:RegisterEvent(event)
end

function ns.onceeventdelay(event, n, func)
    return ns.onceevent(event, ns.delayed(n, func))
end

function ns.onceeventspawn(event, func)
    return ns.onceeventdelay(event, 0, func)
end

function ns.event(event, func)
    assert(type(func) == 'function')

    append(eventCallbacks, event, func)
    events:RegisterEvent(event)
end

function ns.login(func)
    return ns.onceeventspawn('PLAYER_LOGIN', func)
end

function ns.addon(addon, func)
    assert(type(func) == 'function')
    assert(select(5, GetAddOnInfo(addon)) ~= 'MISSING')

    if IsAddOnLoaded(addon) then
        func()
    else
        append(addonCallbacks, addon, func)
        events:RegisterEvent('ADDON_LOADED')
    end
end

function ns.delayed(n, func)
    return function(...)
        local args = {...}
        local argCount = select('#', ...)

        return After(n, function()
            return func(unpack(args, 1, argCount))
        end)
    end
end

function ns.spawned(func)
    return ns.delayed(0, func)
end

ns.securehook = hooksecurefunc
