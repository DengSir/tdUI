-- Inspect.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/11/2020, 12:58:12 PM

---@type ns
local ns = select(2, ...)

ns.addon('tdInspect', 'MeetingHorn', function()
    local MeetingHorn = LibStub('AceAddon-3.0'):GetAddon('MeetingHorn')
    local tdInspect = LibStub('AceAddon-3.0'):GetAddon('tdInspect')

    local Browser = MeetingHorn:GetClass('UI.Browser')
    local Inspect = tdInspect:GetModule('Inspect')

    ns.hook(Browser, 'CreateActivityMenu', function(orig, self, activity)
        local r = orig(self, activity)
        tinsert(r, 3, {
            text = INSPECT,
            func = function()
                Inspect:Query(nil, activity:GetLeader())
            end,
        })
        return r
    end)
end)
