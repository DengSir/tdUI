-- ChatFrame.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/5/2019, 3:55:56 PM

local _G = _G
local ipairs, pairs = ipairs, pairs

local GameTooltip = GameTooltip

local IsModifiedClick = IsModifiedClick
local GameTooltip_ShowCompareItem = GameTooltip_ShowCompareItem
local PanelTemplates_TabResize = PanelTemplates_TabResize

local LINKTYPES = {
    item = true,
    enchant = true,
    spell = true,
    quest = true,
    unit = true,
    talent = true,
    achievement = true,
    glyph = true,
    instancelock = true,
    currency = true,
    keystone = true,
}

local function UpdateTooltip(self)
    GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
    GameTooltip:SetHyperlink(self.currentLink)
    GameTooltip:Show()

    if not self.comparing and IsModifiedClick('COMPAREITEMS') then
        GameTooltip_ShowCompareItem(GameTooltip)
        self.comparing = true
    elseif self.comparing and not IsModifiedClick('COMPAREITEMS') then
        for _, frame in pairs(GameTooltip.shoppingTooltips) do
            frame:Hide()
        end
        self.comparing = nil
    end
end

local function OnHyperlinkEnter(self, link)
    local linktype = link:match('^([^:]+)')
    if linktype and LINKTYPES[linktype] then
        self.currentLink = link
        UpdateTooltip(self)
    end
end

local function OnHyperlinkLeave(self)
    self.currentLink = nil
    GameTooltip:Hide()
end

local function InitChatFrame(self)
    print(self)
    self:SetScript('OnHyperlinkEnter', OnHyperlinkEnter)
    self:SetScript('OnHyperlinkLeave', OnHyperlinkLeave)
    self.UpdateTooltip = UpdateTooltip
    self.editBox:SetAltArrowKeyMode(false)
end

for _, name in ipairs(CHAT_FRAMES) do
    InitChatFrame(_G[name])
end

hooksecurefunc('FloatingChatFrame_OnLoad', InitChatFrame)

---- tabs size
hooksecurefunc('FCFDock_UpdateTabs', function(dock)
    for index, chatFrame in ipairs(dock.DOCKED_CHAT_FRAMES) do
        if not chatFrame.isStaticDocked then
            local chatTab = _G[chatFrame:GetName() .. 'Tab']
            PanelTemplates_TabResize(chatTab, chatTab.sizePadding or 0)
        end
    end
end)

local function BiggerChatFrame(frame)
    frame = frame or ChatFrame1
    if frame == ChatFrame1 and not frame:IsUserPlaced() then
        ChatFrame1:SetHeight(200)
    end
end

hooksecurefunc('RedockChatWindows', BiggerChatFrame)
hooksecurefunc('FCF_ResetChatWindows', BiggerChatFrame)
hooksecurefunc('FCF_RestorePositionAndDimensions', BiggerChatFrame)
C_Timer.After(0, BiggerChatFrame)
