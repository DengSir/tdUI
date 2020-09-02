-- Option.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/2/2020, 12:57:20 PM
---@type ns
local ns = select(2, ...)

local optionFrame
local AceConfigRegistry = LibStub('AceConfigRegistry-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')
local LSM = LibStub('LibSharedMedia-3.0')
local L = setmetatable({}, {
    __index = function(t, k)
        return k
    end,
})

ns.login(function()

    local SHORT_CHANNELS = {}

    local order = 0
    local function orderGen()
        order = order + 1
        return order
    end

    local function treeTitle(name)
        return {type = 'group', name = '|cffffd100' .. name .. '|r', order = orderGen(), args = {}, disabled = true}
    end

    local function treeItem(name)
        return function(args)
            return {type = 'group', name = '  |cffffffff' .. name .. '|r', order = orderGen(), args = args}
        end
    end

    local function inline(name)
        return function(args)
            return {type = 'group', name = name, inline = true, order = orderGen(), args = args}
        end
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
        return function(values)
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
    end

    local function toggle(name)
        return {type = 'toggle', name = name, order = orderGen()}
    end

    local function fulltoggle(name)
        return {type = 'toggle', name = name, order = orderGen(), width = 'full'}
    end

    local function path(paths)
        return table.concat(paths, '.')
    end

    local options = {
        type = 'group',
        name = 'tdUI',
        get = function(paths)
            if paths.type == 'color' then
                local color = ns.config(path(paths))
                return color.r, color.g, color.b, color.a
            else
                return ns.config(path(paths))
            end
        end,
        set = function(paths, ...)
            if paths.type == 'color' then
                local color = {}
                color.r, color.g, color.b, color.a = ...
                ns.config(path(paths), color)
            else
                local value = ...
                return ns.config(path(paths), value)
            end
        end,
        args = {
            actionbar = treeItem(ACTIONBARS_LABEL) {
                ['button.macroName'] = fulltoggle('Show or hide macro`s name'),
                ['micro.position'] = drop(L['Micro menu bar location']) { --
                    {name = 'Left', value = 'LEFT'},
                    {name = 'Right', value = 'RIGHT'},
                    {name = 'Hide', value = 'HIDE'},
                },
            },
            watch = treeItem(L['Right watch panel']) {
                frame = inline(L['Frame']) { --
                    width = range('Width', 100, 500, 1),
                },
                bar = inline(L['Bar']) {
                    height = range(L['Height'], 1, 64, 1),
                    inlineHeight = range(L['Inline height'], 1, 64, 1),
                    spacing = range(L['Spacing'], 0, 20, 1),
                    texture = statusbar(L['Texture']),
                },
                font = inline(L['Font']) {
                    name = font(L['Font name']),
                    size = range(L['Font size'], 6, 32, 0.5),
                    style = drop(L['Font flag']) { --
                        {name = L.NONE, value = ''}, --
                        {name = L.OUTLINE, value = 'OUTLINE'}, --
                        {name = L.THICKOUTLINE, value = 'THICKOUTLINE'}, --
                    },
                    color = rgba(L['Font color']),
                },
                Recount = inline 'Recount' { --
                    maxLines = range(L['Max lines'], 2, 40, 1),
                },
                ThreatClassic2 = inline 'ThreatClassic2' { --
                    maxLines = range(L['Max lines'], 2, 40, 1),
                },
            },
            tooltip = treeItem 'Tooltip' {
                item = inline 'Item' {
                    icon = toggle('Item icon'),
                    itemLevelOnlyEquip = toggle('Show item level on equipment only'),
                },
            },
            chat = treeItem 'Chat' { --
                shortChannels = inline 'Short channel'(SHORT_CHANNELS),
            },
            unitframe = treeItem 'UnitFrame' {
                frame = inline 'Frame' {
                    autoHide = fulltoggle('Auto hide unit frame when power full'),
                    totot = fulltoggle('Target Of Target Of Target'),
                },
            },
            auction = treeItem 'Auction' {
                sell = inline 'Sell' {
                    stackSize = drop('Stack size') { --
                        {name = 'Max', value = 0},
                        {name = '1', value = 1},
                    },
                    duration = drop('Duration') { --
                        {name = '2 ' .. HOURS, value = 1},
                        {name = '8 ' .. HOURS, value = 2},
                        {name = '24 ' .. HOURS, value = 3},
                    },
                    durationNoDeposit = drop('Duration no deposit') {
                        {name = 'Ignore', value = 0},
                        {name = '2 ' .. HOURS, value = 1},
                        {name = '8 ' .. HOURS, value = 2},
                        {name = '24 ' .. HOURS, value = 3},
                    },
                },
            },
        },
    }

    AceConfigRegistry:RegisterOptionsTable('tdUI', options)
    optionFrame = AceConfigDialog:AddToBlizOptions('tdUI', 'tdUI')
end)

local function OpenToCategory(options)
    InterfaceOptionsFrame_OpenToCategory(options)
    InterfaceOptionsFrame_OpenToCategory(options)
    OpenToCategory = InterfaceOptionsFrame_OpenToCategory
end

function ns.OpenOption()
    -- OpenToCategory(optionFrame)

    AceConfigDialog:Open('tdUI')
end
