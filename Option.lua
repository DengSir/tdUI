-- Option.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/2/2020, 12:57:20 PM

---@type ns
local ns = select(2, ...)

ns.login(function()
    local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
    local AceConfigDialog = LibStub('AceConfigDialog-3.0')
    local LSM = LibStub('LibSharedMedia-3.0')

    local order = 0
    local function orderGen()
        order = order + 1
        return order
    end

    local function treeTitle(name)
        return {type = 'group', name = '|cffffd100' .. name .. '|r', order = orderGen(), args = {}, disabled = true}
    end

    local function treeItem(name, args)
        return {type = 'group', name = '  |cffffffff' .. name .. '|r', order = orderGen(), args = args}
    end

    local function inline(name, args)
        return {type = 'group', name = name, inline = true, order = orderGen(), args = args}
    end

    local function range(name, min, max, step)
        return {type = 'range', order = orderGen(), name = name, min = min, max = max, step = step}
    end

    local function rgba(name)
        return {type = 'color', order = orderGen(), name = name, hasAlpha = true}
    end

    local function font(name)
        return {
            type = 'select',
            order = orderGen(),
            name = name,
            dialogControl = 'LSM30_Font',
            values = LSM:HashTable('font'),
        }
    end

    local function statusbar(name)
        return {
            type = 'select',
            order = orderGen(),
            name = name,
            dialogControl = 'LSM30_Statusbar',
            values = LSM:HashTable('statusbar'),
        }
    end

    local function drop(name, values)
        local opts = { --
            type = 'select',
            name = name,
            order = orderGen(),
        }

        if type(values) == 'function' then
            opts.values = values
        else
            opts.values = {}
            opts.sorting = {}

            for i, v in ipairs(values) do
                opts.values[v.value] = v.name
                opts.sorting[i] = v.value
            end
        end
        return opts
    end

    local function toggle(name)
        return {type = 'toggle', name = name, order = orderGen()}
    end

    local options = {
        type = 'group',
        name = 'tdUI',
        get = function(paths)
            if paths.type == 'color' then
                local color = ns.config(paths)
                return color.r, color.g, color.b, color.a
            else
                return ns.config(paths)
            end
        end,
        set = function(paths, ...)
            if paths.type == 'color' then
                local color = {}
                color.r, color.g, color.b, color.a = ...
                ns.config(paths, color)
            else
                local value = ...
                return ns.config(paths, value)
            end
        end,
        args = {
            watch = treeItem('Trackers', {
                frame = inline('Frame', {width = range('Width', 100, 500, 1)}),
                bar = inline('Bar', {
                    height = range('Height', 1, 64, 1),
                    inlineHeight = range('Inline height', 1, 64, 1),
                    spacing = range('Spacing', 0, 20, 1),
                    texture = statusbar('Texture'),
                }),
                font = inline('Font', {
                    name = font('Font name'),
                    size = range('Font size', 6, 32, 0.5),
                    style = drop('Font flag', { --
                        {name = 'NONE', value = ''}, --
                        {name = 'OUTLINE', value = 'OUTLINE'}, --
                        {name = 'THICKOUTLINE', value = 'THICKOUTLINE'},--
                    }),
                    color = rgba('Font color'),
                }),
                Recount = inline('Recount', { --
                    maxLines = range('Max lines', 2, 40, 1),
                }),
                ThreatClassic2 = inline('ThreatClassic2', { --
                    maxLines = range('Max lines', 2, 40, 1),
                }),
            }),
            actionbar = treeItem('Action bar', {
                micro = inline('Micro bar', {
                    position = drop('Position', { --
                        {name = 'Left', value = 'LEFT'}, {name = 'Right', value = 'RIGHT'},
                    }),
                }),
            }),
            tooltip = treeItem('Tooltip', {itemIcon = toggle('Item icon'), itemLevelOnlyEquip = toggle('Show item level on equipment only')}),
        },
    }

    AceConfigRegistry:RegisterOptionsTable('tdUI', options)
    AceConfigDialog:AddToBlizOptions('tdUI', 'tdUI')

    local AceGUI = LibStub('AceGUI-3.0')
end)
