-- Api.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/9/2020, 1:02:09 PM
--
local next = next
local type = type
local assert = assert
local ipairs = ipairs
local select = select
local tinsert, tconcat = table.insert, table.concat

local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local GetAddOnInfo = C_AddOns and C_AddOns.GetAddOnInfo or GetAddOnInfo
local IsLoggedIn = IsLoggedIn
local After = C_Timer.After
local NewTicker = C_Timer.NewTicker
local SafePack = SafePack
local SafeUnpack = SafeUnpack

local ADDON = ...
---@class ns
local ns = select(2, ...)
_G.tdUI = ns

local LibClass = LibStub('LibClass-2.0')

local events = CreateFrame('Frame')

local addonCallbacks = {}
local eventCallbacks = {}
local onceEventCallbacks = {}
local configCallbacks = {}
local itemReadyCallbacks = {}
local pendings = {}

local function append(t, k, v)
    t[k] = t[k] or {}
    tinsert(t[k], v)
end

local function remove(t, k, v)
    if not t[k] then
        return
    end
    tDeleteItem(t[k], v)
end

local function call(t, k, ...)
    if not t[k] then
        return
    end
    for i, v in ipairs(t[k]) do
        v(...)
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
    elseif event == 'GET_ITEM_INFO_RECEIVED' then
        local itemId, ok = ...
        if ok then
            call(itemReadyCallbacks, itemId)

            itemReadyCallbacks[itemId] = nil
            if not next(itemReadyCallbacks) then
                events:UnregisterEvent('GET_ITEM_INFO_RECEIVED')
            end
        end
    else
        ns.fire(event, ...)
    end
end)

ns.after = After
ns.timer = NewTicker
ns.oncetimer = C_Timer.NewTimer

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

function ns.event(event, func)
    assert(type(func) == 'function')

    append(eventCallbacks, event, func)
    register(event)
end

function ns.unevent(event, func)
    remove(eventCallbacks, event, func)
end

function ns.login(func)
    if IsLoggedIn() then
        return ns.spawn(func)
    end
    return ns.onceevent('PLAYER_LOGIN', ns.spawned(func))
end

function ns.logout(func)
    ns.event('PLAYER_LOGOUT', func)
end

local function IsAddonExists(addon)
    return select(5, GetAddOnInfo(addon)) ~= 'MISSING'
end

local function addon(addon, func)
    assert(type(func) == 'function')
    if not IsAddonExists(addon) then
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

    for _, v in ipairs(addons) do
        if not IsAddonExists(v) then
            return
        end
    end

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
    local p = SafePack(...)

    return ns.login(function()
        return ns.addon(SafeUnpack(p))
    end)
end

function ns.delayed(n, func)
    return function(...)
        local p = SafePack(...)

        return After(n, function()
            return func(SafeUnpack(p))
        end)
    end
end

function ns.spawned(func)
    return ns.delayed(0, func)
end

function ns.nocombated(func)
    return function(...)
        return ns.nocombat(func, ...)
    end
end

function ns.nocombat(func, ...)
    if not InCombatLockdown() then
        func(...)
    else
        local p = SafePack(...)
        ns.onceevent('PLAYER_REGEN_ENABLED', function()
            return func(SafeUnpack(p))
        end)
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

function ns.pend(...)
    local obj, func
    if select('#', ...) == 1 then
        obj, func = {}, ...
    else
        obj, func = ...
    end
    return function()
        return ns.pending(obj, func)
    end
end

local function strPaths(paths)
    local t = type(paths)
    if t == 'string' then
        return paths
    elseif t == 'table' then
        return tconcat(paths, '.')
    else
        assert(false)
    end
end

local function parsePaths(paths)
    local t = type(paths)
    if t == 'string' then
        return {strsplit('%.', paths)}
    elseif t == 'table' then
        return paths
    else
        assert(false)
    end
end

local function configListen(paths, func)
    return append(configCallbacks, strPaths(paths), func)
end

local function configRead(paths)
    local db = ns.profile
    for i, path in ipairs(parsePaths(paths)) do
        db = db[path]
        if not db then
            return
        end
    end
    return db
end

local function configWrite(paths, value)
    local p = parsePaths(paths)
    local n = #p
    local db = ns.profile
    for i, v in ipairs(p) do
        if i < n then
            db = db[v]
        else
            db[v] = value
            call(configCallbacks, strPaths(paths))
        end
    end
end

function ns.config(paths, ...)
    local arg1 = ...
    if select('#', ...) == 0 then
        return configRead(paths)
    elseif type(arg1) == 'function' then
        return configListen(paths, arg1)
    else
        return configWrite(paths, arg1)
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

function ns.class(super)
    return LibClass:New(super)
end

function ns.memorize(func)
    local cache = {}
    return function(k, ...)
        if not k then
            return
        end
        if cache[k] == nil then
            cache[k] = func(k, ...)
        end
        return cache[k]
    end
end

function ns.itemready(itemId, func, ...)
    if GetItemInfo(itemId) then
        return func(...)
    end

    local p = SafePack(...)
    append(itemReadyCallbacks, itemId, function()
        return func(SafeUnpack(p))
    end)
    events:RegisterEvent('GET_ITEM_INFO_RECEIVED')
end

function ns.cleantable(t)
    for k, v in pairs(t) do
        if type(v) == 'table' then
            ns.cleantable(v)

            if not next(v) then
                t[k] = nil
            end
        end
    end
end

do
    local menu
    function ns.CallMenu(anchor, menuList)
        if not menu then
            menu = CreateFrame('Frame', 'tdUIDropdown', UIParent, 'UIDropDownMenuTemplate')
        end

        menu.displayMode = 'MENU'
        menu.initialize = EasyMenu_Initialize
        menu.relativeTo = anchor
        CloseDropDownMenus()
        ToggleDropDownMenu(1, nil, menu, anchor, 0, 0, menuList)
    end

    function ns.CloseMenu(anchor)
        if not menu then
            return
        end
        if not DropDownList1:IsShown() then
            return
        end
        if menu ~= UIDROPDOWNMENU_OPEN_MENU then
            return
        end
        if menu.relativeTo == anchor then
            CloseDropDownMenus()
            return true
        end
    end
end
