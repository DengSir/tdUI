-- AtlasLoot.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 6/20/2020, 1:07:36 AM
---@type ns
local ns = select(2, ...)

ns.addon('AtlasLootClassic_Options', function()
    local options = AtlasLoot.Options.config
    ns.RemoveAceConfig(options, 'windows', 'main', 'main', 'bgColor')
    ns.RemoveAceConfig(options, 'windows', 'main', 'main', 'title')
    ns.RemoveAceConfig(options, 'windows', 'main', 'main', 'titleBgColor')
    ns.RemoveAceConfig(options, 'windows', 'main', 'main', 'titleFontColor')
    ns.RemoveAceConfig(options, 'windows', 'main', 'main', 'titleSize')
    ns.RemoveAceConfig(options, 'windows', 'main', 'main', 'font')
    ns.RemoveAceConfig(options, 'windows', 'main', 'content')
    ns.RemoveAceConfig(options, 'windows', 'main', 'contentBottomBar')

    AtlasLoot.Options:NotifyChange()
end)

ns.addon('AtlasLootClassic', function()
    local Window = _G['AtlasLoot_GUI-Frame']
    Window:SetBackdrop(nil)
    Window:SetWidth(Window:GetWidth() - 160)
    Window:SetHeight(Window:GetHeight() - 10)
    Window.CloseButton:Hide()

    local bg = CreateFrame('Frame', nil, Window, 'PortraitFrameTemplate')
    bg:SetAllPoints(true)
    bg:SetFrameLevel(max(Window:GetFrameLevel() - 10, 0))
    -- bg:SetPoint('TOPLEFT')
    -- bg:SetPoint('BOTTOMRIGHT')
    bg.CloseButton:SetScript('OnClick', function()
        HideUIPanel(Window)
    end)
    bg.CloseButton:SetParent(Window)
    SetPortraitToTexture(bg.portrait, [[Interface\EncounterJournal\UI-EJ-PortraitIcon]])

    Window.titleFrame:SetBackdrop(nil)
    Window.titleFrame:ClearAllPoints()
    Window.titleFrame:SetPoint('TOPLEFT', 60, -2)
    Window.titleFrame:SetPoint('TOPRIGHT', -24, -2)
    Window.titleFrame:SetHeight(18)
    Window.titleFrame:SetFont(GameFontHighlightCenter:GetFont())
    Window.titleFrame.SetFont = nop
    Window.titleFrame.text:SetTextColor(1, 1, 1, 1)
    Window.titleFrame.text.SetTextColor = nop

    Window.moduleSelect:SetParPoint('TOPLEFT', Window, 'TOPLEFT', 64, -40)
    Window.moduleSelect:SetWidth(245)
    Window.moduleSelect.frame:SetBackdropBorderColor(0.5, 0.5, 0.5)
    Window.subCatSelect:SetWidth(245)
    Window.subCatSelect.frame:SetBackdropBorderColor(0.5, 0.5, 0.5)

    local function setupInset(frame, left, right, top, bottom)
        local inset = CreateFrame('Frame', nil, Window, 'InsetFrameTemplate')
        inset:SetPoint('TOPLEFT', frame, 'TOPLEFT', left, -top)
        inset:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -right, bottom)
        return inset
    end

    local inset = setupInset(Window.contentFrame, -5, -4, -5, 28)
    setupInset(Window.boss.frame, -2, -2, -2, -2)
    setupInset(Window.extra.frame, -2, -2, -2, -2)
    setupInset(Window.difficulty.frame, -2, -2, -2, -2)

    -- local t = inset:CreateTexture(nil, 'ARTWORK')
    -- t:SetAllPoints(true)
    -- t:SetAtlas('loottab-background')

    Window.contentFrame.itemBG:Hide()
    Window.contentFrame.downBG:Hide()
    Window.contentFrame.downBG:SetPoint('TOPLEFT', Window.contentFrame, 'TOPLEFT', 0, -485)

    Window.boss:SetWidth(170)
    Window.extra:SetWidth(170)
    Window.difficulty:SetWidth(170)

    Window.boss.frame:SetBackdrop(nil)
    Window.extra.frame:SetBackdrop(nil)
    Window.difficulty.frame:SetBackdrop(nil)

    Window:SetAttribute('UIPanelLayout-enabled', true)
    Window:SetAttribute('UIPanelLayout-defined', true)
    Window:SetAttribute('UIPanelLayout-whileDead', true)
    Window:SetAttribute('UIPanelLayout-area', true and 'left')
    Window:SetAttribute('UIPanelLayout-pushable', true and 6)

    ns.override(AtlasLoot.GUI, 'Toggle', function()
        if Window:IsShown() then
            HideUIPanel(Window)
        else
            ShowUIPanel(Window)
        end
    end)
end)
