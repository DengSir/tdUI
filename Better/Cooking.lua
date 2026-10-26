-- Cooking.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/27/2026, 1:20:00 PM
--
---@type ns
local ns = select(2, ...)

ns.addon('Blizzard_Professions', function()
    local CHEF_HAT_ITEM_ID = 134020
    local CHEF_HAT_BUFF_SPELL_ID = 67556
    local CAMPFIRE_SPELL_ID = 818

    local GetItemIconByID = C_Item.GetItemIconByID
    local GetSpellTexture = C_Spell.GetSpellTexture

    local function IsSpellKnownByID(spellID)
        if C_SpellBook and C_SpellBook.IsSpellKnown then
            local ok, known = pcall(C_SpellBook.IsSpellKnown, spellID, Enum.SpellBookSpellBank.Player)
            if ok then
                return known and true or false
            end
        end
        return true
    end

    local function HasAura(spellID)
        if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
            return C_UnitAuras.GetPlayerAuraBySpellID(spellID) ~= nil
        end
        return false
    end

    local function CreateIconButton(parent, texture)
        local button = CreateFrame('Button', nil, parent, 'InsecureActionButtonTemplate')
        button:SetSize(36, 36)
        button:RegisterForClicks('AnyUp')
        button:SetAttribute('useOnKeyDown', false)

        button.Icon = button:CreateTexture(nil, 'BACKGROUND')
        button.Icon:SetAllPoints()
        button.Icon:SetTexture(texture)

        button.IconBorder = button:CreateTexture(nil, 'OVERLAY')
        button.IconBorder:SetAllPoints()
        button.IconBorder:SetTexture([[Interface\Common\WhiteIconFrame]])
        button.IconBorder:SetBlendMode('ADD')

        button.Cooldown = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate')
        button.Cooldown:SetAllPoints()
        button.Cooldown:SetFrameLevel(button:GetFrameLevel() + 1)

        button.SpellAlert = CreateFrame('Frame', nil, button, 'ActionButtonSpellAlertTemplate')
        button.SpellAlert:SetSize(36 * 1.4, 36 * 1.4)
        button.SpellAlert:SetPoint('CENTER', button, 'CENTER', 0, 0)

        button:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]], 'ADD')

        function button:UpdateTooltip()
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            if self.itemID then
                if PlayerHasToy(self.itemID) then
                    GameTooltip:SetToyByItemID(self.itemID)
                else
                    GameTooltip:SetItemByID(self.itemID)
                end
            else
                GameTooltip:SetSpellByID(self.spellID)
            end
            GameTooltip:Show()
        end

        function button:UpdateState(available)
            self:SetEnabled(available)
            self.Icon:SetDesaturated(not available)
        end

        function button:UpdateCooldown()
            if self.spellID then
                local info = C_Spell.GetSpellCooldown(self.spellID)
                if info then
                    if info.isActive then
                        self.Cooldown:SetCooldown(info.startTime, info.duration, info.modRate)
                    else
                        self.Cooldown:Clear()
                    end
                end
            else
                local start, duration, enabled = C_Container.GetItemCooldown(self.itemID)
                if start and duration then
                    CooldownFrame_Set(self.Cooldown, start, duration, enabled)
                end
            end
        end

        function button:SetAlert(shown)
            if self.alertShown == shown then
                return
            end
            self.alertShown = shown
            if shown then
                self.SpellAlert:Show()
                self.SpellAlert.ProcLoop:Play()
            else
                self.SpellAlert:Hide()
                self.SpellAlert.ProcLoop:Stop()
            end
        end

        return button
    end

    local CraftingPage = ProfessionsFrame.CraftingPage

    local Toolbar = CreateFrame('Frame', nil, CraftingPage)
    Toolbar:SetPoint('TOPLEFT', CraftingPage, 'TOPLEFT', 80, -31)
    Toolbar:SetSize(77, 36)
    Toolbar:Hide()

    local HatButton = CreateIconButton(Toolbar, GetItemIconByID(CHEF_HAT_ITEM_ID))
    HatButton:SetPoint('TOPLEFT', Toolbar, 'TOPLEFT', 0, 0)
    HatButton.itemID = CHEF_HAT_ITEM_ID
    HatButton:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    HatButton:SetAttribute('type', 'toy')
    HatButton:SetAttribute('toy', CHEF_HAT_ITEM_ID)
    HatButton:SetAttribute('*type2', 'cancelaura')
    local spellInfo = C_Spell.GetSpellInfo(CHEF_HAT_BUFF_SPELL_ID)
    HatButton:SetAttribute('spell-2', spellInfo and spellInfo.name)
    HatButton:SetScript('OnEnter', HatButton.UpdateTooltip)
    HatButton:SetScript('OnLeave', GameTooltip_Hide)

    function HatButton:IsAvailable()
        return PlayerHasToy(CHEF_HAT_ITEM_ID) and true or false
    end

    local FireButton = CreateIconButton(Toolbar, GetSpellTexture(CAMPFIRE_SPELL_ID))
    FireButton:SetPoint('TOPLEFT', HatButton, 'TOPRIGHT', 5, 0)
    FireButton:SetAttribute('type', 'spell')
    FireButton:SetAttribute('spell', CAMPFIRE_SPELL_ID)
    FireButton:SetAttribute('unit', 'player')
    FireButton.spellID = CAMPFIRE_SPELL_ID
    FireButton:SetScript('OnEnter', FireButton.UpdateTooltip)
    FireButton:SetScript('OnLeave', GameTooltip_Hide)

    function FireButton:IsAvailable()
        return IsSpellKnownByID(CAMPFIRE_SPELL_ID)
    end

    local function IsRecipeRequirementUnmet()
        local recipeInfo = CraftingPage.SchematicForm:GetRecipeInfo()
        if not recipeInfo or not recipeInfo.recipeID then
            return false
        end

        local requirements = C_TradeSkillUI.GetRecipeRequirements(recipeInfo.recipeID)
        if not requirements then
            return false
        end

        for _, requirement in ipairs(requirements) do
            if not requirement.met then
                return true
            end
        end
        return false
    end

    function Toolbar:UpdateStates()
        HatButton:UpdateState(HatButton:IsAvailable())
        FireButton:UpdateState(FireButton:IsAvailable())
    end

    function Toolbar:UpdateCooldowns()
        HatButton:UpdateCooldown()
        FireButton:UpdateCooldown()
    end

    function Toolbar:UpdateAlerts()
        if not self:IsShown() then
            return
        end
        HatButton:SetAlert(HatButton:IsEnabled() and not HasAura(CHEF_HAT_BUFF_SPELL_ID))
        FireButton:SetAlert(FireButton:IsEnabled() and IsRecipeRequirementUnmet())
    end

    function Toolbar:Update()
        local professionInfo = ProfessionsFrame.professionInfo
        local minimized = ProfessionsUtil.IsCraftingMinimized()
        local shown = ProfessionsFrame:IsShown()
            and CraftingPage:IsShown()
            and not InCombatLockdown()
            and Professions.InLocalCraftingMode()
            and professionInfo
            and professionInfo.profession == Enum.Profession.Cooking

        self:ClearAllPoints()
        if minimized then
            self:SetPoint('TOPLEFT', CraftingPage, 'TOPLEFT', 80, -24)
        else
            self:SetPoint('TOPLEFT', CraftingPage, 'TOPLEFT', 80, -31)
        end

        self:SetShown(shown)
        if shown then
            self:UpdateStates()
            self:UpdateCooldowns()
            self:UpdateAlerts()
        end
    end

    function Toolbar:OnShow()
        self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        self:RegisterEvent('BAG_UPDATE_COOLDOWN')
        self:RegisterEvent('SPELL_UPDATE_USABLE')
        self:RegisterUnitEvent('UNIT_AURA', 'player')
        self:RegisterEvent('TOYS_UPDATED')
        self:RegisterEvent('PLAYER_REGEN_DISABLED')
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
    end

    function Toolbar:OnHide()
        self:UnregisterAllEvents()
    end

    function Toolbar:OnEvent(event)
        if event == 'SPELL_UPDATE_COOLDOWN' or event == 'BAG_UPDATE_COOLDOWN' then
            self:UpdateCooldowns()
        elseif event == 'SPELL_UPDATE_USABLE' or event == 'UNIT_AURA' then
            self:UpdateAlerts()
        elseif event == 'TOYS_UPDATED' then
            self:UpdateStates()
            self:UpdateAlerts()
        else
            self:Update()
        end
    end

    Toolbar:SetScript('OnShow', Toolbar.OnShow)
    Toolbar:SetScript('OnHide', Toolbar.OnHide)
    Toolbar:SetScript('OnEvent', Toolbar.OnEvent)

    EventRegistry:RegisterCallback('ProfessionsFrame.Show', Toolbar.Update, Toolbar)
    EventRegistry:RegisterCallback('ProfessionsFrame.Hide', Toolbar.Update, Toolbar)
    EventRegistry:RegisterCallback('ProfessionsFrame.TabSet', Toolbar.Update, Toolbar)
    EventRegistry:RegisterCallback('Professions.ProfessionSelected', Toolbar.Update, Toolbar)
end)
