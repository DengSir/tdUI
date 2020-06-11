local MAJOR = "LibRecipes-1.0"
local MINOR = 11303 -- Should be manually increased
assert(LibStub, MAJOR .. " requires LibStub")

local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end -- No upgrade needed

local type = type
local tonumber = tonumber
local error = error
local select = select
local pairs = pairs

local recipes = lib.recipes or {}
local spells = lib.spells or {}
lib.recipes, lib.spells = recipes, spells

-- ----------------------------------------------------------------------------
-- Internals
-- ----------------------------------------------------------------------------

local function AsNumber(value)
    local valueType = type(value)
    if valueType == "number" then
        return value
    elseif valueType == "string" then
        return tonumber(value)
    end
end

local function Flatten(t, i)
    if t == nil then
        return nil
    elseif i == nil then
        i = 1
        local f = {}
        for k, v in pairs(t) do
            f[i] = k
            f[i+1] = v
            i = i + 2
        end
        return Flatten(f, 1)
    elseif i <= select("#", t) then
        return t[i], t[i+1] or nil, Flatten(t, i+2)
    end
end

-- ----------------------------------------------------------------------------
-- Public API
-- ----------------------------------------------------------------------------

--- Register a recipe
-- @param recipeId Id of the recipe
-- @param spellId Id of the spell learned
-- @param itemId Id of the item created by casting the spell
-- @usage -- item:11813  Formula: Smoking Heart of the Mountain
-- -- spell:15596 Smoking Heart of the Mountain
-- -- item:11811  Smoking Heart of the Mountain (trinket)
-- LibStub("LibRecipes-1.0"):AddRecipe(11813, 15596, 11811)
-- @return nil
function lib:AddRecipe(recipeId, spellId, itemId)
    recipeId = AsNumber(recipeId)
    if recipeId == nil then 
        error("invalid recipe id")
    end
    spellId = AsNumber(spellId)
    if spellId == nil then
        error("invalid spell id")
    end
    -- a craft spell usually creates an item
    itemId = AsNumber(itemId) or false
    
    -- recipe can provide multiple spells (e.g. "Plans: Balanced Trillium Ingot and Its Uses")
    local recipe = recipes[recipeId]
    if recipe == nil then
        recipes[recipeId] = {}
        recipe = recipes[recipeId]
    end
    recipe[spellId] = itemId
    
    -- multiple recipes can provide the same spell (e.g. "Design: Rigid Star of Elune")
    local spell = spells[spellId]
    if spell == nil then
        spells[spellId] = {}
        spell = spells[spellId]
    end
    spell[recipeId] = itemId
end

--- Retrieves the spell and item id related to the specified recipe; repeats in case of multiple spells (spell1, item1, spell2, item2, ...)
-- @param recipeId Id of the recipe
-- @return Id of the spell that is learned 
-- @usage local spellId, itemId = LibStub("LibRecipes-1.0"):GetRecipeInfo(11813) 
-- -- spellId = 15596 
-- -- itemId = 11811 
-- @return Id of the item that is created by the spell or nil if not applicable
function lib:GetRecipeInfo(recipeId)
    recipeId = AsNumber(recipeId)
    if recipeId == nil then 
        error("invalid recipe id")
    end
    return Flatten(recipes[recipeId])
end

--- Retrieves the recipe and item id related to the specified spell; repeats in case of multiple recipes (recipe1, item1, recipe2, item2, ...)
-- @param spellId Id of the spell
-- @usage local recipeId, itemId = LibStub("LibRecipes-1.0"):GetSpellInfo(15596) 
-- -- recipeId = 11813 
-- -- itemId = 11811 
-- @return Id of the recipe that learns the spell
-- @return Id of the item that is created by the spell or nil if not applicable
function lib:GetSpellInfo(spellId)
    spellId = AsNumber(spellId)
    if spellId == nil then
        error("invalid spell id")
    end
    return Flatten(spells[spellId])
end

--- Determines if a spell is taught by a recipe
-- @param spellId Id of the spell
-- @param recipeId Id of the recipe
-- @usage local taughtBy = LibStub("LibRecipes-1.0"):TaughtBy(15596, 11813) 
-- -- taughtBy = true
-- @return true if the recipe teaches the spell; otherwise false
function lib:TaughtBy(spellId, recipeId)
    spellId = AsNumber(spellId)
    if spellId == nil then
        error("invalid spell id")
    end
    recipeId = AsNumber(recipeId)
    if recipeId == nil then 
        error("invalid recipe id")
    end
   return spells[spellId] and spells[spellId][recipeId] ~= nil or false
end

--- Determines if a recipe teaches a spell
-- @param recipeId Id of the recipe
-- @param spellId Id of the spell
-- @usage local teaches = LibStub("LibRecipes-1.0"):Teaches(11813, 15596) 
-- -- teaches = true
-- @return true if the spell is taught by the recipe; otherwise false
function lib:Teaches(recipeId, spellId)
    recipeId = AsNumber(recipeId)
    if recipeId == nil then 
        error("invalid recipe id")
    end
    spellId = AsNumber(spellId)
    if spellId == nil then
        error("invalid spell id")
    end
    return recipes[recipeId] and recipes[recipeId][spellId] ~= nil or false
end

