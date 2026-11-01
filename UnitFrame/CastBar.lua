-- CastBar.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
--
-- 目标/焦点施法条：打断技能在冷却中时，把可打断的敌方法术染红
--
---@type ns
local ns = select(2, ...)

local tinsert = tinsert

local nsConfig = ns.config

local SPELLBANK_PLAYER = Enum.SpellBookSpellBank.Player
local SPELLBANK_PET = Enum.SpellBookSpellBank.Pet

local CAST_BARS = {}
local INTERRUPT_COLOR = CreateColor(1, 0.2, 0.2)
local NORMAL_COLOR = CreateColor(1, 1, 1)

-- 各职业打断技能（参考 BetterBlizzPlates）
local interruptSpells = {
    [1766] = true, -- Kick (Rogue)
    [2139] = true, -- Counterspell (Mage)
    [6552] = true, -- Pummel (Warrior)
    [19647] = true, -- Spell Lock (Warlock)
    [47528] = true, -- Mind Freeze (Death Knight)
    [57994] = true, -- Wind Shear (Shaman)
    [96231] = true, -- Rebuke (Paladin)
    [106839] = true, -- Skull Bash (Feral)
    [115781] = true, -- Optical Blast (Warlock)
    [116705] = true, -- Spear Hand Strike (Monk)
    [119910] = true, -- Spell Lock (Warlock Pet)
    [89766] = true, -- Axe Toss (Warlock Pet)
    [132409] = true, -- Spell Lock (Grimoire of Service)
    [171138] = true, -- Shadow Lock (Warlock)
    [147362] = true, -- Countershot (Hunter)
    [183752] = true, -- Disrupt (Demon Hunter)
    [187707] = true, -- Muzzle (Hunter)
    [212619] = true, -- Call Felhunter (Warlock)
    [351338] = true, -- Quell (Evoker)
    [78675] = true, -- Solar Beam (Balance)
    [97547] = true, -- Solar Beam (Balance)
    [15487] = true, -- Silence (Shadow Priest)
}

-- 术士召唤/献祭宠物会改变可用的打断技能
local petSummonSpells = {
    [30146] = true, -- Summon Felguard
    [691] = true, -- Summon Felhunter
    [108503] = true, -- Grimoire of Sacrifice
}

local enabled
local playerKick
local kickReady -- true 可用 / false 冷却中 / nil 没有打断技能

local function GetInterruptSpell()
    for spellID in pairs(interruptSpells) do
        if C_SpellBook.IsSpellInSpellBook(spellID, SPELLBANK_PLAYER) or
            (UnitExists('pet') and C_SpellBook.IsSpellInSpellBook(spellID, SPELLBANK_PET)) then
            return spellID
        end
    end
end

local function UpdateCastBar(castBar)
    if castBar.classicStyleCastBar then
        return
    end

    local unit = castBar.unit
    local texture = castBar:GetStatusBarTexture()
    if not unit or not texture then
        return
    end

    if not (enabled and kickReady == false and castBar.showShield and UnitCanAttack('player', unit)) then
        -- 恢复白色只限施法进行中，避免抹掉施法结束/被打断时暴雪的填充颜色
        if castBar.casting or castBar.channeling or castBar.reverseChanneling then
            texture:SetVertexColor(NORMAL_COLOR:GetRGB())
        end
        return
    end

    -- casting/channeling/reverseChanneling 是暴雪按事件类型设置的普通标记
    if not (castBar.casting or castBar.channeling or castBar.reverseChanneling) then
        return
    end

    local _, _, _, _, _, isTradeskill, notInterruptible
    if castBar.channeling or castBar.reverseChanneling then
        -- 引导/蓄力法术走 UnitChannelInfo，可打断标志是第 7 个返回值
        _, _, _, _, _, isTradeskill, notInterruptible = UnitChannelInfo(unit)
    else
        _, _, _, _, _, isTradeskill, _, notInterruptible = UnitCastingInfo(unit)
    end

    -- 战斗中敌对目标的施法信息是秘密值：notInterruptible 不能读不能比（分支会抛错），
    -- isTradeskill 标记 NeverSecret，用它确认施法查询仍然有效；
    -- 选色交给引擎的 SetVertexColorFromBoolean：有盾(不可打断)→白色，可打断→红色
    if isTradeskill ~= nil then
        texture:SetVertexColorFromBoolean(notInterruptible, NORMAL_COLOR, INTERRUPT_COLOR)
    end
