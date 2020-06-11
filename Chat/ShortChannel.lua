-- ShortChannel.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/11/2020, 11:31:24 AM

---@type ns
local ns = select(2, ...)

local format = string.format

local SHORTS = { --
    ['大脚世界频道'] = '世界',
    ['本地防务'] = '本地',
    ['世界防务'] = '防务',
    ['寻求组队'] = '组队',
}

ns.hook('ChatFrame_ResolvePrefixedChannelName', function(orig, value)
    local id, name = value:match('(%d+)%. (.+)')
    name = name:gsub('%s+-(.+)$', '')
    name = SHORTS[name] or name
    return orig(format('%s. %s', id, name))
end)
