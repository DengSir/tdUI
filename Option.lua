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

    local options = {
        type = 'group',
        name = 'tdUI',
        get = function(paths)
            return ns.config(paths)
        end,
        set = function(paths, value)
            return ns.config(paths, value)
        end,
        args = {
            Watch = treeItem('Watch', {
                frame = inline('Frame', {width = range('Width', 100, 500, 1)}),
                bar = inline('Bar', {
                    height = range('Height', 1, 64, 1),
                    inlineHeight = range('Inline height', 1, 64, 1),
                    spacing = range('Spacing', 0, 20, 1),
                    font = {
                        order = orderGen(),
                        name = 'Font',
                        type = 'select',
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable('font'),
                    },
                    fontSize = range('Font size', 6, 32, 0.5),
                    fontFlag = drop('Font flag', { --
                        {name = 'NONE', value = 'NONE'}, {name = 'OUTLINE', value = 'OUTLINE'},
                    }),
                    texture = {
                        order = orderGen(),
                        name = 'Texture',
                        type = 'select',
                        dialogControl = 'LSM30_Statusbar',
                        values = LSM:HashTable('statusbar'),
                    },
                }),
                Recount = inline('Recount', {maxLines = range('Max lines', 2, 40, 1)}),
                ThreatClassic2 = inline('ThreatClassic2', {maxLines = range('Max lines', 2, 40, 1)}),
            }),
        },
    }

    AceConfigRegistry:RegisterOptionsTable('tdUI', options)
    AceConfigDialog:AddToBlizOptions('tdUI', 'tdUI')
end)
