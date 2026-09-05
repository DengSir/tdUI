-- Meter.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 7/14/2026, 4:51:19 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_DamageMeter', function()
    local function SetupDefaultStyle(self)
        local statusBar = self:GetStatusBar()
        local background = self:GetBackground()
        local bgEdge = self:GetBackgroundEdge()

        if self:GetStyle() == Enum.DamageMeterStyle.Default then
            statusBar:GetStatusBarTexture():SetTexture([[Interface\AddOns\!!!tdUI\Media\Statusbar_Clean.blp]])

            statusBar:ClearAllPoints()
            if self:ShouldShowBarIcons() then
                statusBar:SetPoint('LEFT', self:GetIcon(), 'RIGHT', 0, 0)
            else
                statusBar:SetPoint('LEFT', 0, 0)
            end
            statusBar:SetPoint('TOP', 0, 0)
            statusBar:SetPoint('BOTTOMRIGHT', -4, 0)

            background:SetTexture([[Interface\AddOns\!!!tdUI\Media\Statusbar_Clean.blp]])

            bgEdge:Hide()
        else
            statusBar:GetStatusBarTexture():SetAtlas([[UI-HUD-CoolDownManager-Bar]])

            background:SetAtlas([[ui-damagemeters-bar-shadowbg]])

            bgEdge:Show()
        end

        self:GetName():SetFontObject('GameFontHighlight')
        self:GetValue():SetFontObject('GameFontHighlight')
    end

    local function Hook(self)
        ns.securehook(self, 'SetupDefaultStyle', SetupDefaultStyle)
    end

    local function SetupFrame(frame)
        if not frame then
            return
        end
        Hook(frame)
        -- UpdateStyle(frame)
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
