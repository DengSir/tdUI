-- AudioDevices.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2/28/2026, 2:43:08 AM
--
---@type ns
local ns = select(2, ...)

ns.after(3, function()
    ns.event('VOICE_CHAT_OUTPUT_DEVICES_UPDATED', function()
        print('VOICE_CHAT_OUTPUT_DEVICES_UPDATED')
        if tonumber(GetCVar('Sound_OutputDriverIndex')) == 0 then
            Sound_GameSystem_RestartSoundSystem()
        end
    end)
end)
