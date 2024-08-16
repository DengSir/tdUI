-- Fishing.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2021, 12:33:30 AM
--
---@type ns
local ns = select(2, ...)

local CVARS = {
    SoftTargetInteractArc = 2,
    SoftTargetInteractRange = 30,
    -- Sound_EnableAllSound = true,
    -- Sound_SFXVolume = 1,
    -- Sound_MasterVolume = 1,
    -- Sound_MusicVolume = 0,
    -- Sound_DialogVolume = 0,
}
local CVARS_CACHE = {}
local WRITING = false

local Action = CreateFrame('Frame', 'tdFishingButton', UIParent, 'SecureHandlerStateTemplate')

Action:SetAttribute('_onstate-usable', [[
    if newstate == 1 then
        self:SetBindingSpell(true, '1', '钓鱼')
        self:SetBinding(true, '2', 'INTERACTTARGET')
    else
        self:ClearBindings()
    end
]])

local function CanFishing()
    local itemId = GetInventoryItemID('player', 16)
    if not itemId then
        return
    end
    local _, itemType, itemSubType = select(6, GetItemInfoInstant(itemId))
    return itemType == 2 and itemSubType == 20
end

Action:HookScript('OnAttributeChanged', function(_, key, value)
    if InCombatLockdown() then
        return
    end

    WRITING = true
    if CanFishing() then
        print('CanFishing')
        for k, v in pairs(CVARS) do
            SetCVar(k, v)
        end
    else
        for k in pairs(CVARS) do
            SetCVar(k, CVARS_CACHE[k])
        end
    end
    C_Timer.After(2, function(cb)
        WRITING = false
    end)
end)

RegisterStateDriver(Action, 'usable', '[equipped:鱼竿]1;0')

local function CacheCVars()
    if WRITING then
        print('Our writing')
        return
    end
    for k, _ in pairs(CVARS) do
        CVARS_CACHE[k] = GetCVar(k)
    end

    dump(CVARS_CACHE)
end

ns.login(CacheCVars)
ns.event('CVAR_UPDATE', CacheCVars)
