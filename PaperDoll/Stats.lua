-- Stats.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/30/2026, 2:20:40 PM
--
-- 角色面板属性行旁用独立右对齐 FontString 显示评分数值
---@type ns
local ns = select(2, ...)

local format = string.format

local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating

-- 各属性的评分常量
-- 爆击取 CR_CRIT_MELEE：装备爆击评分统一计入三系，评分同值，无需按爆击率选系
-- （战斗中爆击率/爆击评分是 secret，不能比较；显示链 FontString:SetText 允许秘密值）
local RATINGS = {
    [STAT_CRITICAL_STRIKE] = CR_CRIT_MELEE,
    [STAT_HASTE] = CR_HASTE_MELEE,
    [STAT_MASTERY] = CR_MASTERY,
    [STAT_VERSATILITY] = CR_VERSATILITY_DAMAGE_DONE,
    [STAT_LIFESTEAL] = CR_LIFESTEAL,
    [STAT_AVOIDANCE] = CR_AVOIDANCE,
    [STAT_SPEED] = CR_SPEED,
    [STAT_DODGE] = CR_DODGE,
    [STAT_PARRY] = CR_PARRY,
    [STAT_BLOCK] = CR_BLOCK,
}

-- 属性行是暴雪的池化 Frame，不往其上挂字段，用弱键表旁挂评分文本，首次访问自动创建
-- 锚在行右缘固定偏移：评分列右边界固定（Value 百分比列右对齐在 -8），两列各自对齐
local ratingTexts = setmetatable({}, {
    __mode = 'k',
    __index = function(t, statFrame)
        local ratingText = statFrame:CreateFontString(nil, 'ARTWORK')
        ratingText:SetFontObject(statFrame.Value:GetFontObject())
        ratingText:SetTextColor(0.62, 0.62, 0.62)
        ratingText:SetPoint('RIGHT', statFrame, 'RIGHT', -45, 0)
        t[statFrame] = ratingText
        return ratingText
    end,
})

ns.securehook('PaperDollFrame_SetLabelAndText', function(statFrame, label)
    local ratingText = ratingTexts[statFrame]

    local rating = RATINGS[label]
    if not rating then
        ratingText:Hide()
        return
    end

    ratingText:SetText(format('(%s)', BreakUpLargeNumbers(GetCombatRating(rating))))
    ratingText:Show()
end)
