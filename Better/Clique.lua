-- Clique.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/11/2026, 2:06:01 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Clique', function()
    ns.hook(Clique, 'SetupDatabase', function(orig, ...)
        setfenv(orig, setmetatable({
            LibStub = function(name, ...)
                if name == 'AceDB-3.0' then
                    local AceDB = LibStub('AceDB-3.0', ...)

                    return setmetatable({
                        New = function(_, n, default)
                            local _, classKey = UnitClass('player')
                            return LibStub('AceDB-3.0'):New(n, default, classKey)
                        end,
                    }, {__index = AceDB})
                else
                    return LibStub(name, ...)
                end
            end,

        }, {__index = _G}))

        return orig(...)
    end)
end)
