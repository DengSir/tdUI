-- TalentGear.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/21/2024, 3:36:07 PM
--
---@type ns
local ns = select(2, ...)

local TALENT_GROUPS = {[1] = TALENT_SPEC_PRIMARY, [2] = TALENT_SPEC_SECONDARY}

local function GetTalentName(group)
    local maxPoint = 0
    local maxName = nil
    for i = 1, GetNumTalentTabs() do
        local name, _, pointsSpent = GetTalentTabInfo(i, nil, nil, group)
        if pointsSpent > maxPoint then
            maxPoint = pointsSpent
            maxName = name
        end
    end
    return maxName
end

local function SetTalentGear(group, name)
    for i in ipairs(TALENT_GROUPS) do
        if group == i then
            ns.char.spec.gears[i] = name
        elseif ns.char.spec.gears[i] == name then
            ns.char.spec.gears[i] = nil
        end
    end
end

local function OnClick(self, button)
    if button ~= 'RightButton' then
        return
    end
    if not self.name then
        return
    end
    if InCombatLockdown() then
        return
    end
    if ns.CloseMenu(self) then
        return
    end

    local numGroup = GetNumTalentGroups()
    if numGroup < 2 then
        return
    end

    local menu = { --
        {isTitle = true, text = '绑定到天赋', notCheckable = true},
    }

    for i, text in ipairs(TALENT_GROUPS) do
        tinsert(menu, {
            text = format('%s - %s', text, GetTalentName(i)),
            func = function()
                SetTalentGear(i, self.name)
            end,
            checked = function()
                return ns.char.spec.gears[i] == self.name
            end,
        })
    end

    ns.CallMenu(self, menu)
end

local buttons = ns.GetFrames('GearSetButton%d', MAX_EQUIPMENT_SETS_PER_PLAYER)

for _, button in ipairs(buttons) do
    button:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    button:HookScript('OnClick', OnClick)
end

ns.event('ACTIVE_TALENT_GROUP_CHANGED', function()
    local group = GetActiveTalentGroup()
    local gear = ns.char.spec.gears[group]
    if gear then
        local id = C_EquipmentSet.GetEquipmentSetID(gear)
        if id then
            C_EquipmentSet.UseEquipmentSet(id)
        end
    end
end)
