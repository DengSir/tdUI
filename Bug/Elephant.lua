-- Elephant.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 1/17/2022, 11:00:36 PM
--
---@type ns
local ns = select(2, ...)

if GetLocale() ~= 'zhCN' then
    return
end

ns.addon('Elephant', function()
    ---@type Frame
    local ElephantFrame = _G.ElephantFrame

    local Elephant = LibStub('AceAddon-3.0'):GetAddon('Elephant')

    local function text(b, t)
        if not b then
            return
        end
        b:SetText(t)
    end

    ns.securehook(Elephant, 'OnEnable', function()
        text(ElephantFrameGuildTabButton, '会')
        text(ElephantFrameOfficerTabButton, '官')
        text(ElephantFrameWhisperTabButton, '密')
        text(ElephantFramePartyTabButton, '队')
        text(ElephantFrameRaidTabButton, '团')
        text(ElephantFrameInstanceTabButton, '本')
        text(ElephantFrameSayTabButton, '说')
        text(ElephantFrameYellTabButton, '喊')
    end)
end)
