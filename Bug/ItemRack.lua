-- ItemRack.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/4/2020, 1:26:08 PM

---@type ns
local ns = select(2, ...)

ns.addon('ItemRack', function()
    local t = ItemRackUser.QueuesEnabled
    for k, v in pairs(t) do
        t[k] = v or nil
    end
end)

ns.addon('ItemRackOptions', function()
    ns.hook(ItemRackOptQueueEnable, 'GetChecked', function(orig, self)
        return orig(self) or nil
    end)
end)
