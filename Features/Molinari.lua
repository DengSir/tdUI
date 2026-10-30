-- Molinari.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/27/2026, 11:21:13 PM
--
-- Baganator 背包面板一键 Molinari：免 Alt 分解/开锁/开启，银行/战团同样生效。
-- 原理：setfenv 给 Molinari 的判定函数换私有环境放行键位检查（不覆盖任何全局）；
-- 银行物品借用其 MODIFIER_STATE_CHANGED 直调路径（无 bagID 0-5 过滤）。
-- 结构：常驻驱动 frame 承载事件监听与显隐/布局逻辑，开关按钮纯渲染。
-- 依赖 Molinari.toc / Baganator.toc 声明 ## AllowAddOnTableAccess: 1（更新会覆盖）。
---@type ns
local ns = select(2, ...)

-- 会话状态，不落盘：默认关闭，关闭背包面板后自动取消
local enabled = false

ns.addon('Baganator', 'Molinari', function()
    local addonTable = C_AddOns.GetAddOnLocalTable('Baganator')
    local M = C_AddOns.GetAddOnLocalTable('Molinari')
    if not (addonTable and M and M.HookTooltip and M.RegisterOptionCallback) then
        return
    end

    -- _G.Molinari 即 Molinari 自建的同名安全按钮，插件加载完成即存在
    local button = _G.Molinari and _G.Molinari.ApplySpell and _G.Molinari
    if not button then
        return
    end

    -- 无相关技能的角色（分解/研磨/选矿/拆解/开锁/烹煮/挤压/转化一个都不会）用不上，不创建开关
    local HasAnySkill = false
    for _, spellID in ipairs({ 13262, 382994, 382995, 447311, 1804, 312890, 323427, 1259655, 404740, 430315 }) do
        if C_SpellBook.IsSpellKnown(spellID) then
            HasAnySkill = true
            break
        end
    end
    if not HasAnySkill then
        return
    end

    -- 上游遗漏：data/Standard/shatterable.lua 注册了 shatterable，api/colors.lua 没有对应颜色，
    -- 悬停碎裂类物品会在 SetColor 崩溃，这里补上（上游修复后此行为空操作）
    M.colors.shatterable = M.colors.shatterable or M.colors.disenchantable

    -- 判定函数的私有环境：仅放行键位检查，其余经 __index 透传真 _G；关闭时与原版等价
    local origIsAltKeyDown = IsAltKeyDown
    ns.hook(M, 'HookTooltip', function(orig, self, callback)
        setfenv(callback, setmetatable({
            IsAltKeyDown = function()
                return origIsAltKeyDown() or enabled
            end,
            IsControlKeyDown = function()
                return IsControlKeyDown() or (enabled and MolinariDB3.modifier == 'CTRL')
            end,
            IsShiftKeyDown = function()
                return IsShiftKeyDown() or (enabled and MolinariDB3.modifier == 'SHIFT')
            end,
        }, {__index = _G}))
        return orig(self, callback)
    end)

    -- 银行/战团：HookTooltip 注册路径有 bagID 0-5 过滤，借 MODIFIER_STATE_CHANGED
    -- 的直调路径（无过滤，等价于"悬停时按了一下 Alt"）
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, _)
        if not enabled or IsModifierKeyDown() or tooltip ~= GameTooltip then
            return
        end

        local owner = tooltip:GetOwner()
        if owner and owner.BGR then
            M:MODIFIER_STATE_CHANGED()
        end
    end)

    -- Shift/Ctrl 点击不触发动作，保留 Shift 链接、Ctrl 拾取
    button:SetAttribute('shift-type1', '')
    button:SetAttribute('ctrl-type1', '')

    -- 动作镜像到普通左键（type1）：无需 Alt 直接点击即可
    button:HookScript('OnAttributeChanged', function(self, name)
        if enabled and (name == 'spell' or name == 'item' or name == 'macrotext') then
            self:SetAttribute('type1', name:gsub('macrotext', 'macro'))
        end
    end)

    -- 常驻驱动 frame：承载事件监听、显隐与布局逻辑，开关按钮退化为纯渲染。
    -- 拿到包裹框架后创建并 parent 其下，随框架显隐
    local driver
    local function InitDriver(frame)
        driver = CreateFrame('Frame', nil, frame)
        driver.frame = frame
    end

    -- 转移按钮接回 Baganator 原布局（排序左侧或齿轮左侧）
    local function RestoreTransfer()
        local frame = driver.frame
        if frame.SortButton:IsShown() then
            frame.TransferButton:SetPoint('RIGHT', frame.SortButton, 'LEFT')
        else
            frame.TransferButton:SetPoint('RIGHT', frame.CustomiseButton, 'LEFT')
        end
    end

    local function DisableMode()
        if not enabled then
            return
        end
        enabled = false
        M:DeferMethod(button, 'SetAttribute', 'type1', nil)
        if button:IsShown() and not origIsAltKeyDown() then
            button:Hide()
        end
    end

    local function CreateSwitch(frame)
        -- 沿用 Baganator 自家的图标按钮模板
        local switch = CreateFrame('Button', nil, frame, 'BaganatorTooltipIconButtonTemplate')
        switch:SetFrameLevel(700)

        local icon = switch:CreateTexture(nil, 'ARTWORK')
        icon:SetTexture([[Interface\Buttons\UI-GroupLoot-DE-Up]])
        icon:SetSize(17, 17)
        icon:SetPoint('CENTER', 1, -1)
        icon:SetVertexColor(1, 0.82, 0)

        local indicator = switch:CreateTexture(nil, 'OVERLAY')
        indicator:SetTexture([[Interface\Buttons\CheckButtonHilight]])
        indicator:SetBlendMode('ADD')
        indicator:SetAllPoints()

        switch.icon = icon
        switch.indicator = indicator

        function switch:ApplyState()
            -- 战斗中禁用（不可点击）并置灰；非战斗始终可点击，仅以指示灯区分开关
            local combat = InCombatLockdown()
            self:SetEnabled(not combat)
            self.indicator:SetShown(enabled and not combat)
            self.icon:SetDesaturated(combat)
        end

        -- 插到转移与排序按钮之间
        function switch:Rearrange()
            local frame = driver.frame
            if frame.SortButton:IsShown() then
                self:SetPoint('RIGHT', frame.SortButton, 'LEFT')
            else
                self:SetPoint('RIGHT', frame.CustomiseButton, 'LEFT')
            end
            frame.TransferButton:SetPoint('RIGHT', self, 'LEFT')
        end

        switch:SetScript('OnShow', function(self)
            self:ApplyState()
            self:Rearrange()
        end)
        switch:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
            GameTooltip:SetText('一键 Molinari')
            GameTooltip:AddLine('悬停可分解/开锁/开启的物品时，无需按住 Alt，直接点击即可。',
                                1, 1, 1, true)
            GameTooltip:AddLine('银行/战团内同样生效；关闭背包面板后自动取消。',
                                GRAY_FONT_COLOR:GetRGB())
            GameTooltip:Show()
        end)
        switch:SetScript('OnLeave', GameTooltip_Hide)
        switch:SetScript('OnClick', function(self)
            enabled = not enabled
            if not enabled then
                DisableMode()
            end
            self:ApplyState()
        end)
        switch:HookScript('OnHide', function()
            RestoreTransfer()
        end)

        addonTable.Skins.AddFrame('IconButton', switch)

        return switch
    end

    -- 显隐刷新：仅本人实时数据视图显示开关
    local function RefreshShown()
        if driver.switch then
            driver.switch:SetShown(driver.frame.isLive and
                                       driver.frame.liveCharacter == Syndicator.API.GetCurrentCharacter())
        end
    end

    ns.securehook(addonTable.ItemViewCommon, 'GetAnchorSetter', function(frame, setting)
        if setting ~= addonTable.Config.Options.MAIN_VIEW_POSITION or driver then
            return
        end

        InitDriver(frame)
        driver.switch = CreateSwitch(frame)
        driver.switch:Hide()

        ns.securehook(frame, 'UpdateForCharacter', RefreshShown)
        frame:HookScript('OnShow', RefreshShown)
    end)

    -- 关闭背包面板自动取消选中
    ns.event('BAG_UPDATE_DELAYED', function()
        if not driver or not driver.frame:IsVisible() then
            DisableMode()
        end
    end)

    -- 战斗状态变化时刷新开关外观（监听常驻，渲染由开关自己同步）
    ns.event('PLAYER_REGEN_ENABLED', function()
        if driver and driver.switch:IsShown() then
            driver.switch:ApplyState()
        end
    end)
    ns.event('PLAYER_REGEN_DISABLED', function()
        if driver and driver.switch:IsShown() then
            driver.switch:ApplyState()
        end
    end)
end)
