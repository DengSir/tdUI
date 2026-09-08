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
end)
