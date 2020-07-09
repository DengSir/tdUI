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
local IsLoggedIn = IsLoggedIn
local After = C_Timer.After
local NewTicker = C_Timer.NewTicker

---@class ns
---@field profile Profile
local ADDON, ns = ...

local events = CreateFrame('Frame')

local addonCallbacks = {}
local eventCallbacks = {}
local onceEventCallbacks = {}
local configCallbacks = {}
local pendings = {}

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

local function pack(...)
    local n = select('#', ...)
    if n == 0 then
        return nop
    elseif n == 1 then
        local arg1 = ...
        return function()
            return arg1
        end
    elseif n == 2 then
        local arg1, arg2 = ...
        return function()
            return arg1, arg2
        end
    elseif n == 3 then
        local arg1, arg2, arg3 = ...
        return function()
            return arg1, arg2, arg3
        end
    else
        local args = {...}
        local argCount = select('#', ...)

        return function()
            return unpack(args, 1, argCount)
        end
    end
end

local function register(event)
    if event:sub(1, 1) ~= '!' then
        events:RegisterEvent(event)
    end
end

local function done(event)
    if event:sub(1, 1) ~= '!' then
        if not onceEventCallbacks[event] and not eventCallbacks[event] then
            events:UnregisterEvent(event)
        end
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
        ns.fire(event, ...)
    end
end)

ns.pack = pack
ns.after = After
ns.timer = NewTicker

function ns.spawn(func)
    return After(0, func)
end

function ns.fire(event, ...)
    call(onceEventCallbacks, event, ...)
    onceEventCallbacks[event] = nil
    call(eventCallbacks, event, ...)
    done(event)
end

function ns.onceevent(event, func)
    assert(type(func) == 'function')

    append(onceEventCallbacks, event, func)
    register(event)
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
    register(event)
end

function ns.login(func)
    if IsLoggedIn() then
        return ns.spawn(func)
    end
    return ns.onceeventspawn('PLAYER_LOGIN', func)
end

local function addon(addon, func)
    assert(type(func) == 'function')
    if select(5, GetAddOnInfo(addon)) == 'MISSING' then
        return
    end

    if addon ~= ADDON and IsAddOnLoaded(addon) then
        func()
    else
        append(addonCallbacks, addon, func)
        events:RegisterEvent('ADDON_LOADED')
    end
end

local function multiaddon(...)
    local n = select('#', ...)
    assert(type(select(n, ...)) == 'function')

    local func = select(n, ...)
    local addons = {...}
    addons[n] = nil

    local function wait()
        local one = tremove(addons)
        if one then
            addon(one, wait)
        else
            func()
        end
    end
    wait()
end

function ns.addon(...)
    local n = select('#', ...)
    if n == 2 then
        return addon(...)
    elseif n > 2 then
        return multiaddon(...)
    else
        assert(false)
    end
end

function ns.load(func)
    return addon(ADDON, func)
end

function ns.addonlogin(...)
    local p = pack(...)

    return ns.login(function()
        return ns.addon(p())
    end)
end

function ns.delayed(n, func)
    return function(...)
        local p = pack(...)

        return After(n, function()
            return func(p())
        end)
    end
end

function ns.spawned(func)
    return ns.delayed(0, func)
end

function ns.nocombated(func)
    return function()
        return ns.nocombat(func)
    end
end

function ns.nocombat(func)
    if not InCombatLockdown() then
        func()
    else
        ns.onceevent('PLAYER_REGEN_ENABLED', func)
    end
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

---hookscript
---@generic T
---@param obj T
---@param script string
---@param func fun(self: T)
function ns.hookscript(obj, script, func)
    return obj:HookScript(script, func)
end

ns.securehook = hooksecurefunc

local function pendingOnUpdate(self)
    self:SetScript('OnUpdate', nil)

    for _, v in pairs(pendings) do
        v()
    end
    wipe(pendings)
end

function ns.pending(obj, func)
    if type(func) == 'string' then
        local method = obj[func]
        func = function()
            return method(obj)
        end
    end

    pendings[obj] = func
    events:SetScript('OnUpdate', pendingOnUpdate)
end

-- do
--     local updaters = {}

--     ns.event('GET_ITEM_INFO_RECEIVED', function(id, ok)
--         if not ok then
--             return
--         end

--         local objects = updaters[id]
--         if objects then
--             for obj, func in pairs(objects) do
--                 func(obj)
--             end
--             updaters[id] = nil
--         end
--     end)

--     local function parseItem(item)
--         return tonumber(item) or tonumber(item:match('item:(%d+)'))
--     end

--     function ns.waititem(item, obj, func)
--         item = parseItem(item)
--         updaters[item] = updaters[item] or {}
--         updaters[item][obj] = func
--     end
-- end

function ns.config(paths, ...)
    if select('#', ...) == 0 then
        local value = ns.profile
        for i, path in ipairs(paths) do
            value = value[path]
            if not value then
                return
            end
        end
        return value
    elseif type(...) == 'function' then
        append(configCallbacks, type(paths) == 'table' and tconcat(paths, '.') or paths, (...))
    else
        local n = #paths
        local db = ns.profile
        for i, v in ipairs(paths) do
            if i < n then
                db = db[v]
            else
                db[v] = ...
                call(configCallbacks, tconcat(paths, '.'))
            end
        end
    end
end

local Runner
function ns.runattribute(handle, attr)
    if not Runner then
        Runner = CreateFrame('Frame', nil, UIParent, 'SecureHandlerAttributeTemplate')
        Runner:SetAttribute('_onattributechanged',
                            [[if name == 'run' then self:GetFrameRef('handle'):RunAttribute(value) end]])
    end
    Runner:SetFrameRef('handle', handle)
    Runner:SetAttribute('run', attr)
end
