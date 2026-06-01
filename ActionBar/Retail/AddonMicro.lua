-- AddonMicro.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/15/2020, 3:49:17 PM
---@type ns
local ns = select(2, ...)

if not ns.CreateMicroButton then

    local buttons = {}

    local function OnMouseDown(self)
        self.icon:SetTexCoord(0.2666, 0.8666, 0, 0.8333)
        self.icon:SetAlpha(0.5)
    end

    local function OnMouseUp(self)
        self.icon:SetTexCoord(0.2, 0.8, 0.0666, 0.9)
        self.icon:SetAlpha(1.0)
    end

    local function OnEvent(self, event)
        if event == 'UPDATE_BINDINGS' then
            self.tooltipText = MicroButtonTooltipText(self.text, self.keybinding)
        end
    end

    local function SetButtonState(self, state, lock)
        self:SetButtonState(state, lock)

        if not self.icon then
            return
        end

        if state and state:upper() == 'PUSHED' then
            OnMouseDown(self)
        else
            OnMouseUp(self)
        end
    end

    function ns.CreateMicroButton(opts)
        local button = CreateFrame('Button', nil, MicroMenu, 'MainMenuBarMicroButton')

        if opts.template then
            LoadMicroButtonTextures(button, opts.template)
        elseif opts.icon then

            button:SetNormalTexture([[Interface\Buttons\UI-MicroButtonCharacter-Up]])
            button:SetPushedTexture([[Interface\Buttons\UI-MicroButtonCharacter-Down]])
            button:SetDisabledTexture([[Interface\Buttons\UI-MicroButtonCharacter-Disabled]])
            button:SetHighlightTexture([[Interface\Buttons\UI-MicroButton-Hilight]])

            local texCoords = {0, 1, 0.359375, 1}
            button:GetNormalTexture():SetTexCoord(unpack(texCoords))
            button:GetPushedTexture():SetTexCoord(unpack(texCoords))
            button:GetDisabledTexture():SetTexCoord(unpack(texCoords))
            button:GetHighlightTexture():SetTexCoord(unpack(texCoords))

            local icon = button:CreateTexture(nil, 'OVERLAY')
            icon:SetTexture(opts.icon)
            icon:SetSize(18, 25)
            icon:SetPoint('CENTER', 0, -1)
            button.icon = icon

            button:SetScript('OnMouseDown', OnMouseDown)
            button:SetScript('OnMouseUp', OnMouseUp)
            OnMouseUp(button)
        end

        if opts.keybinding then
            button.text = opts.text
            button.keybinding = opts.keybinding
            button.tooltipText = MicroButtonTooltipText(opts.text, opts.keybinding)
            button:RegisterEvent('UPDATE_BINDINGS')
            button:SetScript('OnEvent', OnEvent)
        else
            button.text = opts.text
            button.tooltipText = opts.text
        end

        if opts.frame then
            opts.frame:HookScript('OnShow', function()
                SetButtonState(button, 'PUSHED', true)
            end)
            opts.frame:HookScript('OnHide', function()
                SetButtonState(button, 'NORMAL')
            end)
        end

        if opts.onClick then
            button:SetScript('OnClick', opts.onClick)
        end

        button.opts = opts
        -- button.includeInLayout = true
        -- button.layoutIndex =
        button:Show()

        -- MicroMenu:AddButton(button)

        tinsert(buttons, button)
    end

    ns.securehook(MicroMenu, 'OverrideMicroMenuPosition',
                  function(self, parent, anchor, anchorTo, relAnchor, x, y, isStacked)
        self:SetPoint(anchor, anchorTo, relAnchor, x - 7, y)
    end)

    ns.securehook(MicroMenu, 'Layout', function(self)
        local layoutChildren = self:GetLayoutChildren()

        for _, button in ipairs(buttons) do
            local after = _G[button.opts.after]
            local i = tIndexOf(layoutChildren, after)

            tinsert(layoutChildren, i + 1, button)
        end

        -- Multipliers determine the direction the layout grows for grid layouts
        -- Positive means right/up
        -- Negative means left/down
        local xMultiplier = self.layoutFramesGoingRight and 1 or -1
        local yMultiplier = self.layoutFramesGoingUp and 1 or -1

        local stride = self.stride > 6 and 99 or 7

        -- Create the grid layout according to whether we are horizontal or vertical
        local layout
        if self.isHorizontal then
            layout = GridLayoutUtil.CreateStandardGridLayout(stride, self.childXPadding, self.childYPadding,
                                                             xMultiplier, yMultiplier)
        else
            layout = GridLayoutUtil.CreateVerticalGridLayout(stride, self.childXPadding, self.childYPadding,
                                                             xMultiplier, yMultiplier)
        end

        -- Need to change where the frames anchor based on how the layout grows
        local anchorPoint;
        if self.layoutFramesGoingUp then
            anchorPoint = self.layoutFramesGoingRight and 'BOTTOMLEFT' or 'BOTTOMRIGHT'
        else
            anchorPoint = self.layoutFramesGoingRight and 'TOPLEFT' or 'TOPRIGHT'
        end

        -- Apply the layout and then update our size
        GridLayoutUtil.ApplyGridLayout(layoutChildren, AnchorUtil.CreateAnchor(anchorPoint, self, anchorPoint), layout)
        ResizeLayoutMixin.Layout(self)
    end)
end

local function AtlasLootMicro(key)
    local AtlasLoot = _G[key]
    local L = AtlasLoot.Locales
    local SlashCommands = AtlasLoot.SlashCommands

    local Minimap = LibStub('LibDataBroker-1.1'):GetDataObjectByName(key)

    ns.CreateMicroButton {
        text = 'AtlasLoot',
        keybinding = 'ATLASLOOT_TOGGLE',
        template = 'EJ',
        frame = _G['AtlasLoot_GUI-Frame'],
        after = 'LFGMicroButton',
        onClick = Minimap.OnClick,
    }
end

ns.addon('AtlasLootClassic', function()
    AtlasLootMicro('AtlasLootClassic')
end)
ns.addon('AtlasLootMY', function()
    AtlasLootMicro('AtlasLootMY')
end)

ns.addon('MeetingHorn', function()
    local Addon = LibStub('AceAddon-3.0'):GetAddon('MeetingHorn')
    local L = LibStub('AceLocale-3.0'):GetLocale('MeetingHorn')

    ns.CreateMicroButton {
        text = L and L.ADDON_NAME or 'MeetingHorn',
        keybinding = 'MEETINGHORN_TOGGLE',
        icon = [[Interface\AddOns\MeetingHorn\Media\Logo]],
        -- template = 'LFG',
        frame = Addon.MainPanel,
        after = 'LFGMicroButton',
        onClick = function()
            return Addon:Toggle()
        end,
    }
end)

-- if not WorldMapMicroButton then
--     ns.CreateMicroButton {
--         text = WORLDMAP_BUTTON,
--         keybinding = 'TOGGLEWORLDMAP',
--         template = 'World',
--         frame = WorldMapFrame,
--         after = 'SocialsMicroButton',
--         onClick = ToggleWorldMap,
--         hideInOverrideBar = true,
--     }
-- end
