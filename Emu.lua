-- Emu.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/3/2020, 12:06:48 PM

---@type ns
local ns = select(2, ...)

ns.addon('alaTalentEmu', function()
    local emu = _G.__ala_meta__ and _G.__ala_meta__.emu
    if not emu then
        return
    end

    local origCreateMainFrame = emu.CreateMainFrame
    local origEmu_SetEquipment = emu.Emu_SetEquipment

    emu.CreateMainFrame = function()
        local mainFrame = origCreateMainFrame()
        local equipmentButton = mainFrame.objects.equipmentButton

        equipmentButton:HookScript('OnShow', ns.spawned(function()
            return emu.Emu_ToggleEquipmentFrame(mainFrame)
        end))

        return mainFrame
    end

    local function OnEvent(self, _, id, ok)
        if self._id ~= id then
            return
        end

        self:UnregisterEvent('GET_ITEM_INFO_RECEIVED')

        origEmu_SetEquipment(self, self._slot, self._item)

        self._id = nil
        self._slot = nil
        self._item = nil
    end

    emu.Emu_SetEquipment = function(icon, slot, item)
        origEmu_SetEquipment(icon, slot, item)

        if slot > 0 and not icon.link and item then
            local id = tonumber(item) or tonumber(item and item:match('item:(%d+)'))

            if id then
                icon._id = id
                icon._slot = slot
                icon._item = item

                icon:RegisterEvent('GET_ITEM_INFO_RECEIVED')
                icon:SetScript('OnEvent', OnEvent)
            end
        end
    end

    if not ATEMU then
        ATEMU = ALATEMU
    end

end)
