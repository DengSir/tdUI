-- QuickMenu.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/31/2026, 9:01:07 AM
--
-- 角色面板右下角快捷图标：专精图标按钮（菜单：上天赋方案、下专精）+ 战争模式开关
-- 事件由各按钮自理：OnShow 注册 / OnHide 注销 / OnEvent 分发到自身方法（随面板显隐触发）
---@type ns
local ns = select(2, ...)

local format = string.format

local pane = PaperDollItemsFrame

local BUTTON_SIZE = 22
local BUTTON_GAP = 2

local HIGHLIGHT_TEXTURE = [[Interface\Buttons\ButtonHilight-Square]]

-- 两个按钮共用的图标底子
local function SetupIconButton(button)
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    button:SetFrameLevel(pane:GetFrameLevel() + 10)

    local content = button:CreateTexture(nil, 'ARTWORK')
    content:SetAllPoints()
    content:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.Content = content

    local highlight = button:CreateTexture(nil, 'HIGHLIGHT')
    highlight:SetAllPoints()
    highlight:SetTexture(HIGHLIGHT_TEXTURE)
    highlight:SetBlendMode('ADD')
end

--------------------------------------------------------------------
-- 专精菜单按钮：图标显示当前专精，点开合并菜单（上天赋方案、下专精）
-- 菜单回调挂在按钮对象上（Menu 以普通函数回传 data），不暴露模块级裸函数
--------------------------------------------------------------------
local TalentButton = CreateFrame('DropdownButton', nil, pane)
TalentButton:SetPoint('BOTTOMLEFT', CharacterFrameInset, 'BOTTOMLEFT', 4, 4)
TalentButton:SetFrameLevel(pane:GetFrameLevel() + 10)
-- 按钮在右下角，菜单向下弹出、左缘对齐
TalentButton:SetMenuAnchor(AnchorUtil.CreateAnchor('TOPLEFT', TalentButton, 'BOTTOMLEFT', 0, 0))

SetupIconButton(TalentButton)

function TalentButton:EnsureTalentFrame()
    if not PlayerSpellsFrame and not InCombatLockdown() then
        PlayerSpellsFrame_LoadUI()
    end

    -- 战斗中 LoadUI 会被引擎拒绝，PlayerSpellsFrame 可能仍为 nil
    local talentsFrame = PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame
    if not talentsFrame then
        return talentsFrame
    end

    -- 面板从未显示过时内存选中未初始化（CheckSetSelectedConfigID 因 IsShown 早退）：
    -- 不补齐的话 IsDefaultLoadout 误判在默认方案上，首次选方案会弹"离开默认方案"确认
    if not talentsFrame.lastSelectedConfigID then
        local specID = PlayerUtil.GetCurrentSpecID()
        local lastSelected = specID and C_ClassTalents.GetLastSelectedSavedConfigID(specID)
        if lastSelected then
            talentsFrame.lastSelectedConfigID = lastSelected
        end
    end

    return talentsFrame
end

function TalentButton:OnShow()
    -- 菜单生成器推迟到首次显示时挂载：SetupMenu 在 IsShown 为真时会立即 GenerateMenu，
    -- 而按钮创建时自身 shown 标记即为真（父控件隐藏只影响 IsVisible），
    -- 在加载阶段挂载会导致 BuildMenu 随插件加载运行并提前拉起天赋面板
    if not self.menuGenerator then
        self:SetupMenu(function(_, rootDescription)
            self:BuildMenu(rootDescription)
        end)
    end

    self:RegisterUnitEvent('PLAYER_SPECIALIZATION_CHANGED', 'player')
    self:UpdateSpecIcon()
end

function TalentButton:OnHide()
    self:UnregisterAllEvents()
end

function TalentButton:OnEvent()
    self:UpdateSpecIcon()
end

function TalentButton:UpdateSpecIcon()
    if not C_SpecializationInfo.IsInitialized() then
        return
    end

    local current = C_SpecializationInfo.GetSpecialization(nil, false, 1)
    local icon = current and
                     select(4, C_SpecializationInfo.GetSpecializationInfo(current, false, false, nil, UnitSex('player')))
    if icon then
        self.Content:SetTexture(icon)
    end
end

function TalentButton:OnEnter()
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip_SetTitle(GameTooltip, format('%s / %s', SPECIALIZATION, TALENTS))
    GameTooltip:Show()
end

