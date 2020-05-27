-- WatchManager.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/27/2020, 11:47:42 PM

---@type ns
local ns = select(2, ...)

local WatchManager = CreateFrame('Frame', nil, UIParent)
WatchManager:SetSize(1, 1)
WatchManager:SetPoint('TOPRIGHT', QuestWatchFrame, 'TOPRIGHT')
WatchManager.frames = {}
WatchManager.options = {}
ns.WatchManager = WatchManager

local function UpdateFrames()
    return WatchManager:UpdateFrames()
end

function WatchManager:Register(frame, options)
    tinsert(self.frames, frame)
    self.options[frame] = options

    frame:HookScript('OnShow', UpdateFrames)
    frame:HookScript('OnHide', UpdateFrames)
end

function WatchManager:UpdateFrames()
    local prevFrame, prevOptions
    for i, frame in ipairs(self.frames) do
        if frame:IsVisible() then

            local options = self.options[frame]

            local x = -(options and options.marginRight or 0) + (prevOptions and prevOptions.marginRight or 0)
            local y = (options and options.marginTop or 0) - (prevOptions and prevOptions.marginBottom or 0)

            frame:ClearAllPoints()
            if prevFrame then
                frame:SetPoint('TOPRIGHT', prevFrame, 'BOTTOMRIGHT', x, y)
            else
                frame:SetPoint('TOPRIGHT', self, 'TOPRIGHT', x, y)
            end

            prevFrame = frame
            prevOptions = options
        end
    end
end
