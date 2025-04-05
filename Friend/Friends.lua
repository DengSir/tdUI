-- Guild.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 12/2/2019, 3:23:10 PM
---@type ns
local ns = select(2, ...)

---- Lua
local _G = _G
local min = math.min
local format = string.format
local wipe = table.wipe or wipe
local select = select

---- Wow
local BNGetFriendInfo = BNGetFriendInfo
local BNGetGameAccountInfo = BNGetGameAccountInfo
local GetClassColor = GetClassColor
local GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealmID = GetRealmID
local UnitFactionGroup = UnitFactionGroup

local FriendsFrameTooltip_SetLine = FriendsFrameTooltip_SetLine

---- UI
local FriendsTooltip = FriendsTooltip
local FriendsTooltipGameAccount1Name = FriendsTooltipGameAccount1Name

---- GLOBAL
local FRIENDS_GRAY_COLOR = FRIENDS_GRAY_COLOR
local GREEN_FONT_COLOR = GREEN_FONT_COLOR
local RED_FONT_COLOR = RED_FONT_COLOR

local WOW = FRIENDS_BUTTON_TYPE_WOW
local BNET = FRIENDS_BUTTON_TYPE_BNET
local BNET_CLIENT_WOW = BNET_CLIENT_WOW
local WOW_PROJECT_ID = WOW_PROJECT_ID

local TOOLTIP_MAX_WIDTH = FRIENDS_TOOLTIP_MAX_WIDTH
local TOOLTIP_MARGIN_WIDTH = FRIENDS_TOOLTIP_MARGIN_WIDTH

local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local TOOLTIP_BNET_CHARACTER_TEMPLATE = FRIENDS_TOOLTIP_WOW_TOON_TEMPLATE
local TOOLTIP_WOW_CHARACTER_TEMPLATE = '%s %s %s'

local BNET_NAME_TEMPLATE = FRIENDS_BNET_NAME_COLOR_CODE .. '%s|r (%s, %s)'
local WOW_NAME_TEMPLATE = '%s, %s %s'

local CLASS_FILENAMES = tInvert(FillLocalizedClassList({}))

---@class tdUIFriendInfo: FriendInfo
---@field class string
---@field classFileName string
---@field race string
---@field raceFileName string
---@field accountName string
---@field isSameRealm boolean
---@field isSameFaction boolean

local BNET_FRIEND_INFO = {}

local function ColorStr(text, r, g, b)
    r, g, b = ns.rgb(r, g, b)
    return format('|cff%02x%02x%02x%s|r', r * 255, g * 255, b * 255, text)
end

local function GetFriendInfo(type, index)
    ---@type tdUIFriendInfo
    local info
    if type == WOW then
        info = GetFriendInfoByIndex(index)
        info.isSameFaction = true
        info.isSameRealm = true
        info.isSameProject = true

        if info.connected then
            info.class = info.className
            info.race = select(3, GetPlayerInfoByGUID(info.guid))
            info.classFileName = CLASS_FILENAMES[info.class]
        else
            info.class, info.classFileName, info.race = GetPlayerInfoByGUID(info.guid)
        end
    elseif type == BNET then
        info = wipe(BNET_FRIEND_INFO)

        local _, accountName, _, _, _, bnetIdGameAccount, client, connected = BNGetFriendInfo(index)
        if connected and accountName and client == BNET_CLIENT_WOW then
            local _, name, _, _, realmId, faction, race, class, _, _, level, _, _, _, _, _, _, _, _, _, wowProjectId =
                BNGetGameAccountInfo(bnetIdGameAccount)

            if class then
                info.isBNet = true
                info.connected = connected
                info.name = name
                info.accountName = accountName
                info.class = class
                info.race = race
                info.level = level
                info.classFileName = CLASS_FILENAMES[class]

                info.isSameProject = wowProjectId == WOW_PROJECT_ID
                info.isSameRealm = realmId and realmId == GetRealmID()
                info.isSameFaction = faction == UnitFactionGroup('player')
            end
        end
    end
    return info or {}
end

local function SetCharacterLine(text, ...)
    if select('#', ...) > 0 then
        text = format(text, ...)
    end

    FriendsTooltip.height = FriendsTooltip.height - FriendsTooltipGameAccount1Name:GetHeight()

    return FriendsFrameTooltip_SetLine(FriendsTooltipGameAccount1Name, nil, text)
end

