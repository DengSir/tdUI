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

local WIDTH = 61

GearManagerDialogSaveSet:SetWidth(WIDTH)
GearManagerDialogDeleteSet:SetWidth(WIDTH)
GearManagerDialogEquipSet:SetWidth(WIDTH)

ns.point(GearManagerDialogSaveSet, 'BOTTOMRIGHT', -7, 12)
ns.point(GearManagerDialogDeleteSet, 'RIGHT', GearManagerDialogSaveSet, 'LEFT')
ns.point(GearManagerDialogEquipSet, 'BOTTOMLEFT', 10, 12)

local BindButton = CreateFrame('Button', nil, GearManagerDialog, 'UIPanelButtonTemplate')
BindButton:SetSize(WIDTH, 22)
BindButton:SetPoint('LEFT', GearManagerDialogEquipSet, 'RIGHT')
BindButton:SetText(TALENT)
BindButton:Disable()
BindButton:SetScript('OnClick', function(self)
    local name = GearManagerDialog.selectedSetName
    if not name then
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
                SetTalentGear(i, name)
            end,
            checked = function()
                return ns.char.spec.gears[i] == name
            end,
        })
    end

    ns.CallMenu(self, menu)
end)

GearManagerDialogEquipSet:HookScript('OnEnable', function()
    BindButton:Enable()
end)
GearManagerDialogEquipSet:HookScript('OnDisable', function()
    BindButton:Disable()
end)

ns.securehook('GearManagerDialog_Update', CloseDropDownMenus)

-- @build>99@

local TalentButton = CreateFrame('Button', nil, TalentMicroButton)
TalentButton:SetAllPoints(true)
TalentButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
TalentButton:SetScript('OnClick', function(self, button)
    if button == 'LeftButton' then
        ToggleTalentFrame()
    else
        if InCombatLockdown() then
            return
        end
        if ns.CloseMenu(self) then
            return
        end

        GameTooltip_Hide()

        local menu = { --
            {isTitle = true, text = '切换天赋', notCheckable = true},
        }

        for i, text in ipairs(TALENT_GROUPS) do
            tinsert(menu, {
                text = format('%s - %s', text, GetTalentName(i)),
                func = function()
                    SetActiveTalentGroup(i)
                end,
                checked = function()
                    return GetActiveTalentGroup() == i
                end,
            })
        end

        ns.CallMenu(self, menu)
    end
end)
TalentButton:SetScript('OnEnter', function()
    TalentMicroButton:LockHighlight()
    TalentMicroButton:GetScript('OnEnter')(TalentMicroButton)
end)
TalentButton:SetScript('OnLeave', function()
    TalentMicroButton:UnlockHighlight()
    TalentMicroButton:GetScript('OnLeave')(TalentMicroButton)
end)
TalentButton:SetScript('OnMouseDown', function()
    TalentMicroButton:SetButtonState('PUSHED', true)
end)
TalentButton:SetScript('OnMouseUp', function()
    TalentMicroButton:SetButtonState('NORMAL')
end)

-- @end-build>99@
