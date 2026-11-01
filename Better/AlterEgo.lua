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

    local function TranslateDungeons(dungeons)
        local abbrs = {
            [658] = '矿坑',
            [1209] = '通天',
            [1753] = '执政',
            [2526] = '学院',
            [2805] = '风塔',
            [2811] = '平台',
            [2874] = '洞窟',
            [2915] = '节点',
            [2993] = '毒牙',
            [2813] = '密谋',
            [2825] = '洞穴',
            [2859] = '夺目',
            [2923] = '虚痕',
            [1762] = '诸王',
            [1877] = '神庙',
            [2521] = '红玉',
        }

        for _, v in ipairs(dungeons) do
            v.abbr = abbrs[v.mapId] or v.abbr
        end
    end

    TranslateDungeons(LiqUI.Data.dungeons)

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

    local function AffixesSetColumns(orig, frame, columns)
        columns[1].width = 140
        columns[2].width = 180
        columns[3].width = 70
        columns[4].width = 70
        columns[5].width = 140
        return orig(frame, columns)
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
        if options.name == 'AlterEgoEquipment' then
            ns.hook(instance, 'Render', EquipmentRender)
        elseif options.name == 'AlterEgoAffixes' then
            ns.hook(instance, 'SetColumns', AffixesSetColumns)
        end
        return instance
    end)
end)
