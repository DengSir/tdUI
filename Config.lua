-- Config.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/1/2020, 1:49:54 PM
---@type ns
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
    },
    tooltip = { --
        item = { --
            icon = true,
            rarityBorder = true,
            itemLevel = true,
            itemLevelOnlyEquip = false,
        },
    },
    chat = { --
        shortChannels = {},
    },
    minimap = { --
        buttons = {column = 4, ignores = {}},
    },
    window = {minimap = {minimapPos = 215.34}},
}

ns.load(function()
    ns.db = LibStub('AceDB-3.0'):New('TDDB_UI', {profile = DEFAULT_PROFILE}, true)
    ns.profile = ns.db.profile
end)
