-- Questie.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 4/7/2024, 12:31:56 PM
--
---@type  ns
local ns = select(2, ...)
ns.addon('Questie', function()
    local QuestieTracker = QuestieLoader:ImportModule('QuestieTracker')
    local TrackerBaseFrame = QuestieLoader:ImportModule('TrackerBaseFrame')

    ns.securehook(QuestieTracker, 'Initialize', function()
        if not Questie_BaseFrame then
            return
        end
        ns.hide(Questie_Sizer)

        local env = ns.WatchManager:Register(Questie_BaseFrame, 6, {
            header = Questie_HeaderFrame,
            minimizeButton = Questie_HeaderFrame.trackedQuests,
        })

        ns.hook(QuestieTracker, 'UpdateWidth', function(orig, ...)
            if Questie.db.char.isTrackerExpanded then
                Questie_BaseFrame:SetWidth(ns.profile.watch.frame.width)
                TrackedQuests:SetWidth(ns.profile.watch.frame.width)
                TrackedQuests.ScrollChildFrame:SetWidth(ns.profile.watch.frame.width)
            else
                orig(...)
            end
        end)

        ns.securehook(QuestieTracker, 'Update', function()
            env.titleBg:SetShown(Questie.db.char.isTrackerExpanded)
        end)

        TrackerBaseFrame.SetSafePoint = function()
            QuestieTracker:Update()
        end

        ns.config('watch.frame.width', function()
            QuestieTracker:UpdateWidth()
        end)
    end)
end)
