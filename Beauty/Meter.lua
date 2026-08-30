-- Meter.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/14/2026, 4:51:19 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_DamageMeter', function()
    local function UpdateStyle(self)
        local statusBar = self:GetStatusBar()
        statusBar:GetStatusBarTexture():SetTexture([[Interface\AddOns\!!!tdUI\Media\Statusbar_Clean.blp]])

        for _, v in ipairs(self:GetBackgroundRegions()) do
            v:Hide()
        end

        pcall(function()
            local name = self:GetName()
            local value = self:GetValue()
            -- local font, size, flag = name:GetFont()
            -- name:SetFont(font, size, '')
            -- name:SetShadowColor(0, 0, 0)
            -- value:SetFont(font, size, '')

            name:SetFontObject('GameFontHighlight')
            value:SetFontObject('GameFontHighlight')
        end)
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

    local function Hook(self)
        ns.securehook(self, 'UpdateStyle', UpdateStyle)
        ns.securehook(self, 'SetupDefaultStyle', SetupDefaultStyle)
    end

    local function SetupFrame(frame)
        if not frame then
            return
        end
        Hook(frame)
        UpdateStyle(frame)
        SetupDefaultStyle(frame)
    end

    Hook(DamageMeterEntryMixin)

    local MinimizeContainer = DamageMeterSessionWindow1 and DamageMeterSessionWindow1.MinimizeContainer
    if MinimizeContainer then
        for _, v in ipairs(MinimizeContainer.ScrollBox.view.frames) do
            SetupFrame(v)
        end

        SetupFrame(MinimizeContainer.LocalPlayerEntry)
    end
end)
