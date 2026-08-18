-- Meter.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/14/2026, 4:51:19 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_DamageMeter', function()

    local function Init(self)
        -- self:SetClipsChildren(false)

        -- local statusBar = self:GetStatusBar()
        -- statusBar:GetStatusBarTexture():SetTexture([[Interface\AddOns\!!!tdUI\Media\TargetingFrame\UI-StatusBar.blp]])
    end

    local function UpdateStyle(self)
        local statusBar = self:GetStatusBar()
        statusBar:GetStatusBarTexture():SetTexture([[Interface\AddOns\!!!tdUI\Media\TargetingFrame\UI-StatusBar.blp]])

        for _, v in ipairs(self:GetBackgroundRegions()) do
            -- ns.hide(v)
            v:Hide()
        end
    end

    local function SetupDefaultStyle(self)
        if self:GetStyle() ~= Enum.DamageMeterStyle.Default then
            return
        end
        local statusBar = self:GetStatusBar()
        statusBar:ClearAllPoints()

        if self:ShouldShowBarIcons() then
            statusBar:SetPoint('LEFT', self:GetIcon(), 'RIGHT', 0, 0)
        else
            statusBar:SetPoint('LEFT', 0, 0)
        end

        statusBar:SetPoint('TOP', 0, 0)
        statusBar:SetPoint('BOTTOMRIGHT', -4, 0)
    end

    local function SetBarHeight(self, height)
        self:SetHeight(height)
    end

    local function Hook(self)
        ns.securehook(self, 'Init', Init)
        ns.securehook(self, 'UpdateStyle', UpdateStyle)
        ns.securehook(self, 'SetupDefaultStyle', SetupDefaultStyle)
        -- ns.securehook(self, 'SetBarHeight', SetBarHeight)
    end

    local function SetupFrame(self)
        Hook(self)
        Init(self)
        UpdateStyle(self)
        SetupDefaultStyle(self)
    end

    Hook(DamageMeterEntryMixin)

    for _, v in ipairs(DamageMeterSessionWindow1.MinimizeContainer.ScrollBox.view.frames) do
        SetupFrame(v)
    end

    if DamageMeterSessionWindow1.MinimizeContainer.LocalPlayerEntry then
        SetupFrame(DamageMeterSessionWindow1.MinimizeContainer.LocalPlayerEntry)
    end
end)
