-- PaperDoll.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/18/2020, 1:08:03 AM

---@type ns
local ns = select(2, ...)
local Inspect = ns.Inspect

ns.addon('Blizzard_InspectUI', function()
    local function UpdateButton(button)
        local item = Inspect:GetItemLink(button:GetID())
        if item then
            button.hasItem = 1

            local quality = select(3, GetItemInfo(item))
            if not quality then
                ns.waititem(item, button, UpdateButton)
            end
            if quality and quality > 1 then
                local r, g, b = GetItemQualityColor(quality)
                button.IconBorder:SetVertexColor(r, g, b, 0.5)
                button.IconBorder:Show()
            else
                button.IconBorder:Hide()
            end

            SetItemButtonTexture(button, GetItemIcon(item))
        else
            button.hasItem = nil
            button.IconBorder:Hide()

            local icon = button.backgroundTextureName
            if button.checkRelic then
                local unit = Inspect:GetUnit()
                if unit and UnitHasRelicSlot(unit) then
                    icon = [[Interface\Paperdoll\UI-PaperDoll-Slot-Relic.blp]]
                end
            end

            SetItemButtonTexture(button, icon)
        end
    end

    local function OnEnter(button)
        GameTooltip:SetOwner(button, 'ANCHOR_RIGHT')
        local item = Inspect:GetItemLink(button:GetID())
        if item then
            GameTooltip:SetHyperlink(item)
        else
            GameTooltip:SetText(_G[strupper(strsub(button:GetName(), 8))])
        end
        CursorUpdate(button)
    end

    local function OnClick(button)
        local item = Inspect:GetItemLink(button:GetID())
        if item then
            HandleModifiedItemClick(item)
        end
    end

    local function UpdateInfo()
        local unit = Inspect:GetUnit()
        if unit then
            local level = UnitLevel(unit)
            local class, classFileName = UnitClass(unit)
            local race = UnitRace(unit)

            class = ns.strcolor(class, GetClassColor(classFileName))

            InspectLevelText:SetFormattedText(PLAYER_LEVEL, level, race, class)
        else
            InspectLevelText:SetText('')
        end
    end

    InspectPaperDollItemSlotButton_Update = UpdateButton
    InspectPaperDollItemSlotButton_OnEnter = OnEnter
    InspectPaperDollItemSlotButton_OnClick = OnClick

    InspectFrame:HookScript('OnShow', function(self)
        if self.unit then
            return
        end

        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
        InspectFramePortrait:SetTexture([[Interface\FriendsFrame\FriendsFrameScrollIcon]])
        InspectNameText:SetText(Ambiguate(Inspect:GetUnitName(), 'none'))
    end)

    InspectFrame:HookScript('OnHide', function()
        Inspect:Clear()
    end)

    InspectPaperDollFrame:SetScript('OnShow', function()
        UpdateInfo()
    end)

    Inspect:Callback(function(name)
        if name == Inspect:GetUnitName() then
            ShowUIPanel(InspectFrame)
            InspectPaperDollFrame_UpdateButtons()
        end
    end)
end)
