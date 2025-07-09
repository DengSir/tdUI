-- TriggerICD.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/26/2025, 12:38:45 AM
--
---@type ns
local ns = select(2, ...)

local function FindEmptyBagSlot()
    for bag = 0, 4 do
        local free, family = C_Container.GetContainerNumFreeSlots(bag)
        if free > 0 and family == 0 then
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemId = C_Container.GetContainerItemID(bag, slot)
                if not itemId then
                    return bag, slot
                end
            end
        end
    end
end

local tasks = {}

function TriggerICD(slot)
    if InCombatLockdown() then
        return
    end
    if not slot then
        return
    end
    if tasks[slot] then
        return
    end
    local itemId = GetInventoryItemID('player', slot)
    if not itemId then
        return
    end
    local i, j = FindEmptyBagSlot()
    if not i then
        return
    end

    tasks[slot] = {i, j, itemId}

    PickupInventoryItem(slot)
    C_Container.PickupContainerItem(i, j)
end

ns.event('BAG_UPDATE_DELAYED', function()
    for slot, v in pairs(tasks) do
        local i, j = v[1], v[2]
        local info = C_Container.GetContainerItemInfo(i, j)
        if info and not info.isLocked then
            C_Container.PickupContainerItem(i, j)
            PickupInventoryItem(slot)
            tasks[slot] = nil
        end
    end
end)

local function slash(arg)
    local slot = tonumber(arg)
    if not slot or slot < 1 or slot > 19 then
        print('Usage: /triggericd <slot>')
        return
    end
    TriggerICD(slot)
end

RegisterNewSlashCommand(slash, 'triggericd', 'ticd')
