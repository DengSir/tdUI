-- 目标的目标的目标
---@type ns
local ns = select(2, ...)
local enable = false

local function Toggle(switch)
    if not ns.ToToTFrame then
        return
    end
    if switch then
        enable = true
        ns.ToToTFrame:RegisterEvent('UNIT_AURA')
        RegisterUnitWatch(ns.ToToTFrame)
    else
        enable = false
        ns.ToToTFrame:UnregisterEvent('UNIT_AURA')
        ns.ToToTFrame:Hide()
        UnregisterUnitWatch(ns.ToToTFrame)
    end
end

function tdTargetTargetTargetFrameInit(self)

    local ToToTFrame = self
    local TargetFrame = TargetFrame
    local ToTFrame = TargetFrameToT
    local TargetFrame_UpdateAuras = TargetFrame_UpdateAuras
    local UnitFrame_Initialize = UnitFrame_Initialize
    local SetTextStatusBarTextZeroText = SetTextStatusBarTextZeroText
    local SecureUnitButton_OnLoad = SecureUnitButton_OnLoad
    local UnitFrame_OnEvent = UnitFrame_OnEvent
    local RegisterUnitWatch = RegisterUnitWatch
    local UnregisterUnitWatch = UnregisterUnitWatch
    local UnitFrame_Update = UnitFrame_Update
    local RefreshDebuffs = RefreshDebuffs
    local UnitHealth = UnitHealth
    local UnitIsConnected = UnitIsConnected
    local UnitExists = UnitExists
    local UnitIsDead = UnitIsDead
    local UnitIsPlayer = UnitIsPlayer
    local UnitIsGhost = UnitIsGhost
    local UnitHealthMax = UnitHealthMax
    local UnitClass = UnitClass
    local GetClassColor = GetClassColor

    ns.ToToTFrame = self

    UnitFrame_Initialize(self, 'TargetTargetTarget', ToToTFrame.details.name, ToToTFrame.portrait, ToToTFrame.healthBar,
                         ToToTFrame.healthBar.TextString, ToToTFrame.manaBar, ToToTFrame.manaBar.TextString)

    SetTextStatusBarTextZeroText(ToToTFrame.healthBar, DEAD)
    SecureUnitButton_OnLoad(self, 'targettargettarget')

    local text = _G[ToTFrame:GetName() .. 'TextureFrame']:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    text:SetPoint('CENTER', ToTFrame, 'CENTER', 20, 1)
    text:SetTextColor(1, 1, 1)
    text:SetAlpha(0.8)

    self:SetScript('OnShow', function()
        TargetFrame_UpdateAuras(TargetFrame)
    end)
    self:SetScript('OnHide', function()
        TargetFrame_UpdateAuras(TargetFrame)
    end)
    self:SetScript('OnEvent', UnitFrame_OnEvent)

    local function CheckDead()
        if ((UnitHealth('TargetTarget') <= 0) and UnitIsConnected('TargetTarget')) then
            ToToTFrame.details.hp:Hide()
        else
            ToToTFrame.details.hp:Show()
        end

        if ((UnitHealth('TargetTargetTarget') <= 0) and UnitIsConnected('TargetTargetTarget')) then
            ToToTFrame.background:SetAlpha(0.9)
            ToToTFrame.details.deadText:Show()
            ToToTFrame.details.hp:Hide()
        else
            ToToTFrame.background:SetAlpha(1)
            ToToTFrame.details.deadText:Hide()
            ToToTFrame.details.hp:Show()
        end
    end

    local function HealthCheck()
        -- check tot
        if (UnitExists('targettarget')) then
            if (UnitIsDead('targettarget') or UnitIsGhost('targettarget')) then
                ToToTFrame.details.hp:Hide()
            else
                local unitCurrHP = UnitHealth('targettarget')
                local unitHPMax = UnitHealthMax('targettarget')
                ToTFrame.unitHPPercent = unitCurrHP / unitHPMax
                ToToTFrame.details.hp:SetText(string.format('%d%%', ToTFrame.unitHPPercent * 100))
                ToToTFrame.details.hp:Show()
            end
        end

        -- check totot
        if (UnitExists('TargetTargetTarget')) then
            if (UnitIsDead('TargetTargetTarget') or UnitIsGhost('TargetTargetTarget')) then
                ToToTFrame.details.hp:Hide()
                if (UnitIsPlayer('TargetTargetTarget')) then
                    if (UnitIsDead('TargetTargetTarget')) then
                        ToToTFrame.portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0)
                    elseif (UnitIsGhost('TargetTargetTarget')) then
                        ToToTFrame.portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0)
                    end
                end
            else
                local unitCurrHP = UnitHealth('TargetTargetTarget')
                local unitHPMax = UnitHealthMax('TargetTargetTarget')
                ToToTFrame.healthBar.unitHPPercent = unitCurrHP / unitHPMax
                ToToTFrame.details.hp:SetText(string.format('%d%%', ToToTFrame.healthBar.unitHPPercent * 100))
                ToToTFrame.details.hp:Show()

                if (UnitIsPlayer('TargetTargetTarget')) then
                    if ((ToToTFrame.healthBar.unitHPPercent > 0) and (ToToTFrame.healthBar.unitHPPercent <= 0.2)) then
                        ToToTFrame.portrait:SetVertexColor(1.0, 0.0, 0.0)
                    else
                        ToToTFrame.portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0)
                    end
                end
            end
        end
    end

    local function OnUpdate()
        if (not enable) then
            return
        end

        if UnitExists('target') and UnitExists('targettarget') and UnitExists('targettargettarget') then
            UnitFrame_Update(self)
            CheckDead()
            HealthCheck()
            RefreshDebuffs(self, 'targettargettarget')
            if (UnitIsPlayer('targettargettarget')) then
                local _, enClass = UnitClass('targettargettarget')
                ToToTFrame.details.name:SetTextColor(GetClassColor(enClass))
            else
                ToToTFrame.details.name:SetTextColor(1, 0.8, 0)
            end
        else
            ToToTFrame.details.name:SetTextColor(1, 0.8, 0)
        end
    end

    self:SetScript('OnUpdate', OnUpdate)
    hooksecurefunc('TargetofTarget_Update', function()
        OnUpdate()
    end)
    Toggle(true)

end

ns.config('unitframe.frame.totot', function()
    Toggle(ns.profile.unitframe.frame.totot)
end)
ns.load(function()
    Toggle(ns.profile.unitframe.frame.totot)
end)