do
    -- 选中状态读持久化记录（Pick 即落地；面板内选择写入的是同一条记录，两边一致）
    local function GetLastSelectedSavedConfigID()
        local specID = PlayerUtil.GetCurrentSpecID()
        local lastSelectedSavedConfigID = specID and C_ClassTalents.GetLastSelectedSavedConfigID(specID)
        return lastSelectedSavedConfigID
    end

    local function IsLoadoutSelected(configID)
        return GetLastSelectedSavedConfigID() == configID
    end

    -- GearInsight 同款：引擎装载并自动应用；接受后立即落地选中记录，面板下拉会跟着选中
    local function LoadLoadout(configID)
        local talentsFrame = TalentButton:EnsureTalentFrame()
        if not talentsFrame then
            return
        end

        talentsFrame.LoadSystem:SetSelectionID(configID, true)
    end

    local function IsSpecSelected(index)
        return C_SpecializationInfo.GetSpecialization(nil, false, 1) == index
    end

    -- 专精切换需通过等级门槛（提交进行中的锁定由引擎自行拒绝，不再额外判定）
    local function IsSpecEnabled()
        return C_SpecializationInfo.CanPlayerUseTalentSpecUI()
    end

    -- 不能把 C 函数直接当 Menu 回调：SetSpecialization 返回非 nil 的 success，
    -- 会被 Menu 当作 response（非 CloseAll）导致菜单不关闭；包一层返回 nil 即正常关闭
    local function SelectSpec(index)
        C_SpecializationInfo.SetSpecialization(index)
    end

    -- 专精条目在右侧放专精图标
    local function InitSpecMenuButton(button, description)
        local _, _, _, icon = C_SpecializationInfo.GetSpecializationInfo(description:GetData(), false, false, nil,
                                                                         UnitSex('player'))
        if icon then
            local texture = button:AttachTexture()
            texture:SetSize(16, 16)
            texture:SetPoint('RIGHT', button, 'RIGHT', -4, 0)
            texture:SetTexture(icon)
        end
    end

    function TalentButton:BuildMenu(rootDescription)
        -- 天赋方案：只当视图——选中状态读持久化记录（Pick 即落地），切换直调引擎装载（autoApply）
        local specID = PlayerUtil.GetCurrentSpecID()
        if specID then
            rootDescription:CreateTitle(TALENTS)

            local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)
            for _, configID in ipairs(configIDs or {}) do
                local configInfo = C_Traits.GetConfigInfo(configID)
                local name = configInfo and configInfo.name
                if name and name ~= '' then
                    rootDescription:CreateRadio(name, IsLoadoutSelected, LoadLoadout, configID)
                end
            end

            rootDescription:CreateDivider()
        end

        -- 专精
        if C_SpecializationInfo.IsInitialized() then
            rootDescription:CreateTitle(SPECIALIZATION)

            for index = 1, GetNumSpecializations(false, false) do
                local _, name = C_SpecializationInfo.GetSpecializationInfo(index, false, false, nil, UnitSex('player'))
                if name then
                    local desc = rootDescription:CreateRadio(name, IsSpecSelected, SelectSpec, index)
                    desc:AddInitializer(InitSpecMenuButton)
                    desc:SetEnabled(IsSpecEnabled)
                end
            end
        end
    end
end

TalentButton:SetScript('OnShow', TalentButton.OnShow)
TalentButton:SetScript('OnHide', TalentButton.OnHide)
TalentButton:SetScript('OnEvent', TalentButton.OnEvent)
TalentButton:SetScript('OnEnter', TalentButton.OnEnter)
TalentButton:SetScript('OnLeave', GameTooltip_Hide)

--------------------------------------------------------------------
-- 战争模式按钮：剑形图标，亮 = 开，暗 = 关
-- ToggleWarMode 在 12.x 限制为暴雪专用（Only usable by Blizzard），
-- 用安全按钮属性驱动代点天赋界面的战争模式按钮，由暴雪代码块执行切换
--------------------------------------------------------------------
local WarmodeButton = CreateFrame('Button', nil, pane, 'InsecureActionButtonTemplate')
WarmodeButton:SetPoint('BOTTOMLEFT', TalentButton, 'BOTTOMRIGHT', BUTTON_GAP, 0)
WarmodeButton:SetAttribute('type', 'click')
WarmodeButton:SetAttribute('useOnKeyDown', false)
WarmodeButton:SetMotionScriptsWhileDisabled(true)

SetupIconButton(WarmodeButton)

function WarmodeButton:OnShow()
    self:SetupClickbutton()

    self:RegisterUnitEvent('PLAYER_FLAGS_CHANGED', 'player')
    self:RegisterEvent('ZONE_CHANGED')
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA')

    self:Update()
end

function WarmodeButton:OnHide()
    self:UnregisterAllEvents()
end

