-- RaidUnit.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 9/4/2026, 4:47:18 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_CompactRaidFrames', function()
    ---@param frame Frame
    ns.securehook('CompactUnitFrame_SetUpFrame', function(frame)
        if not frame.groupType then
            return
        end

        frame.healthBar:GetStatusBarTexture():SetTexture([[Interface\AddOns\!!!tdUI\Media\Statusbar_Clean.blp]])

        -- local raidIndexIcon = frame:CreateTexture(nil, 'ARTWORK', nil, -1)
        -- raidIndexIcon:SetSize(12, 12)
        -- raidIndexIcon:SetPoint('TOPLEFT', 0, 0)
        -- frame.raidIndexIcon = raidIndexIcon
    end)

    ns.securehook('CompactUnitFrameLayoutTemplates_LayoutFrameElement', function(frame, _, _, containerTypeKey)
        if containerTypeKey == 'Role' then
            frame.roleIcon:SetHeight(13)
            frame.roleIcon:SetPoint('TOPRIGHT', -1, -1)
            frame.roleIcon:SetDrawLayer('ARTWORK', 4)
        end
    end)

    local function IsDpsFrame(frame)
        local atlas = frame.roleIcon:GetAtlas()

        if not issecretvalue(atlas) then
            return atlas == 'UI-LFG-RoleIcon-DPS-Micro-GroupFinder'
        end
    end

    local GroupType = Enum.EditModeUnitFrameSystemIndices

    ns.securehook('CompactUnitFrame_UpdateRoleIcon', function(frame)
        if not frame.roleIcon then
            return
        end
        if not frame.groupType then
            return
        end
        if not (frame.groupType == GroupType.Raid or frame.groupType == GroupType.Party) then
            return
        end

        if IsDpsFrame(frame) then
            frame.roleIcon:Hide()
            frame.roleIcon:SetWidth(1)
        end
    end)

    -- local function UpdateRaidTargetIcon(frame)
    --     print('UpdateRaidTargetIcon', frame)
    --     if frame.raidIndexIcon and frame.unit then
    --         local index = GetRaidTargetIndex(frame.unit)
    --         if index then
    --             SetRaidTargetIconTexture(frame.raidIndexIcon, index)
    --             frame.raidIndexIcon:Show()
    --         else
    --             frame.raidIndexIcon:Hide()
    --         end
    --     end
    -- end

    -- ns.securehook('CompactUnitFrame_UpdateUnitEvents', function(frame)
    --     frame:RegisterEvent('RAID_TARGET_UPDATE')
    -- end)

    -- ns.securehook('CompactUnitFrame_OnEvent', function(frame, event)
    --     if frame.isLootObject then
    --         return
    --     end

    --     if event == 'RAID_TARGET_UPDATE' then
    --         UpdateRaidTargetIcon(frame)
    --     end
    -- end)

    -- ns.securehook('CompactUnitFrame_UpdateAll', function(frame)
    --     UpdateRaidTargetIcon(frame)
    -- end)
end)
