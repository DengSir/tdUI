-- Config.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/1/2020, 1:49:54 PM

---@type ns
local ns = select(2, ...)

---@class Profile
local DEFAULT_PROFILE = {
    Watch = { --
        frame = {width = 255},
        bar = { --
            height = 18,
            spacing = 2,
            font = nil,
            fontSize = 13,
            fontFlag = 'OUTLINE',
            texture = 'BantoBar',
        },
        Recount = {maxLines = 10},
        ThreatClassic2 = {maxLines = 5},
    },
}

ns.load(function()
    ns.db = LibStub('AceDB-3.0'):New('TDDB_UI', {profile = DEFAULT_PROFILE}, true)
    ns.profile = ns.db.profile
end)