-- ----------------------------------------------------------------------------
-- Data (don't forget to increase MINOR when updated)
-- ----------------------------------------------------------------------------

-- Alchemy
lib:AddRecipe(2553, 3230, 2457) -- Elixir of Minor Agility
lib:AddRecipe(2555, 2335, 2459) -- Swiftness Potion
lib:AddRecipe(2556, 2336, 2460) -- Elixir of Tongues
lib:AddRecipe(3393, 3172, 3384) -- Minor Magic Resistance Potion
lib:AddRecipe(3394, 3174, 3386) -- Elixir of Poison Resistance
lib:AddRecipe(3395, 3175, 3387) -- Limited Invulnerability Potion
lib:AddRecipe(3396, 2333, 3390) -- Elixir of Lesser Agility
lib:AddRecipe(3830, 3450, 3825) -- Elixir of Fortitude
lib:AddRecipe(3831, 3451, 3826) -- Mighty Troll's Blood Potion
lib:AddRecipe(3832, 3453, 3828) -- Elixir of Detect Lesser Invisibility
lib:AddRecipe(4597, 4508, 4596) -- Discolored Healing Potion
lib:AddRecipe(4624, 4942, 4623) -- Lesser Stoneshield Potion
lib:AddRecipe(5640, 6617, 5631) -- Rage Potion
lib:AddRecipe(5641, 6619, 5632) -- Cowardly Flight Potion
lib:AddRecipe(5642, 6624, 5634) -- Free Action Potion
lib:AddRecipe(5643, 6618, 5633) -- Great Rage Potion
lib:AddRecipe(6053, 7255, 6051) -- Holy Protection Potion
lib:AddRecipe(6054, 7256, 6048) -- Shadow Protection Potion
lib:AddRecipe(6055, 7257, 6049) -- Fire Protection Potion
lib:AddRecipe(6056, 7258, 6050) -- Frost Protection Potion
lib:AddRecipe(6057, 7259, 6052) -- Nature Protection Potion
lib:AddRecipe(6068, 3449, 3824) -- Shadow Oil
lib:AddRecipe(6211, 3188, 3391) -- Elixir of Ogre's Strength
lib:AddRecipe(6663, 8240, 6662) -- Elixir of Giant Growth
lib:AddRecipe(9293, 11453, 9036) -- Magic Resistance Potion
lib:AddRecipe(9294, 11458, 9144) -- Wildvine Potion
lib:AddRecipe(9295, 11464, 9172) -- Invisibility Potion
lib:AddRecipe(9296, 11466, 9088) -- Gift of Arthas
lib:AddRecipe(9297, 11468, 9197) -- Elixir of Dream Vision
lib:AddRecipe(9298, 11472, 9206) -- Elixir of Giants
lib:AddRecipe(9300, 11477, 9224) -- Elixir of Demonslaying
lib:AddRecipe(9301, 11476, 9264) -- Elixir of Shadow Power
lib:AddRecipe(9302, 11473, 9210) -- Ghost Dye
lib:AddRecipe(9303, 11459, 9149) -- Philosophers' Stone
lib:AddRecipe(9304, 11479, 3577) -- Transmute: Iron to Gold
lib:AddRecipe(9305, 11480, 6037) -- Transmute: Mithril to Truesilver
lib:AddRecipe(10644, 11456, 9061) -- Goblin Rocket Fuel
lib:AddRecipe(12958, 17187, 12360) -- Transmute: Arcanite
lib:AddRecipe(13476, 17552, 13442) -- Mighty Rage Potion
lib:AddRecipe(13477, 17553, 13443) -- Superior Mana Potion
lib:AddRecipe(13478, 17554, 13445) -- Elixir of Superior Defense
lib:AddRecipe(13479, 17555, 13447) -- Elixir of the Sages
lib:AddRecipe(13480, 17556, 13446) -- Major Healing Potion
lib:AddRecipe(13481, 17557, 13453) -- Elixir of Brute Force
lib:AddRecipe(13482, 17559, 7078) -- Transmute: Air to Fire
lib:AddRecipe(13483, 17560, 7076) -- Transmute: Fire to Earth
lib:AddRecipe(13484, 17561, 7080) -- Transmute: Earth to Water
lib:AddRecipe(13485, 17562, 7082) -- Transmute: Water to Air
lib:AddRecipe(13486, 17563, 7080) -- Transmute: Undeath to Water
lib:AddRecipe(13487, 17564, 12808) -- Transmute: Water to Undeath
lib:AddRecipe(13488, 17565, 7076) -- Transmute: Life to Earth
lib:AddRecipe(13489, 17566, 12803) -- Transmute: Earth to Life
lib:AddRecipe(13490, 17570, 13455) -- Greater Stoneshield Potion
lib:AddRecipe(13491, 17571, 13452) -- Elixir of the Mongoose
lib:AddRecipe(13492, 17572, 13462) -- Purification Potion
lib:AddRecipe(13493, 17573, 13454) -- Greater Arcane Elixir
lib:AddRecipe(13494, 17574, 13457) -- Greater Fire Protection Potion
lib:AddRecipe(13495, 17575, 13456) -- Greater Frost Protection Potion
lib:AddRecipe(13496, 17576, 13458) -- Greater Nature Protection Potion
lib:AddRecipe(13497, 17577, 13461) -- Greater Arcane Protection Potion
lib:AddRecipe(13499, 17578, 13459) -- Greater Shadow Protection Potion
lib:AddRecipe(13500, 17579, 13460) -- Greater Holy Protection Potion
lib:AddRecipe(13501, 17580, 13444) -- Major Mana Potion
lib:AddRecipe(13517, 17632, 13503) -- Alchemist's Stone
lib:AddRecipe(13518, 17634, 13506) -- Flask of Petrification
lib:AddRecipe(13519, 17635, 13510) -- Flask of the Titans
lib:AddRecipe(13520, 17636, 13511) -- Flask of Distilled Wisdom
lib:AddRecipe(13521, 17637, 13512) -- Flask of Supreme Power
lib:AddRecipe(13522, 17638, 13513) -- Flask of Chromatic Resistance
lib:AddRecipe(14634, 3454, 3829) -- Frost Oil
lib:AddRecipe(17709, 21923, 17708) -- Elixir of Frost Power
lib:AddRecipe(18257, 22732, 18253) -- Major Rejuvenation Potion
lib:AddRecipe(20011, 24365, 20007) -- Mageblood Potion
lib:AddRecipe(20012, 24366, 20002) -- Greater Dreamless Sleep Potion
lib:AddRecipe(20013, 24367, 20008) -- Living Action Potion
lib:AddRecipe(20014, 24368, 20004) -- Major Troll's Blood Potion
lib:AddRecipe(20761, 25146, 7068) -- Transmute: Elemental Fire
lib:AddRecipe(21547, 26277, 21546) -- Elixir of Greater Firepower
-- Blacksmithing
lib:AddRecipe(2881, 2667, 2864) -- Runed Copper Breastplate
lib:AddRecipe(2882, 3330, 3481) -- Silvered Bronze Shoulders
lib:AddRecipe(2883, 3295, 3490) -- Deadly Bronze Poniard
lib:AddRecipe(3608, 3297, 3492) -- Mighty Iron Hammer
lib:AddRecipe(3609, 3321, 3471) -- Copper Chain Vest
lib:AddRecipe(3610, 3325, 3474) -- Gemmed Copper Gauntlets
lib:AddRecipe(3611, 3334, 3484) -- Green Iron Boots
lib:AddRecipe(3612, 3336, 3485) -- Green Iron Gauntlets
lib:AddRecipe(3866, 3493, 3850) -- Jade Serpentblade
lib:AddRecipe(3867, 3495, 3852) -- Golden Iron Destroyer
lib:AddRecipe(3868, 3497, 3854) -- Frost Tiger Blade
lib:AddRecipe(3869, 3500, 3856) -- Shadow Crescent Axe
lib:AddRecipe(3870, 3504, 3840) -- Green Iron Shoulders
lib:AddRecipe(3871, 3505, 3841) -- Golden Scale Shoulders
lib:AddRecipe(3872, 3507, 3843) -- Golden Scale Leggings
lib:AddRecipe(3873, 3511, 3845) -- Golden Scale Cuirass
lib:AddRecipe(3874, 3513, 3846) -- Polished Steel Boots
lib:AddRecipe(3875, 3515, 3847) -- Golden Scale Boots
lib:AddRecipe(5543, 6518, 5541) -- Iridescent Hammer
lib:AddRecipe(5577, 2671, 2867) -- Rough Bronze Bracers
lib:AddRecipe(5578, 2673, 2869) -- Silvered Bronze Breastplate
lib:AddRecipe(6044, 7221, 6042) -- Iron Shield Spike
lib:AddRecipe(6045, 7222, 6043) -- Iron Counterweight
lib:AddRecipe(6046, 7224, 6041) -- Steel Weapon Chain
lib:AddRecipe(6047, 3503, 3837) -- Golden Scale Coif
lib:AddRecipe(6734, 8366, 6730) -- Ironforge Chain
lib:AddRecipe(6735, 8367, 6731) -- Ironforge Breastplate
lib:AddRecipe(6736, 8368, 6733) -- Ironforge Gauntlets
lib:AddRecipe(7975, 9933, 7921) -- Heavy Mithril Pants
lib:AddRecipe(7976, 9939, 7967) -- Mithril Shield Spike
lib:AddRecipe(7977, 9942, 7925) -- Mithril Scale Gloves
lib:AddRecipe(7978, 9811, 7913) -- Barbaric Iron Shoulders
lib:AddRecipe(7979, 9813, 7914) -- Barbaric Iron Breastplate
lib:AddRecipe(7980, 9814, 7915) -- Barbaric Iron Helm
lib:AddRecipe(7981, 9818, 7916) -- Barbaric Iron Boots
lib:AddRecipe(7982, 9820, 7917) -- Barbaric Iron Gloves
lib:AddRecipe(7983, 9945, 7926) -- Ornate Mithril Pants
lib:AddRecipe(7984, 9950, 7927) -- Ornate Mithril Gloves
lib:AddRecipe(7985, 9952, 7928) -- Ornate Mithril Shoulders
lib:AddRecipe(7986, 9972, 7935) -- Ornate Mithril Breastplate
lib:AddRecipe(7987, 9980, 7937) -- Ornate Mithril Helm
lib:AddRecipe(7988, 9979, 7936) -- Ornate Mithril Boots
lib:AddRecipe(7989, 9964, 7969) -- Mithril Spurs
lib:AddRecipe(7990, 9970, 7934) -- Heavy Mithril Helm
lib:AddRecipe(7991, 9966, 7932) -- Mithril Scale Shoulders
lib:AddRecipe(7992, 9995, 7942) -- Blue Glittering Axe
lib:AddRecipe(7993, 10005, 7944) -- Dazzling Mithril Rapier
lib:AddRecipe(7994, 9957, 7929) -- Orcish War Leggings
lib:AddRecipe(7995, 9937, 7924) -- Mithril Scale Bracers
lib:AddRecipe(8028, 10009, 7946) -- Runed Mithril Hammer
lib:AddRecipe(8029, 9997, 7943) -- Wicked Mithril Blade
lib:AddRecipe(8030, 10013, 7947) -- Ebon Shiv
lib:AddRecipe(9367, 11643, 9366) -- Golden Scale Gauntlets
lib:AddRecipe(10424, 12259, 10423) -- Silvered Bronze Leggings
lib:AddRecipe(10713, 11454, 9060) -- Inlaid Mithril Cylinder
lib:AddRecipe(10858, 3494, 3851) -- Solid Iron Maul
lib:AddRecipe(11610, 15292, 11608) -- Dark Iron Pulverizer
lib:AddRecipe(11611, 15294, 11607) -- Dark Iron Sunderer
lib:AddRecipe(11612, 15296, 11604) -- Dark Iron Plate
lib:AddRecipe(11614, 15293, 11606) -- Dark Iron Mail
lib:AddRecipe(11615, 15295, 11605) -- Dark Iron Shoulders
lib:AddRecipe(12162, 3492, 3849) -- Hardened Iron Shortsword
lib:AddRecipe(12163, 3496, 3853) -- Moonsteel Broadsword
lib:AddRecipe(12164, 3498, 3855) -- Massive Iron Axe
lib:AddRecipe(12261, 15973, 12260) -- Searing Golden Blade
lib:AddRecipe(12682, 16642, 12405) -- Thorium Armor
lib:AddRecipe(12683, 16643, 12406) -- Thorium Belt
lib:AddRecipe(12684, 16644, 12408) -- Thorium Bracers
lib:AddRecipe(12685, 16645, 12416) -- Radiant Belt
lib:AddRecipe(12687, 16646, 12428) -- Imperial Plate Shoulders
lib:AddRecipe(12688, 16647, 12424) -- Imperial Plate Belt
lib:AddRecipe(12689, 16648, 12415) -- Radiant Breastplate
lib:AddRecipe(12690, 16649, 12425) -- Imperial Plate Bracers
lib:AddRecipe(12691, 16650, 12624) -- Wildthorn Mail
lib:AddRecipe(12692, 16651, 12645) -- Thorium Shield Spike
lib:AddRecipe(12693, 16652, 12409) -- Thorium Boots
lib:AddRecipe(12694, 16653, 12410) -- Thorium Helm
lib:AddRecipe(12695, 16654, 12418) -- Radiant Gloves
lib:AddRecipe(12696, 16667, 12628) -- Demon Forged Breastplate
lib:AddRecipe(12697, 16656, 12419) -- Radiant Boots
lib:AddRecipe(12698, 16660, 12625) -- Dawnbringer Shoulders
lib:AddRecipe(12699, 16655, 12631) -- Fiery Plate Gauntlets
lib:AddRecipe(12700, 16657, 12426) -- Imperial Plate Boots
lib:AddRecipe(12701, 16658, 12427) -- Imperial Plate Helm
lib:AddRecipe(12702, 16659, 12417) -- Radiant Circlet
lib:AddRecipe(12703, 16661, 12632) -- Storm Gauntlets
lib:AddRecipe(12704, 16662, 12414) -- Thorium Leggings
lib:AddRecipe(12705, 16663, 12422) -- Imperial Plate Chest
lib:AddRecipe(12706, 16664, 12610) -- Runic Plate Shoulders
lib:AddRecipe(12707, 16665, 12611) -- Runic Plate Boots
lib:AddRecipe(12711, 16724, 12633) -- Whitesoul Helm
lib:AddRecipe(12713, 16725, 12420) -- Radiant Leggings
lib:AddRecipe(12714, 16726, 12612) -- Runic Plate Helm
lib:AddRecipe(12715, 16730, 12429) -- Imperial Plate Leggings
lib:AddRecipe(12716, 16728, 12636) -- Helm of the Great Chief
lib:AddRecipe(12717, 16729, 12640) -- Lionheart Helm
lib:AddRecipe(12718, 16731, 12613) -- Runic Breastplate
lib:AddRecipe(12719, 16732, 12614) -- Runic Plate Leggings
lib:AddRecipe(12720, 16741, 12639) -- Stronghold Gauntlets
lib:AddRecipe(12725, 16742, 12620) -- Enchanted Thorium Helm
lib:AddRecipe(12726, 16744, 12619) -- Enchanted Thorium Leggings
lib:AddRecipe(12727, 16745, 12618) -- Enchanted Thorium Breastplate
lib:AddRecipe(12728, 16746, 12641) -- Invulnerable Mail
lib:AddRecipe(12816, 16960, 12764) -- Thorium Greatsword
lib:AddRecipe(12817, 16965, 12769) -- Bleakwood Hew
lib:AddRecipe(12818, 16967, 12772) -- Inlaid Thorium Hammer
lib:AddRecipe(12819, 16969, 12773) -- Ornate Thorium Handaxe
lib:AddRecipe(12821, 16970, 12774) -- Dawn's Edge
lib:AddRecipe(12823, 16971, 12775) -- Huge Thorium Battleaxe
lib:AddRecipe(12824, 16973, 12776) -- Enchanted Battlehammer
lib:AddRecipe(12825, 16978, 12777) -- Blazing Rapier
lib:AddRecipe(12826, 16980, 12779) -- Rune Edge
lib:AddRecipe(12827, 16983, 12781) -- Serenity
lib:AddRecipe(12828, 16984, 12792) -- Volcanic Hammer
lib:AddRecipe(12830, 16985, 12782) -- Corruption
lib:AddRecipe(12831, 16986, 12795) -- Blood Talon
lib:AddRecipe(12832, 16987, 12802) -- Darkspear
lib:AddRecipe(12833, 16988, 12796) -- Hammer of the Titans
lib:AddRecipe(12834, 16990, 12790) -- Arcanite Champion
lib:AddRecipe(12835, 16991, 12798) -- Annihilator
lib:AddRecipe(12836, 16992, 12797) -- Frostguard
lib:AddRecipe(12837, 16993, 12794) -- Masterwork Stormhammer
lib:AddRecipe(12838, 16994, 12784) -- Arcanite Reaper
lib:AddRecipe(12839, 16995, 12783) -- Heartseeker
lib:AddRecipe(17049, 20872, 16989) -- Fiery Chain Girdle
lib:AddRecipe(17051, 20874, 17014) -- Dark Iron Bracers
lib:AddRecipe(17052, 20876, 17013) -- Dark Iron Leggings
lib:AddRecipe(17053, 20873, 16988) -- Fiery Chain Shoulders
lib:AddRecipe(17059, 20890, 17015) -- Dark Iron Reaver
lib:AddRecipe(17060, 20897, 17016) -- Dark Iron Destroyer
lib:AddRecipe(17706, 21913, 17704) -- Edge of Winter
lib:AddRecipe(18264, 22757, 18262) -- Elemental Sharpening Stone
lib:AddRecipe(18592, 21161, 17193) -- Sulfuron Hammer
lib:AddRecipe(19202, 23628, 19043) -- Heavy Timbermaw Belt
lib:AddRecipe(19203, 23632, 19051) -- Girdle of the Dawn
lib:AddRecipe(19204, 23629, 19048) -- Heavy Timbermaw Boots
lib:AddRecipe(19205, 23633, 19057) -- Gloves of the Dawn
lib:AddRecipe(19206, 23636, 19148) -- Dark Iron Helm
lib:AddRecipe(19207, 23637, 19164) -- Dark Iron Gauntlets
lib:AddRecipe(19208, 23638, 19166) -- Black Amnesty
lib:AddRecipe(19209, 23639, 19167) -- Blackfury
lib:AddRecipe(19210, 23650, 19170) -- Ebon Hand
lib:AddRecipe(19211, 23652, 19168) -- Blackguard
lib:AddRecipe(19212, 23653, 19169) -- Nightfall
lib:AddRecipe(19776, 24136, 19690) -- Bloodsoul Breastplate
lib:AddRecipe(19777, 24137, 19691) -- Bloodsoul Shoulders
lib:AddRecipe(19778, 24138, 19692) -- Bloodsoul Gauntlets
lib:AddRecipe(19779, 24139, 19693) -- Darksoul Breastplate
lib:AddRecipe(19780, 24140, 19694) -- Darksoul Leggings
lib:AddRecipe(19781, 24141, 19695) -- Darksoul Shoulders
lib:AddRecipe(20040, 24399, 20039) -- Dark Iron Boots
lib:AddRecipe(20553, 24912, 20549) -- Darkrune Gauntlets
lib:AddRecipe(20554, 24914, 20550) -- Darkrune Breastplate
lib:AddRecipe(20555, 24913, 20551) -- Darkrune Helm
lib:AddRecipe(22209, 27585, 22197) -- Heavy Obsidian Belt
lib:AddRecipe(22214, 27588, 22195) -- Light Obsidian Belt
lib:AddRecipe(22219, 27586, 22198) -- Jagged Obsidian Shield
lib:AddRecipe(22220, 27589, 22194) -- Black Grasp of the Destroyer
lib:AddRecipe(22221, 27590, 22191) -- Obsidian Mail Tunic
lib:AddRecipe(22222, 27587, 22196) -- Thick Obsidian Breastplate
lib:AddRecipe(22388, 27829, 22385) -- Titanic Leggings
lib:AddRecipe(22389, 27832, 22383) -- Sageblade
lib:AddRecipe(22390, 27830, 22384) -- Persuader
lib:AddRecipe(22703, 28242, 22669) -- Icebane Breastplate
lib:AddRecipe(22704, 28243, 22670) -- Icebane Gauntlets
lib:AddRecipe(22705, 28244, 22671) -- Icebane Bracers
lib:AddRecipe(22766, 28461, 22762) -- Ironvine Breastplate
lib:AddRecipe(22767, 28462, 22763) -- Ironvine Gloves
lib:AddRecipe(22768, 28463, 22764) -- Ironvine Belt
-- Cooking
lib:AddRecipe(728, 2543, 733) -- Westfall Stew
lib:AddRecipe(2697, 2542, 724) -- Goretusk Liver Pie
lib:AddRecipe(2698, 2545, 2682) -- Cooked Crab Claw
lib:AddRecipe(2699, 2547, 1082) -- Redridge Goulash
lib:AddRecipe(2700, 2548, 2685) -- Succulent Pork Ribs
lib:AddRecipe(2701, 2549, 1017) -- Seasoned Wolf Kabob
lib:AddRecipe(2889, 2795, 2888) -- Beer Basted Boar Ribs
lib:AddRecipe(3678, 3370, 3662) -- Crocolisk Steak
lib:AddRecipe(3679, 3371, 3220) -- Blood Sausage
lib:AddRecipe(3680, 3372, 3663) -- Murloc Fin Soup
lib:AddRecipe(3681, 3373, 3664) -- Crocolisk Gumbo
lib:AddRecipe(3682, 3376, 3665) -- Curiously Tasty Omelet
lib:AddRecipe(3683, 3377, 3666) -- Gooey Spider Cake
lib:AddRecipe(3734, 3397, 3726) -- Big Bear Steak
lib:AddRecipe(3735, 3398, 3727) -- Hot Lion Chops
lib:AddRecipe(3736, 3399, 3728) -- Tasty Lion Steak
lib:AddRecipe(3737, 3400, 3729) -- Soothing Turtle Bisque
lib:AddRecipe(4609, 4094, 4457) -- Barbecued Buzzard Wing
lib:AddRecipe(5482, 6412, 5472) -- Kaldorei Spider Kabob
lib:AddRecipe(5483, 6413, 5473) -- Scorpid Surprise
lib:AddRecipe(5484, 6414, 5474) -- Roasted Kodo Meat
lib:AddRecipe(5485, 6415, 5476) -- Fillet of Frenzy
lib:AddRecipe(5486, 6416, 5477) -- Strider Stew
lib:AddRecipe(5487, 6417, 5478) -- Dig Rat Stew
lib:AddRecipe(5488, 6418, 5479) -- Crispy Lizard Tail
lib:AddRecipe(5489, 6419, 5480) -- Lean Venison
lib:AddRecipe(5528, 6501, 5526) -- Clam Chowder
lib:AddRecipe(6039, 7213, 6038) -- Giant Clam Scorcho
lib:AddRecipe(6325, 7751, 6290) -- Brilliant Smallfish
lib:AddRecipe(6326, 7752, 787) -- Slitherskin Mackerel
lib:AddRecipe(6328, 7753, 4592) -- Longjaw Mud Snapper
lib:AddRecipe(6329, 7754, 6316) -- Loch Frenzy Delight
lib:AddRecipe(6330, 7755, 4593) -- Bristle Whisker Catfish
lib:AddRecipe(6368, 7827, 5095) -- Rainbow Fin Albacore
lib:AddRecipe(6369, 7828, 4594) -- Rockscale Cod
lib:AddRecipe(6661, 8238, 6657) -- Savory Deviate Delight
lib:AddRecipe(6891, 8604, 6888) -- Herb Baked Egg
lib:AddRecipe(6892, 8607, 6890) -- Smoked Bear Meat
lib:AddRecipe(7678, 9513, 7676) -- Thistle Tea
lib:AddRecipe(12226, 15935, 12224) -- Crispy Bat Wing
lib:AddRecipe(12227, 15853, 12209) -- Lean Wolf Steak
lib:AddRecipe(12228, 15855, 12210) -- Roast Raptor
lib:AddRecipe(12229, 15856, 13851) -- Hot Wolf Ribs
lib:AddRecipe(12231, 15861, 12212) -- Jungle Stew
lib:AddRecipe(12232, 15863, 12213) -- Carrion Surprise
lib:AddRecipe(12233, 15865, 12214) -- Mystery Stew
lib:AddRecipe(12239, 15906, 12217) -- Dragonbreath Chili
lib:AddRecipe(12240, 15910, 12215) -- Heavy Kodo Stew
lib:AddRecipe(13939, 18238, 6887) -- Spotted Yellowtail
lib:AddRecipe(13940, 18239, 13927) -- Cooked Glossy Mightfish
lib:AddRecipe(13941, 18241, 13930) -- Filet of Redgill
lib:AddRecipe(13942, 18240, 13928) -- Grilled Squid
lib:AddRecipe(13943, 18242, 13929) -- Hot Smoked Bass
lib:AddRecipe(13945, 18243, 13931) -- Nightfin Soup
lib:AddRecipe(13946, 18244, 13932) -- Poached Sunscale Salmon
lib:AddRecipe(13947, 18245, 13933) -- Lobster Stew
lib:AddRecipe(13948, 18246, 13934) -- Mightfish Steak
lib:AddRecipe(13949, 18247, 13935) -- Baked Salmon
lib:AddRecipe(16110, 15933, 12218) -- Monster Omelet
lib:AddRecipe(16111, 15915, 12216) -- Spiced Chili Crab
lib:AddRecipe(16767, 20626, 16766) -- Undermine Clam Chowder
lib:AddRecipe(17062, 20916, 8364) -- Mithril Headed Trout
lib:AddRecipe(17200, 21143, 17197) -- Gingerbread Cookie
lib:AddRecipe(17201, 21144, 17198) -- Egg Nog
lib:AddRecipe(18046, 22480, 18045) -- Tender Wolf Steak
lib:AddRecipe(18160, 9513, 7676) -- Thistle Tea
lib:AddRecipe(18267, 22761, 18254) -- Runn Tum Tuber Surprise
lib:AddRecipe(20075, 24418, 20074) -- Heavy Crocolisk Stew
lib:AddRecipe(21025, 25659, 21023) -- Dirge's Kickin' Chimaerok Chops
lib:AddRecipe(21099, 25704, 21072) -- Smoked Sagefish
lib:AddRecipe(21219, 25954, 21217) -- Sagefish Delight
lib:AddRecipe(23690, 30047, 23683) -- Crystal Throat Lozenge
-- Enchanting
lib:AddRecipe(6342, 7443, nil) -- Enchant Chest - Minor Mana
lib:AddRecipe(6344, 7766, nil) -- Enchant Bracer - Minor Spirit
lib:AddRecipe(6345, 7771, nil) -- Enchant Cloak - Minor Protection
lib:AddRecipe(6346, 7776, nil) -- Enchant Chest - Lesser Mana
lib:AddRecipe(6347, 7782, nil) -- Enchant Bracer - Minor Strength
lib:AddRecipe(6348, 7786, nil) -- Enchant Weapon - Minor Beastslayer
lib:AddRecipe(6349, 7793, nil) -- Enchant 2H Weapon - Lesser Intellect
lib:AddRecipe(6375, 7859, nil) -- Enchant Bracer - Lesser Spirit
lib:AddRecipe(6376, 7863, nil) -- Enchant Boots - Minor Stamina
lib:AddRecipe(6377, 7867, nil) -- Enchant Boots - Minor Agility
lib:AddRecipe(11038, 13380, nil) -- Enchant 2H Weapon - Lesser Spirit
lib:AddRecipe(11039, 13419, nil) -- Enchant Cloak - Minor Agility
lib:AddRecipe(11081, 13464, nil) -- Enchant Shield - Lesser Protection
lib:AddRecipe(11098, 13522, nil) -- Enchant Cloak - Lesser Shadow Resistance
lib:AddRecipe(11101, 13536, nil) -- Enchant Bracer - Lesser Strength
lib:AddRecipe(11150, 13612, nil) -- Enchant Gloves - Mining
lib:AddRecipe(11151, 13617, nil) -- Enchant Gloves - Herbalism
lib:AddRecipe(11152, 13620, nil) -- Enchant Gloves - Fishing
lib:AddRecipe(11163, 13646, nil) -- Enchant Bracer - Lesser Deflection
lib:AddRecipe(11164, 13653, nil) -- Enchant Weapon - Lesser Beastslayer
lib:AddRecipe(11165, 13655, nil) -- Enchant Weapon - Lesser Elemental Slayer
lib:AddRecipe(11166, 13698, nil) -- Enchant Gloves - Skinning
lib:AddRecipe(11167, 13687, nil) -- Enchant Boots - Lesser Spirit
lib:AddRecipe(11168, 13689, nil) -- Enchant Shield - Lesser Block
lib:AddRecipe(11202, 13817, nil) -- Enchant Shield - Stamina
lib:AddRecipe(11203, 13841, nil) -- Enchant Gloves - Advanced Mining
lib:AddRecipe(11204, 13846, nil) -- Enchant Bracer - Greater Spirit
lib:AddRecipe(11205, 13868, nil) -- Enchant Gloves - Advanced Herbalism
lib:AddRecipe(11206, 13882, nil) -- Enchant Cloak - Lesser Agility
lib:AddRecipe(11207, 13898, nil) -- Enchant Weapon - Fiery Weapon
lib:AddRecipe(11208, 13915, nil) -- Enchant Weapon - Demonslaying
lib:AddRecipe(11223, 13931, nil) -- Enchant Bracer - Deflection
lib:AddRecipe(11224, 13933, nil) -- Enchant Shield - Frost Resistance
lib:AddRecipe(11225, 13945, nil) -- Enchant Bracer - Greater Stamina
lib:AddRecipe(11226, 13947, nil) -- Enchant Gloves - Riding Skill
lib:AddRecipe(11813, 15596, 11811) -- Smoking Heart of the Mountain
lib:AddRecipe(16214, 20008, nil) -- Enchant Bracer - Greater Intellect
lib:AddRecipe(16215, 20020, nil) -- Enchant Boots - Greater Stamina
lib:AddRecipe(16216, 20014, nil) -- Enchant Cloak - Greater Resistance
lib:AddRecipe(16217, 20017, nil) -- Enchant Shield - Greater Stamina
lib:AddRecipe(16218, 20009, nil) -- Enchant Bracer - Superior Spirit
lib:AddRecipe(16219, 20012, nil) -- Enchant Gloves - Greater Agility
lib:AddRecipe(16220, 20024, nil) -- Enchant Boots - Spirit
lib:AddRecipe(16221, 20026, nil) -- Enchant Chest - Major Health
lib:AddRecipe(16222, 20016, nil) -- Enchant Shield - Superior Spirit
lib:AddRecipe(16223, 20029, nil) -- Enchant Weapon - Icy Chill
lib:AddRecipe(16224, 20015, nil) -- Enchant Cloak - Superior Defense
lib:AddRecipe(16242, 20028, nil) -- Enchant Chest - Major Mana
lib:AddRecipe(16243, 20051, 16207) -- Runed Arcanite Rod
lib:AddRecipe(16244, 20013, nil) -- Enchant Gloves - Greater Strength
lib:AddRecipe(16245, 20023, nil) -- Enchant Boots - Greater Agility
lib:AddRecipe(16246, 20010, nil) -- Enchant Bracer - Superior Strength
lib:AddRecipe(16247, 20030, nil) -- Enchant 2H Weapon - Superior Impact
lib:AddRecipe(16248, 20033, nil) -- Enchant Weapon - Unholy Weapon
lib:AddRecipe(16249, 20036, nil) -- Enchant 2H Weapon - Major Intellect
lib:AddRecipe(16250, 20031, nil) -- Enchant Weapon - Superior Striking
lib:AddRecipe(16251, 20011, nil) -- Enchant Bracer - Superior Stamina
lib:AddRecipe(16252, 20034, nil) -- Enchant Weapon - Crusader
lib:AddRecipe(16253, 20025, nil) -- Enchant Chest - Greater Stats
lib:AddRecipe(16254, 20032, nil) -- Enchant Weapon - Lifestealing
lib:AddRecipe(16255, 20035, nil) -- Enchant 2H Weapon - Major Spirit
lib:AddRecipe(17725, 21931, nil) -- Enchant Weapon - Winter's Might
lib:AddRecipe(18259, 22749, nil) -- Enchant Weapon - Spell Power
lib:AddRecipe(18260, 22750, nil) -- Enchant Weapon - Healing Power
lib:AddRecipe(19444, 23799, nil) -- Enchant Weapon - Strength
lib:AddRecipe(19445, 23800, nil) -- Enchant Weapon - Agility
lib:AddRecipe(19446, 23801, nil) -- Enchant Bracer - Mana Regeneration
lib:AddRecipe(19447, 23802, nil) -- Enchant Bracer - Healing Power
lib:AddRecipe(19448, 23803, nil) -- Enchant Weapon - Mighty Spirit
lib:AddRecipe(19449, 23804, nil) -- Enchant Weapon - Mighty Intellect
lib:AddRecipe(20726, 25072, nil) -- Enchant Gloves - Threat
lib:AddRecipe(20727, 25073, nil) -- Enchant Gloves - Shadow Power
lib:AddRecipe(20728, 25074, nil) -- Enchant Gloves - Frost Power
lib:AddRecipe(20729, 25078, nil) -- Enchant Gloves - Fire Power
lib:AddRecipe(20730, 25079, nil) -- Enchant Gloves - Healing Power
lib:AddRecipe(20731, 25080, nil) -- Enchant Gloves - Superior Agility
lib:AddRecipe(20732, 25081, nil) -- Enchant Cloak - Greater Fire Resistance
lib:AddRecipe(20733, 25082, nil) -- Enchant Cloak - Greater Nature Resistance
lib:AddRecipe(20734, 25083, nil) -- Enchant Cloak - Stealth
lib:AddRecipe(20735, 25084, nil) -- Enchant Cloak - Subtlety
lib:AddRecipe(20736, 25086, nil) -- Enchant Cloak - Dodge
lib:AddRecipe(20752, 25125, 20745) -- Minor Mana Oil
lib:AddRecipe(20753, 25126, 20746) -- Lesser Wizard Oil
lib:AddRecipe(20754, 25127, 20747) -- Lesser Mana Oil
lib:AddRecipe(20755, 25128, 20750) -- Wizard Oil
lib:AddRecipe(20756, 25129, 20749) -- Brilliant Wizard Oil
lib:AddRecipe(20757, 25130, 20748) -- Brilliant Mana Oil
lib:AddRecipe(20758, 25124, 20744) -- Minor Wizard Oil
lib:AddRecipe(22392, 27837, nil) -- Enchant 2H Weapon - Agility
-- Engineering
lib:AddRecipe(4408, 3928, 4401) -- Mechanical Squirrel
lib:AddRecipe(4409, 3933, 4367) -- Small Seaforium Charge
lib:AddRecipe(4410, 3940, 4373) -- Shadow Goggles
lib:AddRecipe(4411, 3944, 4376) -- Flame Deflector
lib:AddRecipe(4412, 3954, 4383) -- Moonsight Rifle
lib:AddRecipe(4413, 3959, 4388) -- Discombobulator Ray
lib:AddRecipe(4414, 3960, 4403) -- Portable Bronze Mortar
lib:AddRecipe(4415, 3966, 4393) -- Craftsman's Monocle
lib:AddRecipe(4416, 3968, 4395) -- Goblin Land Mine
lib:AddRecipe(4417, 3972, 4398) -- Large Seaforium Charge
lib:AddRecipe(6672, 8243, 4852) -- Flash Bomb
lib:AddRecipe(6716, 8339, 6714) -- EZ-Thro Dynamite
lib:AddRecipe(7192, 8895, 7189) -- Goblin Rocket Boots
lib:AddRecipe(7560, 9269, 7506) -- Gnomish Universal Remote
lib:AddRecipe(7561, 9273, 7148) -- Goblin Jumper Cables
lib:AddRecipe(7742, 3971, 4397) -- Gnomish Cloaking Device
lib:AddRecipe(10601, 12587, 10499) -- Bright-Eye Goggles
lib:AddRecipe(10602, 12597, 10546) -- Deadly Scope
lib:AddRecipe(10603, 12607, 10501) -- Catseye Ultra Goggles
lib:AddRecipe(10604, 12614, 10510) -- Mithril Heavy-bore Rifle
lib:AddRecipe(10605, 12615, 10502) -- Spellpower Goggles Xtreme
lib:AddRecipe(10606, 12616, 10518) -- Parachute Cloak
lib:AddRecipe(10607, 12617, 10506) -- Deepdive Helmet
lib:AddRecipe(10608, 12620, 10548) -- Sniper Scope
lib:AddRecipe(10609, 12624, 10576) -- Mithril Mechanical Dragonling
lib:AddRecipe(11827, 15633, 11826) -- Lil' Smoky
lib:AddRecipe(11828, 15628, 11825) -- Pet Bombling
lib:AddRecipe(13308, 3957, 4386) -- Ice Deflector
lib:AddRecipe(13309, 3939, 4372) -- Lovingly Crafted Boomstick
lib:AddRecipe(13310, 3979, 4407) -- Accurate Scope
lib:AddRecipe(13311, 3969, 4396) -- Mechanical Dragonling
lib:AddRecipe(14639, 3952, 4381) -- Minor Recombobulator
lib:AddRecipe(16041, 19790, 15993) -- Thorium Grenade
lib:AddRecipe(16042, 19791, 15994) -- Thorium Widget
lib:AddRecipe(16043, 19792, 15995) -- Thorium Rifle
lib:AddRecipe(16044, 19793, 15996) -- Lifelike Mechanical Toad
lib:AddRecipe(16045, 19794, 15999) -- Spellpower Goggles Xtreme Plus
lib:AddRecipe(16046, 19814, 16023) -- Masterwork Target Dummy
lib:AddRecipe(16047, 19795, 16000) -- Thorium Tube
lib:AddRecipe(16048, 19796, 16004) -- Dark Iron Rifle
lib:AddRecipe(16049, 19799, 16005) -- Dark Iron Bomb
lib:AddRecipe(16050, 19815, 16006) -- Delicate Arcanite Converter
lib:AddRecipe(16051, 19800, 15997) -- Thorium Shells
lib:AddRecipe(16052, 19819, 16009) -- Voice Amplification Modulator
lib:AddRecipe(16053, 19825, 16008) -- Master Engineer's Goggles
lib:AddRecipe(16054, 19830, 16022) -- Arcanite Dragonling
lib:AddRecipe(16055, 19831, 16040) -- Arcane Bomb
lib:AddRecipe(16056, 19833, 16007) -- Flawless Arcanite Rifle
lib:AddRecipe(17720, 21940, 17716) -- SnowMaster 9000
lib:AddRecipe(18235, 22704, 18232) -- Field Repair Bot 74A
lib:AddRecipe(18290, 22793, 18283) -- Biznicks 247x128 Accurascope
lib:AddRecipe(18291, 22797, 18168) -- Force Reactive Disk
lib:AddRecipe(18292, 22795, 18282) -- Core Marksman Rifle
lib:AddRecipe(18647, 23066, 9318) -- Red Firework
lib:AddRecipe(18648, 23068, 9313) -- Green Firework
lib:AddRecipe(18649, 23067, 9312) -- Blue Firework
lib:AddRecipe(18650, 23069, 18588) -- EZ-Thro Dynamite II
lib:AddRecipe(18651, 23071, 18631) -- Truesilver Transformer
lib:AddRecipe(18652, 23077, 18634) -- Gyrofreeze Ice Reflector
lib:AddRecipe(18653, 23078, 18587) -- Goblin Jumper Cables XL
lib:AddRecipe(18654, 23096, 18645) -- Alarm-O-Bot
lib:AddRecipe(18655, 23079, 18637) -- Major Recombobulator
lib:AddRecipe(18656, 23080, 18594) -- Powerful Seaforium Charge
lib:AddRecipe(18657, 23081, 18638) -- Hyper-Radiant Flame Reflector
lib:AddRecipe(18658, 23082, 18639) -- Ultra-Flash Shadow Reflector
lib:AddRecipe(18661, 23129, 18660) -- World Enlarger
lib:AddRecipe(19027, 23507, 19026) -- Snake Burst Firework
lib:AddRecipe(20000, 24356, 19999) -- Bloodvine Goggles
lib:AddRecipe(20001, 24357, 19998) -- Bloodvine Lens
lib:AddRecipe(21724, 26416, 21558) -- Small Blue Rocket
lib:AddRecipe(21725, 26417, 21559) -- Small Green Rocket
lib:AddRecipe(21726, 26418, 21557) -- Small Red Rocket
lib:AddRecipe(21727, 26420, 21589) -- Large Blue Rocket
lib:AddRecipe(21728, 26421, 21590) -- Large Green Rocket
lib:AddRecipe(21729, 26422, 21592) -- Large Red Rocket
lib:AddRecipe(21730, 26423, 21571) -- Blue Rocket Cluster
lib:AddRecipe(21731, 26424, 21574) -- Green Rocket Cluster
lib:AddRecipe(21732, 26425, 21576) -- Red Rocket Cluster
lib:AddRecipe(21733, 26426, 21714) -- Large Blue Rocket Cluster
lib:AddRecipe(21734, 26427, 21716) -- Large Green Rocket Cluster
lib:AddRecipe(21735, 26428, 21718) -- Large Red Rocket Cluster
lib:AddRecipe(21737, 26443, 21570) -- Firework Cluster Launcher
lib:AddRecipe(21738, 26442, 21569) -- Firework Launcher
lib:AddRecipe(22729, 28327, 22728) -- Steam Tonk Controller
-- First Aid
lib:AddRecipe(6454, 7935, 6453) -- Strong Anti-Venom
lib:AddRecipe(16112, 7929, 6451) -- Heavy Silk Bandage
lib:AddRecipe(16113, 10840, 8544) -- Mageweave Bandage
lib:AddRecipe(19442, 23787, 19440) -- Powerful Anti-Venom
lib:AddRecipe(23689, 30021, 23684) -- Crystal Infused Bandage
-- Leatherworking
lib:AddRecipe(2406, 2158, 2307) -- Fine Leather Boots
lib:AddRecipe(2407, 2163, 2311) -- White Leather Jerkin
lib:AddRecipe(2408, 2164, 2312) -- Fine Leather Gloves
lib:AddRecipe(2409, 2169, 2317) -- Dark Leather Tunic
lib:AddRecipe(4293, 3762, 4244) -- Hillman's Leather Vest
lib:AddRecipe(4294, 3767, 4250) -- Hillman's Belt
lib:AddRecipe(4295, 7153, 5965) -- Guardian Cloak
lib:AddRecipe(4296, 3769, 4252) -- Dark Leather Shoulders
lib:AddRecipe(4297, 3771, 4254) -- Barbaric Gloves
lib:AddRecipe(4298, 3775, 4258) -- Guardian Belt
lib:AddRecipe(4299, 3773, 4256) -- Guardian Armor
lib:AddRecipe(4300, 3777, 4260) -- Guardian Leather Bracers
lib:AddRecipe(4301, 3779, 4264) -- Barbaric Belt
lib:AddRecipe(5083, 5244, 5081) -- Kodo Hide Bag
lib:AddRecipe(5786, 6702, 5780) -- Murloc Scale Belt
lib:AddRecipe(5787, 6703, 5781) -- Murloc Scale Breastplate
lib:AddRecipe(5788, 6704, 5782) -- Thick Murloc Armor
lib:AddRecipe(5789, 6705, 5783) -- Murloc Scale Bracers
lib:AddRecipe(5972, 7133, 5958) -- Fine Leather Pants
lib:AddRecipe(5973, 7149, 5963) -- Barbaric Leggings
lib:AddRecipe(5974, 7153, 5965) -- Guardian Cloak
lib:AddRecipe(6474, 7953, 6466) -- Deviate Scale Cloak
lib:AddRecipe(6475, 7954, 6467) -- Deviate Scale Gloves
lib:AddRecipe(6476, 7955, 6468) -- Deviate Scale Belt
lib:AddRecipe(6710, 8322, 6709) -- Moonglow Vest
lib:AddRecipe(7288, 9064, 7280) -- Rugged Leather Pants
lib:AddRecipe(7289, 9070, 7283) -- Black Whelp Cloak
lib:AddRecipe(7290, 9072, 7284) -- Red Whelp Gloves
lib:AddRecipe(7360, 3765, 4248) -- Dark Leather Gloves
lib:AddRecipe(7361, 9146, 7349) -- Herbalist's Gloves
lib:AddRecipe(7362, 9147, 7352) -- Earthen Leather Shoulders
lib:AddRecipe(7363, 9148, 7358) -- Pilferer's Gloves
lib:AddRecipe(7364, 9149, 7359) -- Heavy Earthen Gloves
lib:AddRecipe(7449, 9195, 7373) -- Dusky Leather Leggings
lib:AddRecipe(7450, 9197, 7375) -- Green Whelp Armor
lib:AddRecipe(7451, 9202, 7386) -- Green Whelp Bracers
lib:AddRecipe(7452, 9207, 7390) -- Dusky Boots
lib:AddRecipe(7453, 9208, 7391) -- Swift Boots
lib:AddRecipe(7613, 3772, 4255) -- Green Leather Armor
lib:AddRecipe(8384, 10490, 8174) -- Comfortable Leather Hat
lib:AddRecipe(8385, 10509, 8187) -- Turtle Scale Gloves
lib:AddRecipe(8386, 10520, 8200) -- Big Voodoo Robe
lib:AddRecipe(8387, 10531, 8201) -- Big Voodoo Mask
lib:AddRecipe(8388, 10550, 8195) -- Nightscape Cloak
lib:AddRecipe(8389, 10560, 8202) -- Big Voodoo Pants
lib:AddRecipe(8390, 10562, 8216) -- Big Voodoo Cloak
lib:AddRecipe(8395, 10525, 8203) -- Tough Scorpid Breastplate
lib:AddRecipe(8397, 10533, 8205) -- Tough Scorpid Bracers
lib:AddRecipe(8398, 10542, 8204) -- Tough Scorpid Gloves
lib:AddRecipe(8399, 10554, 8209) -- Tough Scorpid Boots
lib:AddRecipe(8400, 10564, 8207) -- Tough Scorpid Shoulders
lib:AddRecipe(8401, 10568, 8206) -- Tough Scorpid Leggings
lib:AddRecipe(8402, 10570, 8208) -- Tough Scorpid Helm
lib:AddRecipe(8403, 10529, 8210) -- Wild Leather Shoulders
lib:AddRecipe(8404, 10544, 8211) -- Wild Leather Vest
lib:AddRecipe(8405, 10546, 8214) -- Wild Leather Helmet
lib:AddRecipe(8406, 10566, 8213) -- Wild Leather Boots
lib:AddRecipe(8407, 10572, 8212) -- Wild Leather Leggings
lib:AddRecipe(8408, 10574, 8215) -- Wild Leather Cloak
lib:AddRecipe(8409, 10516, 8192) -- Nightscape Shoulders
lib:AddRecipe(13287, 4096, 4455) -- Raptor Hide Harness
lib:AddRecipe(13288, 4097, 4456) -- Raptor Hide Belt
lib:AddRecipe(14635, 3778, 4262) -- Gem-studded Leather Belt
lib:AddRecipe(15724, 19048, 15077) -- Heavy Scorpid Bracers
lib:AddRecipe(15725, 19049, 15083) -- Wicked Leather Gauntlets
lib:AddRecipe(15726, 19050, 15045) -- Green Dragonscale Breastplate
lib:AddRecipe(15727, 19051, 15076) -- Heavy Scorpid Vest
lib:AddRecipe(15728, 19052, 15084) -- Wicked Leather Bracers
lib:AddRecipe(15729, 19053, 15074) -- Chimeric Gloves
lib:AddRecipe(15730, 19054, 15047) -- Red Dragonscale Breastplate
lib:AddRecipe(15731, 19055, 15091) -- Runic Leather Gauntlets
lib:AddRecipe(15732, 19059, 15054) -- Volcanic Leggings
lib:AddRecipe(15733, 19060, 15046) -- Green Dragonscale Leggings
lib:AddRecipe(15734, 19061, 15061) -- Living Shoulders
lib:AddRecipe(15735, 19062, 15067) -- Ironfeather Shoulders
lib:AddRecipe(15737, 19063, 15073) -- Chimeric Boots
lib:AddRecipe(15738, 19064, 15078) -- Heavy Scorpid Gauntlets
lib:AddRecipe(15739, 19065, 15092) -- Runic Leather Bracers
lib:AddRecipe(15740, 19066, 15071) -- Frostsaber Boots
lib:AddRecipe(15741, 19067, 15057) -- Stormshroud Pants
lib:AddRecipe(15742, 19068, 15064) -- Warbear Harness
lib:AddRecipe(15743, 19070, 15082) -- Heavy Scorpid Belt
lib:AddRecipe(15744, 19071, 15086) -- Wicked Leather Headband
lib:AddRecipe(15745, 19072, 15093) -- Runic Leather Belt
lib:AddRecipe(15746, 19073, 15072) -- Chimeric Leggings
lib:AddRecipe(15747, 19074, 15069) -- Frostsaber Leggings
lib:AddRecipe(15748, 19075, 15079) -- Heavy Scorpid Leggings
lib:AddRecipe(15749, 19076, 15053) -- Volcanic Breastplate
lib:AddRecipe(15751, 19077, 15048) -- Blue Dragonscale Breastplate
lib:AddRecipe(15752, 19078, 15060) -- Living Leggings
lib:AddRecipe(15753, 19079, 15056) -- Stormshroud Armor
lib:AddRecipe(15754, 19080, 15065) -- Warbear Woolies
lib:AddRecipe(15755, 19081, 15075) -- Chimeric Vest
lib:AddRecipe(15756, 19082, 15094) -- Runic Leather Headband
lib:AddRecipe(15757, 19083, 15087) -- Wicked Leather Pants
lib:AddRecipe(15758, 19084, 15063) -- Devilsaur Gauntlets
lib:AddRecipe(15759, 19085, 15050) -- Black Dragonscale Breastplate
lib:AddRecipe(15760, 19086, 15066) -- Ironfeather Breastplate
lib:AddRecipe(15761, 19087, 15070) -- Frostsaber Gloves
lib:AddRecipe(15762, 19088, 15080) -- Heavy Scorpid Helm
lib:AddRecipe(15763, 19089, 15049) -- Blue Dragonscale Shoulders
lib:AddRecipe(15764, 19090, 15058) -- Stormshroud Shoulders
lib:AddRecipe(15765, 19091, 15095) -- Runic Leather Pants
lib:AddRecipe(15768, 19092, 15088) -- Wicked Leather Belt
lib:AddRecipe(15769, 19093, 15138) -- Onyxia Scale Cloak
lib:AddRecipe(15770, 19094, 15051) -- Black Dragonscale Shoulders
lib:AddRecipe(15771, 19095, 15059) -- Living Breastplate
lib:AddRecipe(15772, 19097, 15062) -- Devilsaur Leggings
lib:AddRecipe(15773, 19098, 15085) -- Wicked Leather Armor
lib:AddRecipe(15774, 19100, 15081) -- Heavy Scorpid Shoulders
lib:AddRecipe(15775, 19101, 15055) -- Volcanic Shoulders
lib:AddRecipe(15776, 19102, 15090) -- Runic Leather Armor
lib:AddRecipe(15777, 19103, 15096) -- Runic Leather Shoulders
lib:AddRecipe(15779, 19104, 15068) -- Frostsaber Tunic
lib:AddRecipe(15781, 19107, 15052) -- Black Dragonscale Leggings
lib:AddRecipe(17022, 20853, 16982) -- Corehound Boots
lib:AddRecipe(17023, 20854, 16983) -- Molten Helm
lib:AddRecipe(17025, 20855, 16984) -- Black Dragonscale Boots
lib:AddRecipe(17722, 21943, 17721) -- Gloves of the Greatfather
lib:AddRecipe(18239, 22711, 18238) -- Shadowskin Gloves
lib:AddRecipe(18252, 22727, 18251) -- Core Armor Kit
lib:AddRecipe(18514, 22921, 18504) -- Girdle of Insight
lib:AddRecipe(18515, 22922, 18506) -- Mongoose Boots
lib:AddRecipe(18516, 22923, 18508) -- Swift Flight Bracers
lib:AddRecipe(18517, 22926, 18509) -- Chromatic Cloak
lib:AddRecipe(18518, 22927, 18510) -- Hide of the Wild
lib:AddRecipe(18519, 22928, 18511) -- Shifting Cloak
lib:AddRecipe(18731, 23190, 18662) -- Heavy Leather Ball
lib:AddRecipe(18949, 23399, 18948) -- Barbaric Bracers
lib:AddRecipe(19326, 23703, 19044) -- Might of the Timbermaw
lib:AddRecipe(19327, 23704, 19049) -- Timbermaw Brawlers
lib:AddRecipe(19328, 23705, 19052) -- Dawn Treaders
lib:AddRecipe(19329, 23706, 19058) -- Golden Mantle of the Dawn
lib:AddRecipe(19330, 23707, 19149) -- Lava Belt
lib:AddRecipe(19331, 23708, 19157) -- Chromatic Gauntlets
lib:AddRecipe(19332, 23709, 19162) -- Corehound Belt
lib:AddRecipe(19333, 23710, 19163) -- Molten Belt
lib:AddRecipe(19769, 24121, 19685) -- Primal Batskin Jerkin
lib:AddRecipe(19770, 24122, 19686) -- Primal Batskin Gloves
lib:AddRecipe(19771, 24123, 19687) -- Primal Batskin Bracers
lib:AddRecipe(19772, 24124, 19688) -- Blood Tiger Breastplate
lib:AddRecipe(19773, 24125, 19689) -- Blood Tiger Shoulders
lib:AddRecipe(20253, 19068, 15064) -- Warbear Harness
lib:AddRecipe(20254, 19080, 15065) -- Warbear Woolies
lib:AddRecipe(20382, 24703, 20380) -- Dreamscale Breastplate
lib:AddRecipe(20506, 24846, 20481) -- Spitfire Bracers
lib:AddRecipe(20507, 24847, 20480) -- Spitfire Gauntlets
lib:AddRecipe(20508, 24848, 20479) -- Spitfire Breastplate
lib:AddRecipe(20509, 24849, 20476) -- Sandstalker Bracers
lib:AddRecipe(20510, 24850, 20477) -- Sandstalker Gauntlets
lib:AddRecipe(20511, 24851, 20478) -- Sandstalker Breastplate
lib:AddRecipe(20576, 24940, 20575) -- Black Whelp Tunic
lib:AddRecipe(21548, 26279, 21278) -- Stormshroud Gloves
lib:AddRecipe(22692, 28219, 22661) -- Polar Tunic
lib:AddRecipe(22694, 28220, 22662) -- Polar Gloves
lib:AddRecipe(22695, 28221, 22663) -- Polar Bracers
lib:AddRecipe(22696, 28222, 22664) -- Icy Scale Breastplate
lib:AddRecipe(22697, 28223, 22666) -- Icy Scale Gauntlets
lib:AddRecipe(22698, 28224, 22665) -- Icy Scale Bracers
lib:AddRecipe(22769, 28474, 22761) -- Bramblewood Belt
lib:AddRecipe(22770, 28473, 22760) -- Bramblewood Boots
lib:AddRecipe(22771, 28472, 22759) -- Bramblewood Helm
-- Mining
-- Tailoring
lib:AddRecipe(2598, 2389, 2572) -- Red Linen Robe
lib:AddRecipe(2601, 2403, 2585) -- Gray Woolen Robe
lib:AddRecipe(4292, 3758, 4241) -- Green Woolen Bag
lib:AddRecipe(4345, 3847, 4313) -- Red Woolen Boots
lib:AddRecipe(4346, 3844, 4311) -- Heavy Woolen Cloak
lib:AddRecipe(4347, 3849, 4315) -- Reinforced Woolen Shoulders
lib:AddRecipe(4348, 3868, 4331) -- Phoenix Gloves
lib:AddRecipe(4349, 3851, 4317) -- Phoenix Pants
lib:AddRecipe(4350, 3856, 4321) -- Spider Silk Slippers
lib:AddRecipe(4351, 3858, 4323) -- Shadow Hood
lib:AddRecipe(4352, 3860, 4325) -- Boots of the Enchanter
lib:AddRecipe(4353, 3863, 4328) -- Spider Belt
lib:AddRecipe(4354, 3872, 4335) -- Rich Purple Silk Shirt
lib:AddRecipe(4355, 3862, 4327) -- Icy Cloak
lib:AddRecipe(4356, 3864, 4329) -- Star Belt
lib:AddRecipe(5771, 6686, 5762) -- Red Linen Bag
lib:AddRecipe(5772, 6688, 5763) -- Red Woolen Bag
lib:AddRecipe(5773, 6692, 5770) -- Robes of Arcana
lib:AddRecipe(5774, 6693, 5764) -- Green Silk Pack
lib:AddRecipe(5775, 6695, 5765) -- Black Silk Pack
lib:AddRecipe(6270, 7630, 6240) -- Blue Linen Vest
lib:AddRecipe(6271, 7629, 6239) -- Red Linen Vest
lib:AddRecipe(6272, 7633, 6242) -- Blue Linen Robe
lib:AddRecipe(6273, 7636, 6243) -- Green Woolen Robe
lib:AddRecipe(6274, 7639, 6263) -- Blue Overalls
lib:AddRecipe(6275, 7643, 6264) -- Greater Adept's Robe
lib:AddRecipe(6390, 7892, 6384) -- Stylish Blue Shirt
lib:AddRecipe(6391, 7893, 6385) -- Stylish Green Shirt
lib:AddRecipe(6401, 3870, 4333) -- Dark Silk Shirt
lib:AddRecipe(7084, 8793, 7059) -- Crimson Silk Shoulders
lib:AddRecipe(7085, 8795, 7060) -- Azure Shoulders
lib:AddRecipe(7086, 8797, 7061) -- Earthen Silk Belt
lib:AddRecipe(7087, 8789, 7056) -- Crimson Silk Cloak
lib:AddRecipe(7088, 8802, 7063) -- Crimson Silk Robe
lib:AddRecipe(7089, 8786, 7053) -- Azure Silk Cloak
lib:AddRecipe(7090, 8784, 7065) -- Green Silk Armor
lib:AddRecipe(7091, 8782, 7049) -- Truefaith Gloves
lib:AddRecipe(7092, 8780, 7047) -- Hands of Darkness
lib:AddRecipe(7093, 8778, 7027) -- Boots of Darkness
lib:AddRecipe(7114, 3854, 4319) -- Azure Silk Gloves
lib:AddRecipe(10300, 12056, 10007) -- Red Mageweave Vest
lib:AddRecipe(10301, 12059, 10008) -- White Bandit Mask
lib:AddRecipe(10302, 12060, 10009) -- Red Mageweave Pants
lib:AddRecipe(10303, 12062, 10010) -- Stormcloth Pants
lib:AddRecipe(10304, 12063, 10011) -- Stormcloth Gloves
lib:AddRecipe(10311, 12064, 10052) -- Orange Martial Shirt
lib:AddRecipe(10312, 12066, 10018) -- Red Mageweave Gloves
lib:AddRecipe(10313, 12068, 10020) -- Stormcloth Vest
lib:AddRecipe(10314, 12075, 10054) -- Lavender Mageweave Shirt
lib:AddRecipe(10315, 12078, 10029) -- Red Mageweave Shoulders
lib:AddRecipe(10316, 12047, 10048) -- Colorful Kilt
lib:AddRecipe(10317, 12080, 10055) -- Pink Mageweave Shirt
lib:AddRecipe(10318, 12081, 10030) -- Admiral's Hat
lib:AddRecipe(10319, 12083, 10032) -- Stormcloth Headband
lib:AddRecipe(10320, 12084, 10033) -- Red Mageweave Headband
lib:AddRecipe(10321, 12085, 10034) -- Tuxedo Shirt
lib:AddRecipe(10322, 12087, 10038) -- Stormcloth Shoulders
lib:AddRecipe(10323, 12089, 10035) -- Tuxedo Pants
lib:AddRecipe(10324, 12090, 10039) -- Stormcloth Boots
lib:AddRecipe(10325, 12091, 10040) -- White Wedding Dress
lib:AddRecipe(10326, 12093, 10036) -- Tuxedo Jacket
lib:AddRecipe(10463, 12086, 10025) -- Shadoweave Mask
lib:AddRecipe(10728, 3873, 4336) -- Black Swashbuckler's Shirt
lib:AddRecipe(14466, 18403, 13869) -- Frostweave Tunic
lib:AddRecipe(14467, 18404, 13868) -- Frostweave Robe
lib:AddRecipe(14468, 18405, 14046) -- Runecloth Bag
lib:AddRecipe(14469, 18406, 13858) -- Runecloth Robe
lib:AddRecipe(14470, 18407, 13857) -- Runecloth Tunic
lib:AddRecipe(14471, 18408, 14042) -- Cindercloth Vest
lib:AddRecipe(14472, 18409, 13860) -- Runecloth Cloak
lib:AddRecipe(14473, 18410, 14143) -- Ghostweave Belt
lib:AddRecipe(14474, 18411, 13870) -- Frostweave Gloves
lib:AddRecipe(14476, 18412, 14043) -- Cindercloth Gloves
lib:AddRecipe(14477, 18413, 14142) -- Ghostweave Gloves
lib:AddRecipe(14478, 18414, 14100) -- Brightcloth Robe
lib:AddRecipe(14479, 18415, 14101) -- Brightcloth Gloves
lib:AddRecipe(14480, 18416, 14141) -- Ghostweave Vest
lib:AddRecipe(14481, 18417, 13863) -- Runecloth Gloves
lib:AddRecipe(14482, 18418, 14044) -- Cindercloth Cloak
lib:AddRecipe(14483, 18419, 14107) -- Felcloth Pants
lib:AddRecipe(14484, 18420, 14103) -- Brightcloth Cloak
lib:AddRecipe(14485, 18421, 14132) -- Wizardweave Leggings
lib:AddRecipe(14486, 18422, 14134) -- Cloak of Fire
lib:AddRecipe(14488, 18423, 13864) -- Runecloth Boots
lib:AddRecipe(14489, 18424, 13871) -- Frostweave Pants
lib:AddRecipe(14490, 18434, 14045) -- Cindercloth Pants
lib:AddRecipe(14491, 18438, 13865) -- Runecloth Pants
lib:AddRecipe(14492, 18437, 14108) -- Felcloth Boots
lib:AddRecipe(14493, 18436, 14136) -- Robe of Winter Night
lib:AddRecipe(14494, 18439, 14104) -- Brightcloth Pants
lib:AddRecipe(14495, 18441, 14144) -- Ghostweave Pants
lib:AddRecipe(14496, 18442, 14111) -- Felcloth Hood
lib:AddRecipe(14497, 18440, 14137) -- Mooncloth Leggings
lib:AddRecipe(14498, 18444, 13866) -- Runecloth Headband
lib:AddRecipe(14499, 18445, 14155) -- Mooncloth Bag
lib:AddRecipe(14500, 18446, 14128) -- Wizardweave Robe
lib:AddRecipe(14501, 18447, 14138) -- Mooncloth Vest
lib:AddRecipe(14504, 18449, 13867) -- Runecloth Shoulders
lib:AddRecipe(14505, 18450, 14130) -- Wizardweave Turban
lib:AddRecipe(14506, 18451, 14106) -- Felcloth Robe
lib:AddRecipe(14507, 18448, 14139) -- Mooncloth Shoulders
lib:AddRecipe(14508, 18453, 14112) -- Felcloth Shoulders
lib:AddRecipe(14509, 18452, 14140) -- Mooncloth Circlet
lib:AddRecipe(14510, 18455, 14156) -- Bottomless Bag
lib:AddRecipe(14511, 18454, 14146) -- Gloves of Spell Mastery
lib:AddRecipe(14512, 18456, 14154) -- Truefaith Vestments
lib:AddRecipe(14513, 18457, 14152) -- Robe of the Archmage
lib:AddRecipe(14514, 18458, 14153) -- Robe of the Void
lib:AddRecipe(14526, 18560, 14342) -- Mooncloth
lib:AddRecipe(14627, 3869, 4332) -- Bright Yellow Shirt
lib:AddRecipe(14630, 3857, 4322) -- Enchanter's Cowl
lib:AddRecipe(17017, 20848, 16980) -- Flarecore Mantle
lib:AddRecipe(17018, 20849, 16979) -- Flarecore Gloves
lib:AddRecipe(17724, 21945, 17723) -- Green Holiday Shirt
lib:AddRecipe(18265, 22759, 18263) -- Flarecore Wraps
lib:AddRecipe(18414, 22866, 18405) -- Belt of the Archmage
lib:AddRecipe(18415, 22867, 18407) -- Felcloth Gloves
lib:AddRecipe(18416, 22868, 18408) -- Inferno Gloves
lib:AddRecipe(18417, 22869, 18409) -- Mooncloth Gloves
lib:AddRecipe(18418, 22870, 18413) -- Cloak of Warding
lib:AddRecipe(18487, 22902, 18486) -- Mooncloth Robe
lib:AddRecipe(19215, 23662, 19047) -- Wisdom of the Timbermaw
lib:AddRecipe(19216, 23664, 19056) -- Argent Boots
lib:AddRecipe(19217, 23665, 19059) -- Argent Shoulders
lib:AddRecipe(19218, 23663, 19050) -- Mantle of the Timbermaw
lib:AddRecipe(19219, 23666, 19156) -- Flarecore Robe
lib:AddRecipe(19220, 23667, 19165) -- Flarecore Leggings
lib:AddRecipe(19764, 24091, 19682) -- Bloodvine Vest
lib:AddRecipe(19765, 24092, 19683) -- Bloodvine Leggings
lib:AddRecipe(19766, 24093, 19684) -- Bloodvine Boots
lib:AddRecipe(20546, 24901, 20538) -- Runed Stygian Leggings
lib:AddRecipe(20547, 24903, 20537) -- Runed Stygian Boots
lib:AddRecipe(20548, 24902, 20539) -- Runed Stygian Belt
lib:AddRecipe(21358, 26085, 21340) -- Soul Pouch
lib:AddRecipe(21369, 26086, 21341) -- Felcloth Bag
lib:AddRecipe(21371, 26087, 21342) -- Core Felcloth Bag
lib:AddRecipe(21722, 26403, 21154) -- Festive Red Dress
lib:AddRecipe(21723, 26407, 21542) -- Festive Red Pant Suit
lib:AddRecipe(22307, 27658, 22246) -- Enchanted Mageweave Pouch
lib:AddRecipe(22308, 27659, 22248) -- Enchanted Runecloth Bag
lib:AddRecipe(22309, 27660, 22249) -- Big Bag of Enchantment
lib:AddRecipe(22310, 27724, 22251) -- Cenarion Herb Bag
lib:AddRecipe(22312, 27725, 22252) -- Satchel of Cenarius
lib:AddRecipe(22683, 28210, 22660) -- Gaea's Embrace
lib:AddRecipe(22684, 28205, 22654) -- Glacial Gloves
lib:AddRecipe(22685, 28208, 22658) -- Glacial Cloak
lib:AddRecipe(22686, 28207, 22652) -- Glacial Vest
lib:AddRecipe(22687, 28209, 22655) -- Glacial Wrists
lib:AddRecipe(22772, 28482, 22758) -- Sylvan Shoulders
lib:AddRecipe(22773, 28481, 22757) -- Sylvan Crown
lib:AddRecipe(22774, 28480, 22756) -- Sylvan Vest
