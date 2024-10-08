-- Config.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/1/2020, 1:49:54 PM
--
---@class ns
local ns = select(2, ...)

---@class Profile
local DEFAULT_PROFILE = {
    watch = { --
        frame = {width = 255},
        bar = { --
            height = 18,
            spacing = 2,
            texture = 'Blizzard',
            inlineHeight = 8,
        },
        font = { --
            name = nil,
            size = 13,
            style = 'OUTLINE',
            color = {r = 1, g = 1, b = 1, a = 0.8},
        },
        Recount = {maxLines = 10},
        ThreatClassic2 = {maxLines = 5},
    },
    actionbar = { --
        micro = { --
            position = 'RIGHT',
        },
        button = {macroName = false},
    },
    chat = { --
        shortChannels = {},
    },
    minimap = { --
        buttons = { --
            ignores = {},
        },
    },
    window = {minimap = {minimapPos = 215.34}},
    unitframe = {frame = {autoHide = true, totot = false}},
    keybindings = {vehicle = {}},
}

---@class Global
local DEFAULT_GLOBAL = {auction = {prices = {}}}

ns.load(function()
    ns.db = LibStub('AceDB-3.0'):New('TDDB_UI', { --
        profile = DEFAULT_PROFILE,
        global = DEFAULT_GLOBAL,
    }, true)

    ns.profile = ns.db.profile
    ns.global = ns.db.global

    if not TDDB_UI_CHAR then
        TDDB_UI_CHAR = {}
    end

    ns.char = TDDB_UI_CHAR

    ns.char.spec = ns.char.spec or {}
    ns.char.spec.gears = ns.char.spec.gears or {}
end)
