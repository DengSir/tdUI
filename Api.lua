-- Api.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/9/2020, 1:02:09 PM

local ipairs = ipairs
local next = next
local tinsert = table.insert

local CreateFrame = CreateFrame

---@class ns
local ns = select(2, ...)

local events
local callbacks = {}

function ns.WithAddon(addon, callback)
    if not events then
        events = CreateFrame('Frame')
        events:RegisterEvent('ADDON_LOADED')
        events:SetScript('OnEvent', function(_, event, name)
            local cbs = callbacks[name]
            if cbs then
                for _, callback in ipairs(cbs) do
                    callback()
                end
                callbacks[name] = nil
            end

            if not next(callbacks) then
                events:UnregisterEvent('ADDON_LOADED')
            end
        end)
    end

    callbacks[addon] = callbacks[addon] or {}
    tinsert(callbacks[addon], callback)
end

function ns.OnceEvent(event, callback)
    local handle = LibStub('AceEvent-3.0'):Embed({})
    handle:RegisterEvent(event, function(_, ...)
        callback(...)
        handle:UnregisterEvent(event)
    end)
end
