-- LoseBuff.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 2022/4/21 14:27:01
--
---@type ns
local ns = select(2, ...)

local Flask = tInvert {
    28520, -- 无情突袭合剂
    28521, -- 盲目光芒合剂
    28540, -- 纯粹死亡合剂
    41608, -- 沙塔斯无情突袭
    42735, -- 多彩奇迹
    17627, -- 精炼智慧
    28518, -- 强固合剂
    28519, -- 强效回复合剂
    46837, -- 沙塔斯纯净死亡
    41609, -- 沙塔斯强固
    46839, -- 沙塔斯盲目光芒
    17628, -- 超级能量
    41611, -- 沙塔斯超级能量
    41610, -- 沙塔斯强效回复
    17629, -- 多彩抗性
}

local BattleElixir = tInvert {
    28503, -- 特效暗影能量
    45373, -- 血莓
    38954, -- 魔能力量药剂
    28497, -- 特效敏捷
    28501, -- 特效火力
    28493, -- 特效冰霜能量
    33726, -- 掌控药剂
    28491, -- 治疗能量
    28490, -- 特效力量
    33721, -- 法能药剂
    33720, -- 强攻药剂
    17539, -- 强效奥法药剂
    11406, -- 屠魔药剂
    17538, -- 猫鼬药剂
}

local GuardianElixir = tInvert {
    28514, -- 增效
    28509, -- 强效法力回复
    28502, -- 特效护甲
    39628, -- 铁皮药剂
    39627, -- 德莱尼智慧药剂
    39626, -- 土灵药剂
    39625, -- 特效坚韧药剂
    17535, -- 先知药剂
    11371, -- 阿尔萨斯的礼物
    11396, -- 强效智力
}

local RefreshBuffList

local BUFFS, LIST = {}, {}
do
    local function GetGroupClassCount()
        local counts = {}
        for _, unit in ns.IterateGroup() do
            if UnitIsConnected(unit) then
                local class = UnitClassBase(unit)
                if class then
                    counts[class] = (counts[class] or 0) + 1
                end
            end
        end
        return counts
    end

    local function GetMajorTalent()
        local bestIndex, bestPoints
        for i = 1, GetNumTalentTabs() do
            local points = select(3, GetTalentTabInfo(i))

            if not bestIndex or bestPoints < points then
                bestIndex = i
                bestPoints = points
            end
        end
        return bestIndex
    end

    local counts
    local function AddBuff(cls, clsCount, buffs)
        if not clsCount then
            buffs = cls
        else
            if not counts[cls] or counts[cls] < clsCount then
                return
            end
        end

        local minorId = buffs[1]

        tinsert(LIST, minorId)

        for _, spellId in ipairs(buffs) do
            BUFFS[spellId] = minorId
        end
    end

    local function SetElixir(b, g, f)
        BATTLE, GUARDIAN, FLASK = b, g, f
    end

    local BlessingofKings = {25898, 20217} -- 王者
    local BlessingofMight = {27141, 27140} -- 力量
    local BlessingofLight = {27145, 27144} -- 光明
    local BlessingofSalvation = {25895, 1038} -- 拯救
    local BlessingofWisdom = {27143, 27142} -- 智慧
    local MarkoftheWild = {26991, 26990} -- 爪子
    local PowerWordFortitude = {25392, 25389} -- 耐力
    local ArcaneIntellect = {27127, 27126, 46302} -- 智力

    local Food = {
        19705,
        19706,
        19708,
        19709,
        19710,
        19711,
        24799,
        24870,
        25694,
        25941,
        33254,
        33256,
        33257,
        33259,
        33261,
        33263,
        33265,
        33268,
        33272,
        35272,
        40323,
        43764,
        43771,
        45245,
        45619,
        46682,
        46687,
        46899,
    }

    function RefreshBuffList()
        local class = UnitClassBase('player')
        counts = GetGroupClassCount()
        local minorTalent = GetMajorTalent()

        wipe(BUFFS)
        wipe(LIST)

        if not IsInGroup(1) then
            return
        end

        AddBuff(Food)

        if class == 'WARRIOR' then
            if minorTalent == 3 then -- 防护
                AddBuff('PALADIN', 1, BlessingofKings)
                AddBuff('PALADIN', 2, BlessingofMight)
                AddBuff('PALADIN', 3, BlessingofLight)
            else -- 武器、狂怒
                AddBuff('PALADIN', 1, BlessingofSalvation)
                AddBuff('PALADIN', 2, BlessingofKings)
                AddBuff('PALADIN', 3, BlessingofMight)
            end
        elseif class == 'PALADIN' then
            if minorTalent == 1 then -- 神圣
                AddBuff('PALADIN', 1, BlessingofSalvation)
                AddBuff('PALADIN', 2, BlessingofKings)
                AddBuff('PALADIN', 3, BlessingofWisdom)
                AddBuff('PALADIN', 4, BlessingofLight)
                -- SetElixir(28491, 39627)
            elseif minorTalent == 2 then -- 防护
                AddBuff('PALADIN', 1, BlessingofKings)
                AddBuff('PALADIN', 2, BlessingofWisdom)
                AddBuff('PALADIN', 3, BlessingofMight)
                AddBuff('PALADIN', 4, BlessingofLight)
            else -- 惩戒
                AddBuff('PALADIN', 1, BlessingofSalvation)
                AddBuff('PALADIN', 2, BlessingofKings)
                AddBuff('PALADIN', 3, BlessingofMight)
                AddBuff('PALADIN', 4, BlessingofWisdom)
                -- SetElixir(28491, 39627)
            end
            AddBuff('MAGE', 1, ArcaneIntellect)
        elseif class == 'WARLOCK' or class == 'MAGE' or class == 'PRIEST' then
            AddBuff('PALADIN', 1, BlessingofSalvation)
            AddBuff('PALADIN', 2, BlessingofKings)
            AddBuff('PALADIN', 3, BlessingofWisdom)
            AddBuff('PALADIN', 4, BlessingofLight)
            AddBuff('MAGE', 1, ArcaneIntellect)
        elseif class == 'ROGUE' then
            AddBuff('PALADIN', 1, BlessingofSalvation)
            AddBuff('PALADIN', 2, BlessingofKings)
            AddBuff('PALADIN', 3, BlessingofMight)
        elseif class == 'HUNTER' then
            AddBuff('PALADIN', 1, BlessingofSalvation)
            AddBuff('PALADIN', 2, BlessingofKings)
            AddBuff('PALADIN', 3, BlessingofMight)
            AddBuff('PALADIN', 4, BlessingofWisdom)
            AddBuff('MAGE', 1, ArcaneIntellect)
        elseif class == 'SHAMAN' then
            if minorTalent == 2 then -- 增强
                AddBuff('PALADIN', 1, BlessingofSalvation)
                AddBuff('PALADIN', 2, BlessingofKings)
                AddBuff('PALADIN', 3, BlessingofMight)
                AddBuff('PALADIN', 4, BlessingofWisdom)
            else
                AddBuff('PALADIN', 1, BlessingofSalvation)
                AddBuff('PALADIN', 2, BlessingofKings)
                AddBuff('PALADIN', 3, BlessingofWisdom)
                AddBuff('PALADIN', 4, BlessingofLight)
            end
            AddBuff('MAGE', 1, ArcaneIntellect)
        end

        -- 职业特殊
        if class == 'MAGE' then
            AddBuff({27125, 30482, 27124, 6117})
        end

        if class == 'WARLOCK' then
            AddBuff({28189, 27260}) -- 甲

            if IsSpellKnown(18788) then
                AddBuff({18791, 18789, 18790, 18792}) -- 牺牲
            end
        end

        if class == 'PALADIN' and minorTalent == 2 then
            AddBuff({25780}) -- 正义之怒
        end

        if class == 'HUNTER' then
            AddBuff({27044, 34074, 27045}) -- 守护
        end

        AddBuff('DRUID', 1, MarkoftheWild)
        AddBuff('PRIEST', 1, PowerWordFortitude)
    end
    RefreshBuffList()