ns.securehook('FriendsFrame_UpdateFriendButton', function(button)
    button.classIcon:Hide()
    button.inviteButton:Hide()

    local info = GetFriendInfo(button.buttonType, button.id)
    if info.connected then
        local r, g, b = GetClassColor(info.classFileName)
        local name = ColorStr(info.name, r, g, b)
        local level = ColorStr(info.level, GetQuestDifficultyColor(info.level))

        if info.isBNet then
            if info.isSameProject then
                button.name:SetFormattedText(BNET_NAME_TEMPLATE, info.accountName, name, level)
                button.name:SetTextColor(FRIENDS_GRAY_COLOR:GetRGB())
            end
        else
            local class = ColorStr(info.class, r, g, b)
            button.name:SetFormattedText(WOW_NAME_TEMPLATE, name, level, class)
            button.name:SetTextColor(FRIENDS_GRAY_COLOR:GetRGB())

            button.classIcon:SetTexCoord(ns.CropClassCoords(info.classFileName))
            button.classIcon:Show()
            -- button.gameIcon:Show()
            button.gameIcon:Hide()

            button.inviteButton.target = info.name
            button.inviteButton:Show()
        end
    else
        if info.class then
            button.info:SetText(info.class)
        end
    end
end)

local function UpdateTooltipSize()
    FriendsTooltip:SetWidth(min(TOOLTIP_MAX_WIDTH, FriendsTooltip.maxWidth + TOOLTIP_MARGIN_WIDTH))
    FriendsTooltip:SetHeight(FriendsTooltip.height + TOOLTIP_MARGIN_WIDTH)
end

local function FriendsFrameTooltip_Show(button)
    local info = GetFriendInfo(button.buttonType, button.id)
    if info.connected then
        local level = ColorStr(info.level, GetQuestDifficultyColor(info.level))
        local class = ColorStr(info.class, GetClassColor(info.classFileName))
        local race = ColorStr(info.race, info.isSameFaction and GREEN_FONT_COLOR or RED_FONT_COLOR)

        if info.isBNet then
            local name = ColorStr(info.name, GetClassColor(info.classFileName))
            SetCharacterLine(TOOLTIP_BNET_CHARACTER_TEMPLATE, name, level, race, class)
        else
            SetCharacterLine(TOOLTIP_WOW_CHARACTER_TEMPLATE, level, race, class)
        end
        UpdateTooltipSize()
    end
end

local function OnEnter(self)
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:SetText(TRAVEL_PASS_INVITE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end

local function OnClick(self)
    InviteToGroup(self.target)
end

local function InitButton(button)
    ---@type Button
    local inviteButton = CreateFrame('Button', nil, button)
    inviteButton:SetSize(24, 32)
    inviteButton:SetPoint('TOPRIGHT', 1, -1)
    inviteButton:SetNormalTexture([[Interface\FriendsFrame\TravelPass-Invite]])
    inviteButton:SetPushedTexture([[Interface\FriendsFrame\TravelPass-Invite]])
    inviteButton:SetDisabledTexture([[Interface\FriendsFrame\TravelPass-Invite]])
    inviteButton:SetHighlightTexture([[Interface\FriendsFrame\TravelPass-Invite]], 'ADD')
    inviteButton:GetNormalTexture():SetTexCoord(0.01562500, 0.39062500, 0.27343750, 0.52343750)
    inviteButton:GetPushedTexture():SetTexCoord(0.42187500, 0.79687500, 0.27343750, 0.52343750)
    inviteButton:GetDisabledTexture():SetTexCoord(0.01562500, 0.39062500, 0.00781250, 0.25781250)
    inviteButton:GetHighlightTexture():SetTexCoord(0.42187500, 0.79687500, 0.00781250, 0.25781250)
    inviteButton:SetScript('OnClick', OnClick)
    inviteButton:SetScript('OnEnter', OnEnter)
    inviteButton:SetScript('OnLeave', GameTooltip_Hide)

    local classIcon = button:CreateTexture(nil, 'ARTWORK', nil, 2)
    classIcon:SetAllPoints(button.gameIcon)
    classIcon:SetTexture([[Interface\WorldStateFrame\ICONS-CLASSES]])

    button.classIcon = classIcon
    button.inviteButton = inviteButton
end

for i, button in ipairs(FriendsFrameFriendsScrollFrame.buttons) do
    InitButton(button)
    button:HookScript('OnEnter', FriendsFrameTooltip_Show)
end

ns.securehook('FriendsFrameTooltip_Show', FriendsFrameTooltip_Show)
ns.hookscript(GuildFrame, 'OnShow', function()
    ButtonFrameTemplate_ShowButtonBar(FriendsFrame)
end)
