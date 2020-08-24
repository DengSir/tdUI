-- Bonus.lua
-- @Author : Dencer (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 8/19/2020, 12:22:27 PM
---@type ns
local ns = select(2, ...)

local ITEM_CLASSES = {
    [21330] = 'WARRIOR',
    [21332] = 'WARRIOR',
    [21334] = 'WARLOCK',
    [21336] = 'WARLOCK',
    [21338] = 'WARLOCK',
    [21344] = 'MAGE',
    [21346] = 'MAGE',
    [21348] = 'PRIEST',
    [21350] = 'PRIEST',
    [21352] = 'PRIEST',
    [21354] = 'DRUID',
    [21356] = 'DRUID',
    [19834] = 'ROGUE',
    [21360] = 'ROGUE',
    [21362] = 'ROGUE',
    [21364] = 'ROGUE',
    [21366] = 'HUNTER',
    [21368] = 'HUNTER',
    [19846] = 'MAGE',
    [21372] = 'SHAMAN',
    [21374] = 'SHAMAN',
    [21376] = 'SHAMAN',
    [18713] = 'HUNTER',
    [18715] = 'HUNTER',
    [18465] = 'ROGUE',
    [18467] = 'WARLOCK',
    [18469] = 'PRIEST',
    [18471] = 'SHAMAN',
    [18473] = 'HUNTER',
    [21396] = 'PALADIN',
    [21398] = 'SHAMAN',
    [21400] = 'SHAMAN',
    [21402] = 'HUNTER',
    [21404] = 'ROGUE',
    [21406] = 'ROGUE',
    [21408] = 'DRUID',
    [21410] = 'PRIEST',
    [21412] = 'PRIEST',
    [21414] = 'MAGE',
    [21416] = 'WARLOCK',
    [21418] = 'WARLOCK',
    [20033] = 'WARLOCK',
    [21393] = 'WARRIOR',
    [21373] = 'SHAMAN',
    [19826] = 'PALADIN',
    [19836] = 'ROGUE',
    [18646] = 'PRIEST',
    [21392] = 'WARRIOR',
    [21394] = 'WARRIOR',
    [19824] = 'WARRIOR',
    [19838] = 'DRUID',
    [19825] = 'PALADIN',
    [19828] = 'SHAMAN',
    [19840] = 'DRUID',
    [21329] = 'WARRIOR',
    [21331] = 'WARRIOR',
    [21333] = 'WARRIOR',
    [21335] = 'WARLOCK',
    [21337] = 'WARLOCK',
    [19848] = 'WARLOCK',
    [19843] = 'PRIEST',
    [21343] = 'MAGE',
    [21345] = 'MAGE',
    [21347] = 'MAGE',
    [21349] = 'PRIEST',
    [19827] = 'PALADIN',
    [21353] = 'DRUID',
    [21355] = 'DRUID',
    [19833] = 'HUNTER',
    [19835] = 'ROGUE',
    [21361] = 'ROGUE',
    [19839] = 'DRUID',
    [19841] = 'PRIEST',
    [21367] = 'HUNTER',
    [19845] = 'MAGE',
    [21370] = 'HUNTER',
    [19849] = 'WARLOCK',
    [21375] = 'SHAMAN',
    [21351] = 'PRIEST',
    [21357] = 'DRUID',
    [18714] = 'HUNTER',
    [21389] = 'PALADIN',
    [19832] = 'HUNTER',
    [18466] = 'WARRIOR',
    [18468] = 'MAGE',
    [18470] = 'DRUID',
    [18472] = 'PALADIN',
    [21395] = 'PALADIN',
    [21397] = 'PALADIN',
    [21399] = 'SHAMAN',
    [21401] = 'HUNTER',
    [21403] = 'HUNTER',
    [21405] = 'ROGUE',
    [21407] = 'DRUID',
    [21409] = 'DRUID',
    [21411] = 'PRIEST',
    [21413] = 'MAGE',
    [21415] = 'MAGE',
    [21417] = 'WARLOCK',
    [19830] = 'SHAMAN',
    [21365] = 'HUNTER',
    [21387] = 'PALADIN',
    [21388] = 'PALADIN',
    [21390] = 'PALADIN',
    [21391] = 'PALADIN',
    [20034] = 'MAGE',
    [19822] = 'WARRIOR',
    [19823] = 'WARRIOR',
    [19829] = 'SHAMAN',
    [19831] = 'HUNTER',
    [19842] = 'PRIEST',
    [21359] = 'ROGUE',
}

-- from  https://github.com/Hoizame/AtlasLootClassic/blob/master/AtlasLootClassic/Data/Token.lua
local DATA = {
    -- Dire Maul books
    [18401] = {18348}, -- Foror's Compendium of Dragon Slaying
    [18362] = {18469}, -- Holy Bologna: What the Light Won't Tell You
    [18358] = {18468}, -- The Arcanist's Cookbook
    [18360] = {18467}, -- Harnessing Shadows
    [18356] = {18465}, -- Garona: A Study on Stealth and Treachery
    [18364] = {18470}, -- The Emerald Dream
    [18361] = {18473}, -- The Greatest Race of Hunters
    [18363] = {18471}, -- Frost Shock and You
    [18359] = {18472}, -- The Light and How to Swing It
    [18357] = {18466}, -- Codex of Defense

    [18333] = {18330}, -- Libram of Focus
    [11733] = {11642}, -- Libram of Constitution
    [18334] = {18331}, -- Libram of Protection
    [18332] = {18329}, -- Libram of Rapidity
    [11736] = {11644}, -- Libram of Resilience
    [11732] = {11622}, -- Libram of Rumination
    [11734] = {11643}, -- Libram of Tenacity
    [11737] = {11647, 11648, 11649, 11645, 11646}, -- Libram of Voracity

    --- Darkmoon cards
    -- Portals / Darkmoon Card: Twisting Nether
    [19277] = {19277, 19290}, -- Portals Deck
    [19276] = 19277, -- Ace of Portals
    [19278] = 19277, -- Two of Portals
    [19279] = 19277, -- Three of Portals
    [19280] = 19277, -- Four of Portals
    [19281] = 19277, -- Five of Portals
    [19282] = 19277, -- Six of Portals
    [19283] = 19277, -- Seven of Portals
    [19284] = 19277, -- Eight of Portals

    -- Elementals / Darkmoon Card: Maelstrom
    [19267] = {19267, 19289}, -- Elementals Deck
    [19268] = 19267, -- Ace of Elementals
    [19269] = 19267, -- Two of Elementals
    [19270] = 19267, -- Three of Elementals
    [19271] = 19267, -- Four of Elementals
    [19272] = 19267, -- Five of Elementals
    [19273] = 19267, -- Six of Elementals
    [19274] = 19267, -- Seven of Elementals
    [19275] = 19267, -- Eight of Elementals

    -- Warlords / Darkmoon Card: Heroism
    [19257] = {19257, 19287}, -- Warlords Deck
    [19258] = 19257, -- Ace of Warlords
    [19259] = 19257, -- Two of Warlords
    [19260] = 19257, -- Three of Warlords
    [19261] = 19257, -- Four of Warlords
    [19262] = 19257, -- Five of Warlords
    [19263] = 19257, -- Six of Warlords
    [19264] = 19257, -- Seven of Warlords
    [19265] = 19257, -- Eight of Warlords

    -- Beasts / Darkmoon Card: Blue Dragon
    [19228] = {19228, 19288}, -- Beasts Deck
    [19227] = 19228, -- Ace of Beasts
    [19230] = 19228, -- Two of Beasts
    [19231] = 19228, -- Three of Beasts
    [19232] = 19228, -- Four of Beasts
    [19233] = 19228, -- Five of Beasts
    [19234] = 19228, -- Six of Beasts
    [19235] = 19228, -- Seven of Beasts
    [19236] = 19228, -- Eight of Beasts

    -- Zul'Gurub
    [19724] = {19841, 19834, 19831}, -- Primal Hakkari Aegis
    [19717] = {19830, 19836, 19824}, -- Primal Hakkari Armsplint
    [19716] = {19827, 19846, 19833}, -- Primal Hakkari Bindings
    [19719] = {19829, 19835, 19823}, -- Primal Hakkari Girdle
    [19723] = {20033, 20034, 19822}, -- Primal Hakkari Kossack
    [19720] = {19842, 19849, 19839}, -- Primal Hakkari Sash
    [19721] = {19826, 19845, 19832}, -- Primal Hakkari Shawl
    [19718] = {19843, 19848, 19840}, -- Primal Hakkari Stanchion
    [19722] = {19828, 19825, 19838}, -- Primal Hakkari Tabard

    -- AQ40
    [21237] = {21268, 21273, 21275}, -- Imperial Qiraji Regalia
    [21232] = {21242, 21244, 21272, 21269}, -- Imperial Qiraji Armaments
    [20928] = {21333, 21330, 21359, 21361, 21349, 21350, 21365, 21367}, -- Qiraji Bindings of Command
    [20932] = {21388, 21391, 21338, 21335, 21344, 21345, 21355, 21354, 21373, 21376}, -- Qiraji Bindings of Dominance
    [20930] = {21387, 21360, 21353, 21372, 21366}, -- Vek'lor's Diadem
    [20926] = {21329, 21337, 21347, 21348}, -- Vek'nilash's Circlet
    [20927] = {21332, 21362, 21346, 21352}, -- Ouro's Intact Hide
    [20931] = {21390, 21336, 21356, 21375, 21368}, -- Skin of the Great Sandworm
    [20929] = {21389, 21331, 21364, 21374, 21370}, -- Carapace of the Old God
    [20933] = {21334, 21343, 21357, 21351}, -- Ouro's Intact Hide

    -- AQ20
    [20888] = {21405, 21411, 21417, 21402}, -- Qiraji Ceremonial Ring
    [20884] = {21408, 21414, 21396, 21399, 21393}, -- Qiraji Magisterial Ring
    [20885] = {21406, 21394, 21415, 21412}, -- Qiraji Martial Drape
    [20889] = {21397, 21409, 21400, 21403, 21418}, -- Qiraji Regal Drape
    [20890] = {21413, 21410, 21416, 21407}, -- Qiraji Ornate Hilt
    [20886] = {21395, 21404, 21398, 21401, 21392}, -- Qiraji Spiked Hilt

    -- Tier 3
    [22370] = {22518, 22502, 22510}, -- Desecrated Belt
    [22369] = {22519, 22503, 22511}, -- Desecrated Bindings
    [22365] = {22440, 22492, 22468, 22430}, -- Desecrated Boots
    [22355] = {22483, 22423}, -- Desecrated Bracers
    [22349] = {22476, 22416}, -- Desecrated Breastplate
    [22367] = {22514, 22498, 22506}, -- Desecrated Circlet
    [22357] = {22481, 22421}, -- Desecrated Gauntlets
    [22363] = {22442, 22494, 22470, 22431}, -- Desecrated Girdle
    [22371] = {22501, 22517, 22509}, -- Desecrated Gloves
    [22364] = {22441, 22493, 22469, 22426}, -- Desecrated Handguards
    [22360] = {22438, 22490, 22466, 22428}, -- Desecrated Headpiece
    [22353] = {22478, 22418}, -- Desecrated Helmet
    [22366] = {22497, 22513, 22505}, -- Desecrated Leggings
    [22359] = {22437, 22489, 22465, 22427}, -- Desecrated Legguards
    [22352] = {22477, 22417}, -- Desecrated Legplates
    [22354] = {22479, 22419}, -- Desecrated Pauldrons
    [22351] = {22496, 22504, 22512}, -- Desecrated Robe
    [22358] = {22480, 22420}, -- Desecrated Sabatons
    [22372] = {22500, 22508, 22516}, -- Desecrated Robe
    [22368] = {22499, 22507, 22515}, -- Desecrated Shoulderpads
    [22361] = {22439, 22491, 22467, 22429}, -- Desecrated Spaulders
    [22350] = {22436, 22488, 22464, 22425}, -- Desecrated Tunic
    [22356] = {22482, 22422}, -- Desecrated Waistguard
    [22362] = {22443, 22495, 22471, 22424}, -- Desecrated Wristguards

    -- Misc
    [18784] = {12725, 0, 18783, 18784}, -- Top Half of Advanced Armorsmithing: Volume III
    [18783] = 18784, -- Bottom Half of Advanced Armorsmithing: Volume III
    [18780] = {12727, 0, 18779, 18780}, -- Top Half of Advanced Armorsmithing: Volume I
    [18779] = 18780, -- Bottom Half of Advanced Armorsmithing: Volume I
    [18782] = {12726, 0, 18781, 18782}, -- Top Half of Advanced Armorsmithing: Volume II
    [18781] = {12726, 0, 18781, 18782}, -- Bottom Half of Advanced Armorsmithing: Volume II

    [12731] = {12752, 12757, 12756}, -- Pristine Hide of the Beast

    [18564] = {19019}, -- Bindings of the Windseeker <right>
    [18563] = 18564, -- Bindings of the Windseeker <left>
    [19017] = 18564, -- Essence of the Firelord
    [17204] = {17182}, -- Eye of Sulfuras
    [18703] = {18714, 18713, 18715}, -- Ancient Petrified Leaf

    [18646] = {18665, 18646}, -- The Eye of Divinity
    [18665] = 18646, -- The Eye of Shadow

    [7740] = {7733}, -- Gni'kiv Medallion
    [7741] = 7740, -- The Shaft of Tsol
    [12845] = {17044, 17045}, -- Medallion of Faith

    -- Quests
    [10441] = {10657, 10658}, -- Glowing Shard
    [6283] = {6335, 4534}, -- The Book of Ur
    [16782] = {16886, 16887}, -- Strange Water Globe
    [9326] = {9588}, -- Grime-Encrusted Ring
    [17008] = {17043, 17042, 17039}, -- Small Scroll
    [10454] = {10455}, -- Essence of Eranikus
    [12780] = {13966, 13968, 13965}, -- General Drakkisath's Command
    [7666] = {7673}, -- Shattered Necklace
    [19003] = {19383, 19384, 19366}, -- Head of Nefarian
    [18423] = {18404, 18403, 18406}, -- Head of Onyxia
    [20644] = {20600}, -- Shrouded in Nightmare

    -- Quest objective
    [18705] = {18713}, -- Mature Black Dragon Sinew
    [18704] = {18714}, -- Mature Blue Dragon Sinew
    [12871] = {12895}, -- Chromatic Carapace
    [18706] = {19024}, -- Arena Master

    [22523] = {22689, 22690, 22681, 22680, 22688, 22679, 22667, 22668, 22657, 22659, 22678, 22656}, -- Insignia of the Dawn
    [22524] = 22523, -- Insignia of the Crusade

    -- Naxxramas
    [22520] = {23207, 23206}, -- The Phylactery of Kel'Thuzad

    -- AQ40
    [21221] = {21712, 21710, 21709}, -- Amulet of the Fallen God

    -- AQ20
    [21220] = {21504, 21507, 21505, 21506}, -- Head of Ossirian the Unscarred

    -- ZG
    [19802] = {19950, 19949, 19948}, -- Heart of Hakkar

    -- Atiesh
    [22727] = {22631, 22589, 22630, 22632}, -- Frame of Atiesh
    [22726] = 22727, -- Splinter of Atiesh
    [22734] = 22727, -- Base of Atiesh
    [22733] = 22727, -- Staff Head of Atiesh

    -- UBRS key
    [12219] = {12344}, -- Unadorned Seal of Ascension
    [12336] = 12219, -- Gemstone of Spirestone
    [12335] = 12219, -- Gemstone of Smolderthorn
    [12337] = 12219, -- Gemstone of Bloodaxe
}

do
    local IgnoreClass = UnitFactionGroup('player') == 'Alliance' and 'SHAMAN' or 'PALADIN'

    local function Filter(itemId)
        local class = ITEM_CLASSES[itemId]
        return not class or class ~= IgnoreClass
    end

    for k, v in pairs(DATA) do
        if type(v) == 'table' then
            DATA[k] = tFilter(v, Filter, true)
        end
    end

    for k, v in pairs(DATA) do
        if type(v) == 'number' then
            DATA[k] = assert(DATA[v])
        end
    end
end

local SIZE = 30
local SPACING = 3
local Bonus = tdUIBonusFrame

local function GetTipItemId(tip)
    local name, link = tip:GetItem()
    return link and tonumber(link:match('item:(%d+)'))
end

local function GetTipBonusItems(tip)
    local itemId = GetTipItemId(tip)
    return itemId and DATA[itemId]
end

Bonus.buttons = {}
Bonus.buttons[0] = Bonus.Token
Bonus.Token.index = 0

function Bonus:SetItemRef(itemId)
    ShowUIPanel(ItemRefTooltip)

    if not ItemRefTooltip:IsShown() then
        ItemRefTooltip:SetOwner(UIParent, 'ANCHOR_PRESERVE')
    end

    if itemId ~= GetTipItemId(ItemRefTooltip) then
        ItemRefTooltip:SetItemByID(itemId)
    end
end

function Bonus:GetButton(i)
    if not self.buttons[i] then
        local button = CreateFrame('Button', nil, self, 'tdUIBonusItemTemplate')
        button:SetSize(SIZE, SIZE)
        button:SetPoint('LEFT', self.Token, 'RIGHT', 16 + (i - 1) * (SIZE + SPACING) + 3, 0)
        button.index = i
        self.buttons[i] = button
    end
    return self.buttons[i]
end

function Bonus:RefreshButton(index, itemId)
    return ns.itemready(itemId, self.UpdateButton, self, index, itemId)
end

function Bonus:UpdateButton(index, itemId)
    local button = self:GetButton(index)
    button.itemId = itemId
    button.hasItem = true
    button.Icon:SetTexture(GetItemIcon(itemId))
    button:Show()

    local quality = select(3, GetItemInfo(itemId))
    if quality and quality > LE_ITEM_QUALITY_COMMON then
        local r, g, b = GetItemQualityColor(quality)
        button.Border:SetVertexColor(r, g, b, 0.5)
        button.Border:Show()
    else
        button.Border:Hide()
    end

    local class = ITEM_CLASSES[itemId]
    if not class then
        button.Class:Hide()
        button.ClassBorder:Hide()
    else
        button.Class:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
        button.Class:Show()
        button.ClassBorder:Show()
    end
end

function Bonus:GetItemByIndex(index)
    if not index then
        return
    end
    if index > 0 then
        return self.currentItems[index]
    else
        return self.tokenItemId
    end
end

function Bonus:Update()
    local hasClass = false
    for i = 0, max(#self.currentItems, #self.buttons) do
        local itemId = self:GetItemByIndex(i)
        if itemId then
            self:RefreshButton(i, itemId)

            if ITEM_CLASSES[itemId] then
                hasClass = true
            end

        elseif self.buttons[i] then
            self.buttons[i]:Hide()
        end
    end

    local name, _, quality = GetItemInfo(self.tokenItemId)
    if name then
        local r, g, b = GetItemQualityColor(quality)
        self.Name:SetText(name)
        self.Name:SetTextColor(r, g, b)
        local bg = (self.style or self)
        bg:SetBackdropBorderColor(r, g, b)
    else
        self.Name:SetText('')
    end

    self:SetWidth(40 + (#self.currentItems + 1) * (SIZE + SPACING))
    self:SetHeight(hasClass and 78 or 72)
end

function Bonus:SetItems(itemId, items, force)
    if force or self.tokenItemId ~= itemId or self.currentItems ~= items then
        self.tokenItemId = itemId
        self.currentItems = items
    end
    self:Update()
end

local CLASSES = FillLocalizedClassList {}

function Bonus:SendChat(chatType, target)
    SendChatMessage(select(2, GetItemInfo(self.tokenItemId)) .. ' exchange:', chatType, nil, target)

    local classItems = {}
    for _, itemId in ipairs(self.currentItems) do
        local classFileName = ITEM_CLASSES[itemId] or ''

        classItems[classFileName] = classItems[classFileName] or {}
        tinsert(classItems[classFileName], itemId)
    end

    for classFileName, items in pairs(classItems) do
        local text, classText
        local className = CLASSES[classFileName]
        if className then
            classText = className .. ': '
        else
            classText = ''
        end
        text = classText

        for _, itemId in ipairs(items) do
            local link = select(2, GetItemInfo(itemId))
            if #text + #link > 255 then
                SendChatMessage(text, chatType, nil, target)
                text = classText
            end

            text = text .. link
        end

        if text ~= classText then
            SendChatMessage(text, chatType, nil, target)
        end
    end
end

local channels = { --
    {channel = 'SAY'},
    {channel = 'YELL'},
    {
        channel = 'PARTY',
        visible = function()
            return IsInGroup(1)
        end,
    },
    {
        channel = 'RAID',
        visible = function()
            return IsInRaid(1)
        end,
    },
    {channel = 'GUILD', visible = IsInGuild},
}

local function Initialize()
    for i, v in ipairs(channels) do
        if not v.visible or v.visible() then
            UIDropDownMenu_AddButton {
                text = v.text or _G[v.channel],
                func = function()
                    return Bonus:SendChat(v.channel)
                end,
            }
        end
    end
end

local DropMenu
function Bonus:OpenChatMenu(anchorFrame)
    if not DropMenu then
        DropMenu = CreateFrame('Frame', 'tdUIBonusDropMenu', UIParent, 'UIDropDownMenuTemplate')
        DropMenu.displayMode = 'MENU'
        DropMenu.initialize = Initialize
    end
    ToggleDropDownMenu(1, nil, DropMenu, anchorFrame, 0, 0)
end

ns.hookscript(ItemRefTooltip, 'OnTooltipSetItem', function(self)
    local itemId = GetTipItemId(ItemRefTooltip)
    if itemId then
        local items = DATA[itemId]
        if items then
            Bonus:SetItems(itemId, items, true)
            Bonus:Show()
        end
    else
        Bonus:Hide()
    end
end)

ns.hookscript(GameTooltip, 'OnTooltipSetItem', function(self)
    if GetTipBonusItems(self) then
        if not self:IsOwned(Bonus.Token) then
            self:AddLine('Press CTRL to see bouns')
        end
    end
end)

ns.event('MODIFIER_STATE_CHANGED', function(key, down)
    if (key == 'LCTRL' or key == 'RCTRL') and down == 0 then
        local itemId = GetTipItemId(GameTooltip)
        if not itemId then
            return
        end
        local items = DATA[itemId]
        if items then
            Bonus:SetItems(itemId, items)
            Bonus:Show()
        end
    end
end)
