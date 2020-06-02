-- WatchManager.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/27/2020, 11:47:42 PM

---@type ns
local ns = select(2, ...)

local WatchManager = CreateFrame('Frame', nil, UIParent)
ns.WatchManager = WatchManager

WatchManager:SetSize(1, 1)
WatchManager:SetPoint('TOPRIGHT', QuestWatchFrame, 'TOPRIGHT')

WatchManager.frames = {}
WatchManager.env = {}
WatchManager.debug = false

local function UpdateFrames()
    return WatchManager:Refresh()
end

function WatchManager:Register(frame, order, options)
    local env = options or {}

    tinsert(self.frames, frame)
    self.env[frame] = env
    self.env[frame].order = order

    sort(self.frames, function(a, b)
        return self.env[a].order < self.env[b].order
    end)

    if self.debug then
        local color = #self.frames % 2 == 0 and 1 or 0
        local bg = frame:CreateTexture(nil, 'BACKGROUND', nil, -8)
        bg:SetPoint('TOPLEFT', -(self.env[frame].marginLeft or 0), self.env[frame].marginTop or 0)
        bg:SetPoint('BOTTOMRIGHT', self.env[frame].marginRight or 0, -(self.env[frame].marginBottom or 0))
        bg:SetColorTexture(color, color, color, 0.3)
    end

    frame:HookScript('OnShow', UpdateFrames)
    frame:HookScript('OnHide', UpdateFrames)
    frame:SetFrameStrata('BACKGROUND')

    env.SetPoint = frame.SetPoint
    env.ClearAllPoints = frame.ClearAllPoints

    frame.SetPoint = nop
    frame.ClearAllPoints = nop
    frame.SetFrameStrata = nop

    if env.header then
        self:SetupHeaderFrame(frame, env.header)
    end
    if env.minimizeButton then
        self:SetupMinimizeButton(frame, env.minimizeButton)
    end

    self:Refresh()
end

function WatchManager:Refresh()
    local prevFrame, prevEnv
    for i, frame in ipairs(self.frames) do
        if frame:IsVisible() then
            local env = self.env[frame]

            local x = -(env.marginRight or 0) + (prevEnv and prevEnv.marginRight or 0)
            local y = -(env.marginTop or 0) - (prevEnv and prevEnv.marginBottom or 0)

            env.ClearAllPoints(frame)
            if prevFrame then
                env.SetPoint(frame, 'TOPRIGHT', prevFrame, 'BOTTOMRIGHT', x, y)
            else
                env.SetPoint(frame, 'TOPRIGHT', self, 'TOPRIGHT', x, y)
            end

            prevFrame = frame
            prevEnv = env
        end
    end
end

function WatchManager:SetupHeaderFrame(frame, header)
    local env = self.env[frame]

    header:ClearAllPoints()
    header:SetPoint('LEFT', frame, 'TOPLEFT', -(env.marginLeft or 0), -16 + (env.marginTop or 0))

    header.ClearAllPoints = nop
    header.SetPoint = nop

    local bg = header:CreateTexture(nil, 'BACKGROUND')
    bg:SetAtlas('Objective-Header', true)
    bg:SetPoint('LEFT', -25, -16)
    bg:SetWidth(ns.profile.Watch.frame.width + 40)

    env.titleBg = bg
end

local function Fold(button)
    button:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)
    button:GetPushedTexture():SetTexCoord(0.5, 1, 0, 0.5)
end

local function Unfold(button)
    button:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
    button:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1)
end

function WatchManager:SetupMinimizeButton(frame, button)
    local options = self.env[frame]

    button:ClearAllPoints()
    button:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -8 + (options.marginRight or 0), -8 + (options.marginTop or 0))
    button:SetSize(16, 16)
    button:SetNormalTexture([[Interface\Buttons\UI-Panel-QuestHideButton]])
    button:SetPushedTexture([[Interface\Buttons\UI-Panel-QuestHideButton]])
    button:SetHighlightTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]], 'ADD')
    button:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
    button:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1)

    button.Fold = Fold
    button.Unfold = Unfold

    button.SetNormalTexture = nop
    button.SetSize = nop
    button.SetWidth = nop
    button.SetHeight = nop
end

ns.config('Watch.frame.width', function()
    local width = ns.profile.Watch.frame.width + 40
    for _, frame in ipairs(WatchManager.frames) do
        local env = WatchManager.env[frame]
        if env.titleBg then
            env.titleBg:SetWidth(width)
        end
    end
end)