end

local function UpdateCastBars()
    for i = 1, #CAST_BARS do
        UpdateCastBar(CAST_BARS[i])
    end
end

local function HookCastBar(castBar)
    if castBar.tduiCastBarHooked then
        return
    end
    castBar.tduiCastBarHooked = true

    -- 暴雪每次更新填充都会重置颜色，在其后重新染色；isFull 是施法结束的填充，不处理
    ns.securehook(castBar, 'UpdateBarFillTexture', function(self, isFull)
        if not isFull then
            UpdateCastBar(self)
        end
    end)

    -- 备用触发：施法事件处理完后再染色一次，覆盖事件时序上的遗漏
    ns.hookscript(castBar, 'OnEvent', function(self)
        if self:IsShown() and (self.casting or self.channeling) then
            UpdateCastBar(self)
        end
    end)
end

local tracker = CreateFrame('Frame')
local trackerCooldown = CreateFrame('Cooldown', nil, tracker, 'CooldownFrameTemplate')
trackerCooldown:SetMinimumCountdownDuration(0)

trackerCooldown:HookScript('OnCooldownDone', function()
    kickReady = true
    UpdateCastBars()
end)

local function UpdateKickTracking()
    if not playerKick then
        playerKick = GetInterruptSpell()
    end

    if not playerKick then
        kickReady = nil
        return
    end

    -- ignoreGCD：公共冷却不算打断技能冷却
    local duration = C_Spell.GetSpellCooldownDuration(playerKick, true)
    if duration then
        trackerCooldown:SetCooldownFromDurationObject(duration)
        kickReady = not trackerCooldown:IsShown()
    else
        trackerCooldown:Clear()
        kickReady = true
    end
end

if TargetFrameSpellBar then
    tinsert(CAST_BARS, TargetFrameSpellBar)
    HookCastBar(TargetFrameSpellBar)
end

if FocusFrameSpellBar then
    tinsert(CAST_BARS, FocusFrameSpellBar)
    HookCastBar(FocusFrameSpellBar)
end

local eventFrame = CreateFrame('Frame')
eventFrame:RegisterEvent('SPELL_UPDATE_COOLDOWN')
eventFrame:RegisterEvent('SPELL_UPDATE_USABLE')
eventFrame:RegisterEvent('PLAYER_TALENT_UPDATE')
eventFrame:RegisterEvent('TRAIT_CONFIG_UPDATED')
eventFrame:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED', 'player')
eventFrame:SetScript('OnEvent', function(_, event, _, _, spellID)
    if event == 'UNIT_SPELLCAST_SUCCEEDED' then
        if not petSummonSpells[spellID] then
            return
        end
        playerKick = nil
        ns.after(0.1, function()
            UpdateKickTracking()
            UpdateCastBars()
        end)
    elseif event == 'SPELL_UPDATE_COOLDOWN' or event == 'SPELL_UPDATE_USABLE' then
        local old = kickReady
        UpdateKickTracking()
        if old ~= kickReady then
            UpdateCastBars()
        end
    else
        playerKick = nil
        UpdateKickTracking()
        UpdateCastBars()
    end
end)

ns.event('PLAYER_ENTERING_WORLD', function()
    playerKick = nil
    UpdateKickTracking()
end)

local function UpdateEnabled()
    enabled = nsConfig('unitframe.castbar.interruptColor')
    UpdateCastBars()
end

nsConfig('unitframe.castbar.interruptColor', UpdateEnabled)
UpdateEnabled()
