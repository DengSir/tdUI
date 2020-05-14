-- Aura.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2019, 3:20:41 PM

---@type ns
local ns = select(2, ...)

local format = string.format
local ceil = math.ceil

ns.securehook('AuraButton_UpdateDuration', function(button, timeLeft)
    timeLeft = ceil(timeLeft)
    if timeLeft < 300 then
        button.duration:SetText(format('%d:%02d', timeLeft / 60, ceil(timeLeft % 60)))
    end
    if timeLeft > 3600 and timeLeft < 86400 then
        button.duration:SetText(format('%dh%2dm', timeLeft / 3600, timeLeft % 3600 / 60))
    end
end)
