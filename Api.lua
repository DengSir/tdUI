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
local tinsert, tconcat = table.insert, table.concat

local IsAddOnLoaded = IsAddOnLoaded
local GetAddOnInfo = GetAddOnInfo
local After = C_Timer.After

---@class ns
local ADDON, ns = ...

local events = CreateFrame('Frame')

local addonCallbacks = {}
local eventCallbacks = {}
local onceEventCallbacks = {}
local configCallbacks = {}

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
    if IsLoggedIn() then
        return ns.spawned(func)()
    end
    return ns.onceeventspawn('PLAYER_LOGIN', func)
end

function ns.addon(addon, func)
    assert(type(func) == 'function')
    if select(5, GetAddOnInfo(addon)) == 'MISSING' then
        return
    end

    if IsAddOnLoaded(addon) then
        func()
    else
        append(addonCallbacks, addon, func)
        events:RegisterEvent('ADDON_LOADED')
    end
end

function ns.addonlogin(addon, func)
    return ns.login(function()
        print(addon)
        return ns.addon(addon, func)
    end)
end

local repeaterPool = {}
function ns.repeater(n, func)
    local frame = CreateFrame('Frame')
    local timer = 0
    frame:SetScript('OnUpdate', function(self, elasped)
        timer = timer - elasped
        if timer < 0 then
            timer = n
            func()
        end
    end)
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

function ns.hook(t, k, v)
    if type(t) ~= 'table' then
        t, k, v = _G, t, k
    end

    local orig = t[k]

    t[k] = function(...)
        return v(orig, ...)
    end
end

function ns.override(t, k, v)
    if type(t) ~= 'table' then
        t, k, v = _G, t, k
    end

    t[k] = v
end

ns.securehook = hooksecurefunc

do
    local updaters = {}

    ns.event('GET_ITEM_INFO_RECEIVED', function(id, ok)
        if not ok then
            return
        end

        local objects = updaters[id]
        if objects then
            for obj, func in pairs(objects) do
                func(obj)
            end
            updaters[id] = nil
        end
    end)

    local function parseItem(item)
        return tonumber(item) or tonumber(item:match('item:(%d+)'))
    end

    function ns.waititem(item, obj, func)
        item = parseItem(item)
        updaters[item] = updaters[item] or {}
        updaters[item][obj] = func
    end
end

local function setvalue(value, db, ...)
    local n = select('#', ...)
    if n == 1 then
        db[...] = value
    else
        return setvalue(value, db[...], select(2, ...))
    end
end

function ns.config(paths, ...)
    if select('#', ...) == 0 then
        local value = TDDB_UI
        for i, path in ipairs(paths) do
            value = value[path]
            if not value then
                return
            end
        end
        return value
    elseif type(...) == 'function' then
        append(configCallbacks, table.concat(paths, '.'), (...))
    else
        local n = #paths
        local db = TDDB_UI
        for i, v in ipairs(paths) do
            if i < n then
                db = db[v]
            else
                db[v] = ...
                call(configCallbacks, table.concat(paths, '.'))
            end
        end
    end
end
