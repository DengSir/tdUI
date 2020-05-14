-- Channel.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/16/2020, 12:53:56 PM

---@type ns
local ns = select(2, ...)

local function GetChannelId(name)
    local id = GetChannelName(name)
    return id and id ~= 0 and id or nil
end

local function JoinChannel(name)
    local timer
    timer = C_Timer.NewTicker(1, function()
        local id = GetChannelId(name)
        if not id then
            JoinChannelByName(name)
        else
            timer:Cancel()
        end
    end)
end

if not GetChannelId('大脚世界频道') then
    ns.onceeventdelay('CHANNEL_UI_UPDATE', 5, function()
        JoinChannel('大脚世界频道')
    end)
end
