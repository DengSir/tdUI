-- ChatFrame.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/5/2019, 3:55:56 PM

---@type ns
local ns = select(2, ...)

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

    -- if not self.comparing and IsModifiedClick('COMPAREITEMS') then
    --     GameTooltip_ShowCompareItem(GameTooltip)
    --     self.comparing = true
    -- elseif self.comparing and not IsModifiedClick('COMPAREITEMS') then
    --     for _, frame in pairs(GameTooltip.shoppingTooltips) do
    --         frame:Hide()
    --     end
    --     self.comparing = nil
    -- end
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

local function OnDropDown(dropdown, level)
    if level == 1 then
        local chatFrame = FCF_GetCurrentChatFrame(dropdown)
        ns.InsertDropdownAfter(1, BACKGROUND, CLEAR_ALL, chatFrame.Clear, chatFrame)
    end
end

local function InitChatFrame(self)
    self:SetScript('OnHyperlinkEnter', OnHyperlinkEnter)
    self:SetScript('OnHyperlinkLeave', OnHyperlinkLeave)
    self.UpdateTooltip = UpdateTooltip
    self.editBox:SetAltArrowKeyMode(false)

    ns.securehook(_G[self:GetName() .. 'TabDropDown'], 'initialize', OnDropDown)
end

for _, name in ipairs(CHAT_FRAMES) do
    InitChatFrame(_G[name])
end

ns.securehook('FloatingChatFrame_OnLoad', InitChatFrame)

---- chat tab size
ns.securehook('FCFDock_UpdateTabs', function(dock, force)
    local dynTabSize, hasOverflow = FCFDock_CalculateTabSize(dock, dock.scrollFrame.numDynFrames)
    if not hasOverflow then
        for index, chatFrame in ipairs(dock.DOCKED_CHAT_FRAMES) do
            if not chatFrame.isStaticDocked then
                local chatTab = _G[chatFrame:GetName() .. 'Tab']
                local padding = chatTab.sizePadding or 0
                PanelTemplates_TabResize(chatTab, padding, nil, nil, dynTabSize - 28)
            end
        end
    end
end)

---- fix call in every flash
ns.securehook('FCFDock_OnUpdate', function(dock)
    if not dock.isDirty then
        dock:SetScript('OnUpdate', nil)
    end
end)

local function BiggerChatFrame(frame)
    frame = frame or ChatFrame1
    if frame == ChatFrame1 and not frame:IsUserPlaced() then
        ChatFrame1:SetHeight(207)
    end
end

ns.securehook('RedockChatWindows', BiggerChatFrame)
ns.securehook('FCF_ResetChatWindows', BiggerChatFrame)
ns.securehook('FCF_RestorePositionAndDimensions', BiggerChatFrame)
ns.login(BiggerChatFrame)
ns.login(function()
    TextToSpeechButtonFrame:EnableMouse(false)
end)

ns.after(5, function()
    SetChatColorNameByClass('GUILD_ACHIEVEMENT', true)
    SetChatColorNameByClass('ACHIEVEMENT', true)
end)
