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

    -- for i, obj in ipairs({ElephantFrame:GetChildren()}) do
    --     if obj:GetObjectType() == 'Button' and obj:GetName():find('TabButton$') then
    --         if _G[obj:GetName() .. 'Text'] then
    --             print(obj)
    --         end
    --     end
    -- end

    ns.securehook(Elephant, 'OnEnable', function()
        ElephantFrameGuildTabButton:SetText('会')
        ElephantFrameOfficerTabButton:SetText('官')
        ElephantFrameWhisperTabButton:SetText('密')
        ElephantFramePartyTabButton:SetText('队')
        ElephantFrameRaidTabButton:SetText('团')
        -- ElephantFrameInstanceTabButton:SetText('本')
        ElephantFrameSayTabButton:SetText('说')
        ElephantFrameYellTabButton:SetText('喊')
    end)
end)
