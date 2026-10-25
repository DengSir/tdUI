-- AlterEgo.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/21/2026, 11:52:05 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('AlterEgo', function()

    local LiqUI = LibStub('LiqUI-1.0', true)
    if not LiqUI then
        return
    end

    local positions = {}

    local function OnShow(window)
        local pos = positions[window]
        if not pos then
            return
        end
        window:ClearAllPoints()
        window:SetPoint(SafeUnpack(pos))
    end

    local function HookPosition(window, ...)
        positions[window] = SafePack(...)
        window:HookScript('OnShow', OnShow)
    end

    local function HookCreate(elementType, fn)
        ns.hook(LiqUI.elements, elementType, fn)
    end

    local function ItemNameRender(cellData, rowData, rowIndex)
        local text = cellData.data:gsub('%[', ''):gsub('%]', '')
        return text
    end

    HookCreate('Window', function(orig, options)
        local instance = orig(options)
        local name = instance:GetName()
        if name == 'LiqUIWindowAlterEgoEquipment' then
            HookPosition(instance, 'TOPLEFT', 'LiqUIWindowAlterEgoMain', 'TOPRIGHT', 1, 0)
        elseif name == 'LiqUIWindowAlterEgoAffixes' then
            HookPosition(instance, 'BOTTOMLEFT', 'LiqUIWindowAlterEgoMain', 'BOTTOMRIGHT', 1, 0)
        end

        instance:SetClampRectInsets(0, 0, 0, 0)
        instance.SetClampRectInsets = nop

        return instance
    end)

    local function EquipmentRender(orig, frame)
        orig(frame)

        if frame.isRendering or frame.renderQueued then
            return
        end

        local inited = false

        for _, row in ipairs(frame.rowFrames) do
            if row.cells[2] then
                local label = row.cells[2].label
                label:SetFontObject(ChatFontNormal)
                label.SetFontObject = nop

                inited = true
            end
        end

        if inited then
            frame.Render = orig
        end
    end

    HookCreate('Table', function(orig, options)
        if options.name == 'AlterEgoEquipment' then
            local columns = options.columns
            columns[1].width = 50
            columns[2].width = 220
            columns[3].width = 50
            columns[4].width = 80

            columns[2].render = ItemNameRender
        end

        local instance = orig(options)
        local name = instance:GetName()
        if name == 'LiqUITableAlterEgoEquipment' then
            ns.hook(instance, 'Render', EquipmentRender)
        end
        return instance
    end)
end)
