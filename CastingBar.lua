-- CastingBar.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 3/14/2020, 6:48:09 PM
-- CastingBarFrame:SetAttribute('ignoreFramePositionManager', true)
-- UIPARENT_MANAGED_FRAME_POSITIONS.CastingBarFrame = nil
-- UIPARENT_MANAGED_FRAME_POSITIONS.ArcheologyDigsiteProgressBar.castingBar = nil
---@type ns
local ns = select(2, ...)

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
        ElephantFrameInstanceTabButton:SetText('本')
        ElephantFrameSayTabButton:SetText('说')
        ElephantFrameYellTabButton:SetText('喊')
    end)
end)
