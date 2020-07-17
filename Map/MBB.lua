-- MBB.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 5/15/2020, 3:56:36 PM
---@type ns
local ns = select(2, ...)

local BLACK_LIST = { --
    ['TimeManagerClockButton'] = true,
    ['BattlefieldMinimap'] = true,
    ['MiniMapBattlefieldFrame'] = true,
}

local buttons = {}

local ToggleButton = CreateFrame('Button', nil, UIParent)
local MinimapBagFrame = CreateFrame('Frame', nil, UIParent)

local HookEnter
do
    local function SetOwner(orig, tip, owner)
        return orig(tip, owner, 'ANCHOR_LEFT')
    end

    local function HookOwner(tip)
        if tip then
            ns.hook(tip, 'SetOwner', SetOwner)
        end
    end

    local function UnhookOwner(tip)
        if tip then
            tip.SetOwner = nil
        end
    end

    local function OnEnter(button)
        HookOwner(GameTooltip)
        HookOwner(LibDBIconTooltip)
        button:origOnEnter()
        UnhookOwner(GameTooltip)
        UnhookOwner(LibDBIconTooltip)
    end

    function HookEnter(button)
        button.origOnEnter = button:GetScript('OnEnter')
        if button.origOnEnter then
            button:SetScript('OnEnter', OnEnter)
        end
    end
end

local function HookPoints(button)
    button.origClearAllPoints = button.ClearAllPoints
    button.origSetPoint = button.SetPoint
    button.ClearAllPoints = nop
    button.SetPoint = nop
end

local function HookButton(button)
    button:SetParent(MinimapBagFrame)

    HookPoints(button)
    HookEnter(button)

    tinsert(buttons, button)
end

local function Layout()
    local width = 0
    local height = 20
    local prev
    for i, button in ipairs(buttons) do
        if button:IsVisible() then
            button:origClearAllPoints()
            if not prev then
                button:origSetPoint('TOPLEFT', MinimapBagFrame, 'TOPLEFT', 0, -20)
            else
                button:origSetPoint('TOP', prev, 'BOTTOM')
            end
            width = max(width, button:GetWidth())
            height = height + button:GetHeight()

            prev = button
        end
    end
    MinimapBagFrame:SetSize(width, height)
end

local function IsCollectable(button)
    return button:GetObjectType() == 'Button' and button:GetNumRegions() >= 3 and button:IsShown()
end

local function IsIgnored(name)
    return BLACK_LIST[name] or ns.profile.minimap.bag.ignores[name]
end

local function comp(a, b)
    return a:GetName() < b:GetName()
end

local function Collect()
    local found = false
    for _, child in ipairs({Minimap:GetChildren()}) do
        local name = child:GetName()
        if name and not IsIgnored(name) and IsCollectable(child) then
            HookButton(child)
            found = true
        end
    end

    if found then
        sort(buttons, comp)
        Layout()
    end
end

ToggleButton:SetFrameStrata('HIGH')
ToggleButton:SetToplevel(true)
ToggleButton:SetSize(16, 16)
ToggleButton:SetPoint('TOPRIGHT', Minimap, 'BOTTOMRIGHT', -5, 30)

do
    local icon = ToggleButton:CreateTexture(nil, 'ARTWORK')
    icon:SetTexture([[Interface\scenarios\scenarioicon-interact]])
    icon:SetSize(16, 16)
    icon:SetPoint('CENTER')

    local ht = ToggleButton:CreateTexture(nil, 'HIGHLIGHT')
    ht:SetTexture([[Interface\scenarios\scenarioicon-interact]])
    ht:SetBlendMode('ADD')
    ht:SetSize(16, 16)
    ht:SetPoint('CENTER')
end

ToggleButton:SetScript('OnClick', function()
    MinimapBagFrame:SetShown(not MinimapBagFrame:IsShown())
end)
ToggleButton:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
    GameTooltip:SetText('Minimap Buttons')
    GameTooltip:Show()
end)
ToggleButton:SetScript('OnLeave', GameTooltip_Hide)

MinimapBagFrame:Hide()
MinimapBagFrame:SetFrameStrata('HIGH')
MinimapBagFrame:SetPoint('TOP', ToggleButton, 'TOP', 0, 0)
MinimapBagFrame:SetSize(1, 1)
MinimapBagFrame:SetScript('OnShow', Layout)
MinimapBagFrame:SetScript('OnUpdate', function(self, elasped)
    self.timer = (self.timer or 0.5) - elasped
    if self.timer > 0 then
        return
    end

    if self:IsMouseOver() then
        self.timer = 0.5
    else
        self:Hide()
    end
end)

ns.load(function()
    ns.timer(3, Collect)
end)
