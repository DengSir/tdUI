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
WatchManager.options = {}
WatchManager.debug = false

local function UpdateFrames()
    return WatchManager:Refresh()
end

function WatchManager:Register(frame, order, options)
    options = options or {}

    tinsert(self.frames, frame)
    self.options[frame] = options
    self.options[frame].order = order

    sort(self.frames, function(a, b)
        return self.options[a].order < self.options[b].order
    end)

    frame:HookScript('OnShow', UpdateFrames)
    frame:HookScript('OnHide', UpdateFrames)

    if self.debug then
        local color = #self.frames % 2 == 0 and 1 or 0
        local bg = frame:CreateTexture(nil, 'BACKGROUND', nil, -8)
        bg:SetPoint('TOPLEFT', -(self.options[frame].marginLeft or 0), self.options[frame].marginTop or 0)
        bg:SetPoint('BOTTOMRIGHT', self.options[frame].marginRight or 0, -(self.options[frame].marginBottom or 0))
        bg:SetColorTexture(color, color, color, 0.3)
    end

    if options.header then
        self:SetupHeaderFrame(frame, options.header)
    end
    if options.minimizeButton then
        self:SetupMinimizeButton(frame, options.minimizeButton)
    end

    self:Refresh()
end

function WatchManager:Refresh()
    local prevFrame, prevOptions
    for i, frame in ipairs(self.frames) do
        if frame:IsVisible() then

            local options = self.options[frame]

            local x = -(options and options.marginRight or 0) + (prevOptions and prevOptions.marginRight or 0)
            local y = -(options and options.marginTop or 0) - (prevOptions and prevOptions.marginBottom or 0)

            frame:ClearAllPoints()

            local setPoint = frame.origSetPoint or frame.SetPoint
            if prevFrame then
                setPoint(frame, 'TOPRIGHT', prevFrame, 'BOTTOMRIGHT', x, y)
            else
                setPoint(frame, 'TOPRIGHT', self, 'TOPRIGHT', x, y)
            end

            prevFrame = frame
            prevOptions = options
        end
    end
end

function WatchManager:SetupHeaderFrame(frame, header)
    local options = self.options[frame]

    header:ClearAllPoints()
    header:SetPoint('LEFT', frame, 'TOPLEFT', -(options.marginLeft or 0), -16 + (options.marginTop or 0))

    header.ClearAllPoints = nop
    header.SetPoint = nop

    local bg = header:CreateTexture(nil, 'BACKGROUND')
    bg:SetAtlas('Objective-Header', true)
    bg:SetPoint('LEFT', -25, -16)
    bg:SetWidth(TDDB_UI.Watch.frame.width + 40)

    options.titleBg = bg
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
    local options = self.options[frame]

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

ns.config({'Watch', 'frame', 'width'}, function()
    local width = TDDB_UI.Watch.frame.width + 40
    for _, frame in ipairs(WatchManager.frames) do
        local options = WatchManager.options[frame]
        if options.titleBg then
            options.titleBg:SetWidth(width)
        end
    end
end)