end

---@class BuffButton: Button, Object
local BuffButton = ns.class('Button')
BuffButton.buttons = {}

function BuffButton:Constructor()
    self:SetSize(30, 30)
    self:SetAlpha(0.8)

    local Icon = self:CreateTexture(nil, 'ARTWORK')
    Icon:SetAllPoints(true)
    Icon:SetDesaturated(true)

    self.Icon = Icon

    -- self:SetScript('OnEnter', self.OnEnter)
    -- self:SetScript('OnLeave', GameTooltip_Hide)
end

function BuffButton:OnEnter()
    GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
    GameTooltip:SetSpellByID(self.spellId)
    GameTooltip:Show()
end

function BuffButton:SetSpell(spellId)
    self.spellId = spellId
    self.Icon:SetTexture(select(3, GetSpellInfo(spellId)))
end

function BuffButton:Get(index)
    if not self.buttons[index] then
        local button = self:New(BuffFrame)
        self.buttons[index] = button
    end
    return self.buttons[index]
end

function BuffButton:SetIndex(offset)
    local x = -((offset - 1) % BUFFS_PER_ROW) * (30 - BUFF_HORIZ_SPACING)
    local y = -math.floor((offset - 1) / BUFFS_PER_ROW) * (30 + BUFF_ROW_SPACING)

    self:ClearAllPoints()
    self:SetPoint('TOPRIGHT', x, y)
end

local function Update()
    local exists = {}
    local hasBattleElixir
    local hasGuardianElixir

    for i = 1, 32 do
        local name, _, _, _, _, _, _, _, _, spellId = UnitBuff('player', i)
        if not name then
            break
        end

        local show = BUFFS[spellId]
        if show then
            exists[show] = true
        end

        if Flask[spellId] then
            hasBattleElixir = true
            hasGuardianElixir = true
        end
        if BattleElixir[spellId] then
            hasBattleElixir = true
        end
        if GuardianElixir[spellId] then
            hasGuardianElixir = true
        end
    end


    local numBuffs = BuffFrame.numEnchants + BUFF_ACTUAL_DISPLAY

    local index = 1
    for _, spellId in ipairs(LIST) do
        if not exists[spellId] then
            local button = BuffButton:Get(index)

            button:SetSpell(spellId)
            button:SetIndex(numBuffs + index)
            button:Show()

            index = index + 1
        end
    end

    if not hasBattleElixir then
        local button = BuffButton:Get(index)
        button:SetSpell(28503)
        button:SetIndex(numBuffs + index)
        button:Show()

        index = index + 1
    end

    if not hasGuardianElixir then
        local button = BuffButton:Get(index)
        button:SetSpell(28514)
        button:SetIndex(numBuffs + index)
        button:Show()

        index = index + 1
    end

    for i = index, #BuffButton.buttons do
        BuffButton.buttons[i]:Hide()
    end
end

ns.securehook('BuffFrame_Update', Update)
ns.event('GROUP_ROSTER_UPDATE', RefreshBuffList)
ns.event('CHARACTER_POINTS_CHANGED', RefreshBuffList)
ns.load(RefreshBuffList)

TemporaryEnchantFrame:SetHeight(30)
