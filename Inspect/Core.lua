-- Core.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/17/2020, 11:08:38 PM

---@type ns
local ns = select(2, ...)

local ipairs = ipairs
local tinsert = tinsert
local select = select
local strsplit = strsplit
local tonumber = tonumber

local UnitGUID = UnitGUID
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetInventoryItemID = GetInventoryItemID
local GetInventoryItemLink = GetInventoryItemLink

local ALA_PREFIX = 'ATEADD'
local ALA_CMD_LEN = 6

local Inspect = {}
Inspect.name = nil
Inspect.db = {}
Inspect.callbacks = {}

ns.Inspect = Inspect

C_ChatInfo.RegisterAddonMessagePrefix(ALA_PREFIX)

function Inspect:GetUnit()
    return InspectFrame and InspectFrame.unit
end

function Inspect:GetUnitName()
    local unit = self:GetUnit()
    local name
    if unit then
        name = ns.UnitName(unit)
    else
        name = self.name
    end
    return name
end

function Inspect:GetItemLink(slot)
    local unit = self:GetUnit()
    local link
    if unit then
        link = GetInventoryItemLink(unit, slot)
    end
    if not link then
        local name = self:GetUnitName()
        local db = self.db[name]
        if db then
            link = db[slot]
        end
    end
    return link
end

function Inspect:Query(name, unit)
    if not InspectFrame then
        LoadAddOn('Blizzard_InspectUI')
    end

    HideUIPanel(InspectFrame)

    self.name = name

    INSPECTED_UNIT = unit
    InspectFrame.unit = unit
    InspectSwitchTabs(1)

    C_ChatInfo.SendAddonMessage(ALA_PREFIX, '_q_equ', 'WHISPER', name)
end

function Inspect:BuildCharacterDb(name)
    self.db[name] = self.db[name] or {}
    return self.db[name]
end

function Inspect:Clear()
    self.name = nil
end

function Inspect:Callback(func)
    tinsert(self.callbacks, func)
end

function Inspect:Fire(name)
    for _, func in ipairs(self.callbacks) do
        func(name)
    end
end

ns.event('INSPECT_READY', function(guid)
    local unit = Inspect:GetUnit()
    if not unit then
        return
    end

    if UnitGUID(unit) ~= guid then
        return
    end

    local name = ns.GetFullName(select(6, GetPlayerInfoByGUID(guid)))
    if name then
        local db = Inspect:BuildCharacterDb(name)

        for slot = 0, 18 do
            local link = GetInventoryItemLink(unit, slot)
            if link then
                link = link:match('(item:[%-0-9:]+)')
            else
                local id = GetInventoryItemID(unit, slot)
                if id then
                    link = 'item:' .. id
                end
            end

            db[slot] = link
        end
    end
end)

ns.event('CHAT_MSG_ADDON', function(prefix, msg, channel, sender)
    if prefix ~= ALA_PREFIX then
        return
    end

    local cmd = msg:sub(1, ALA_CMD_LEN)
    if cmd == '_r_equ' then
        local sep = msg:sub(ALA_CMD_LEN + 1, ALA_CMD_LEN + 1)
        local data = {strsplit(sep, msg:sub(ALA_CMD_LEN + 2))}

        local name = ns.GetFullName(sender)
        local db = Inspect:BuildCharacterDb(name)

        for i = 1, #data, 2 do
            local slot, link = tonumber(data[i]), data[i + 1]
            if slot and link ~= 'item:-1' then
                db[slot] = link
            end
        end

        Inspect:Fire(name)
    end
end)