function WarmodeButton:OnEvent(event)
    if event == 'PLAYER_FLAGS_CHANGED' then
        -- 原按钮隐藏期间收不到该事件，predictedValue 会停留在上次切换的预测上；
        -- 旗帜真正变化时这里代为清除，Get() 随即回落到实时状态，面板亮暗与实际一致
        local nativeButton = PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame and
                                 PlayerSpellsFrame.TalentsFrame.WarmodeButton
        if nativeButton and nativeButton.predictedToggle then
            nativeButton.predictedToggle:Clear()
        end
    end

    self:Update()
end

function WarmodeButton:SetupClickbutton()
    if self:GetAttribute('clickbutton') then
        return
    end

    -- 战斗中不能加载插件、也不能改安全按钮属性；面板未加载时由 PreClick 兜底加载
    if InCombatLockdown() then
        return
    end

    local nativeButton = PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame and
                             PlayerSpellsFrame.TalentsFrame.WarmodeButton
    if nativeButton then
        self:SetAttribute('clickbutton', nativeButton)
    end
end

function WarmodeButton:PreClick()
    if not self:GetAttribute('clickbutton') then
        if InCombatLockdown() then
            return
        end
        C_AddOns.LoadAddOn('Blizzard_PlayerSpells')
        self:SetupClickbutton()
    end
end

ns.addon('Blizzard_PlayerSpells', function()
    -- print('Blizzard_PlayerSpells', debugstack())

    ns.securehook(PlayerSpellsFrame.TalentsFrame.LoadSystem, 'SetSelectionID', function(...)
        print(...)
        print(debugstack())
    end)
end)

function WarmodeButton:OnEnter()
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip_SetTitle(GameTooltip, PVP_LABEL_WAR_MODE)
    if C_PvP.IsWarModeActive() or C_PvP.IsWarModeDesired() then
        GameTooltip_AddInstructionLine(GameTooltip, PVP_WAR_MODE_ENABLED)
    end
    GameTooltip_AddNormalLine(GameTooltip, PVP_WAR_MODE_DESCRIPTION_FORMAT:format(C_PvP.GetWarModeRewardBonus()), true)

    -- 不可切换时的原因提示（同暴雪战争模式按钮）
    local canToggleWarmode = C_PvP.CanToggleWarMode(true)
    local canToggleWarmodeOff = C_PvP.CanToggleWarMode(false)
    if not canToggleWarmode or not canToggleWarmodeOff then
        if not C_PvP.ArePvpTalentsUnlocked() then
            GameTooltip_AddErrorLine(GameTooltip, PVP_TALENT_SLOT_LOCKED:format(C_PvP.GetPvpTalentsUnlockedLevel()),
                                     true)
        else
            local warmodeErrorText

            if not C_PvP.CanToggleWarModeInArea() then
                if C_PvP.IsWarModeDesired() then
                    if not canToggleWarmodeOff and not IsResting() then
                        warmodeErrorText = UnitFactionGroup('player') == PLAYER_FACTION_GROUP[0] and
                                               PVP_WAR_MODE_NOT_NOW_HORDE_RESTAREA or
                                               PVP_WAR_MODE_NOT_NOW_ALLIANCE_RESTAREA
                    end
                else
                    if not canToggleWarmode then
                        warmodeErrorText = UnitFactionGroup('player') == PLAYER_FACTION_GROUP[0] and
                                               PVP_WAR_MODE_NOT_NOW_HORDE or PVP_WAR_MODE_NOT_NOW_ALLIANCE
                    end
                end
            end

            if warmodeErrorText then
                GameTooltip_AddErrorLine(GameTooltip, warmodeErrorText, true)
            elseif UnitAffectingCombat('player') then
                GameTooltip_AddErrorLine(GameTooltip, SPELL_FAILED_AFFECTING_COMBAT, true)
            end
        end
    end

    GameTooltip:Show()
end

function WarmodeButton:Update()
    self.Content:SetAtlas(C_PvP.IsWarModeDesired() and 'pvptalents-warmode-swords' or
                              'pvptalents-warmode-swords-disabled')
    self:SetEnabled(not IsInInstance())

    -- 切换后 tooltip 若仍停留在本按钮上，按新状态重刷（同暴雪战争模式按钮）
    if GameTooltip:GetOwner() == self then
        self:OnEnter()
    end
end

WarmodeButton:SetScript('PreClick', WarmodeButton.PreClick)
WarmodeButton:SetScript('OnShow', WarmodeButton.OnShow)
WarmodeButton:SetScript('OnHide', WarmodeButton.OnHide)
WarmodeButton:SetScript('OnEvent', WarmodeButton.OnEvent)
WarmodeButton:SetScript('OnEnter', WarmodeButton.OnEnter)
WarmodeButton:SetScript('OnLeave', GameTooltip_Hide)
