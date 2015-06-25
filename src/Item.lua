local SWS_ADDON_NAME, StatWeightScore = ...;
local ItemModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Item");

local B = LibStub("LibBabble-Inventory-3.0");
local BL = B:GetLookupTable();

local Utils;

local Armor = BL["Armor"];
local Weapon = BL["Weapon"];

local Miscellaneous = BL["Miscellaneous"];
local Cloth = BL["Cloth"];
local Leather = BL["Leather"];
local Mail = BL["Mail"];
local Plate = BL["Plate"];
local Shields = BL["Shields"];

local OneHandedAxes = BL["One-Handed Axes"];
local OneHandedMaces = BL["One-Handed Maces"];
local OneHandedSwords = BL["One-Handed Swords"];
local TwoHandedAxes = BL["Two-Handed Axes"];
local TwoHandedMaces = BL["Two-Handed Maces"];
local TwoHandedSwords = BL["Two-Handed Swords"];
local Bows = BL["Bows"];
local Guns = BL["Guns"];
local Crossbows = BL["Crossbows"];
local Polearms = BL["Polearms"];
local FistWeapons = BL["Fist Weapons"];
local Staves = BL["Staves"];
local Daggers = BL["Daggers"];
local Wands = BL["Wands"];

local function AddMapping(map, key, ...)
    map[key] = {};

    local items = Utils.Pack(...);

    for i = 1, items.n do
        map[key][items[i]] = true;
    end
end

local function AddSimpleMapping(map, key)
    map[key] = true;
end

local function AddValueMapping(map, key, value)
    map[key] = value;
end

function ItemModule:CreateMaps()
    self.ClassArmorMap = {};
    self.ClassWeaponMap = {};
    self.HeldInOffhandMap = {};

    AddMapping(self.ClassArmorMap, "WARLOCK", Cloth);
    AddMapping(self.ClassArmorMap, "MAGE", Cloth);
    AddMapping(self.ClassArmorMap, "PRIEST", Cloth);
    AddMapping(self.ClassArmorMap, "DRUID", Leather);
    AddMapping(self.ClassArmorMap, "ROGUE", Leather);
    AddMapping(self.ClassArmorMap, "MONK", Leather);
    AddMapping(self.ClassArmorMap, "SHAMAN", Mail, Shields);
    AddMapping(self.ClassArmorMap, "HUNTER", Mail);
    AddMapping(self.ClassArmorMap, "WARRIOR", Plate, Shields);
    AddMapping(self.ClassArmorMap, "PALADIN", Plate, Shields);
    AddMapping(self.ClassArmorMap, "DEATHKNIGHT", Plate);

    AddMapping(self.ClassWeaponMap, "WARLOCK", OneHandedSwords, Daggers, Staves, Wands);
    AddMapping(self.ClassWeaponMap, "MAGE", OneHandedSwords, Daggers, Staves, Wands);
    AddMapping(self.ClassWeaponMap, "PRIEST", OneHandedMaces, Daggers, Staves, Wands);
    AddMapping(self.ClassWeaponMap, "DRUID", OneHandedMaces, TwoHandedMaces, Daggers, FistWeapons, Polearms, Staves);
    AddMapping(self.ClassWeaponMap, "ROGUE", OneHandedMaces, OneHandedSwords, OneHandedAxes, FistWeapons, Daggers);
    AddMapping(self.ClassWeaponMap, "MONK", OneHandedMaces, OneHandedSwords, OneHandedAxes, FistWeapons, Polearms, Staves);
    AddMapping(self.ClassWeaponMap, "SHAMAN", OneHandedMaces, TwoHandedMaces, OneHandedAxes, TwoHandedAxes, FistWeapons, Daggers, Staves);
    AddMapping(self.ClassWeaponMap, "HUNTER", Bows, Guns, Crossbows);
    AddMapping(self.ClassWeaponMap, "WARRIOR", OneHandedMaces, TwoHandedMaces, OneHandedAxes, TwoHandedAxes, OneHandedSwords, TwoHandedSwords, FistWeapons, Daggers, Polearms);
    AddMapping(self.ClassWeaponMap, "PALADIN", OneHandedMaces, TwoHandedMaces, OneHandedAxes, TwoHandedAxes, OneHandedSwords, TwoHandedSwords, Polearms);
    AddMapping(self.ClassWeaponMap, "DEATHKNIGHT", OneHandedMaces, TwoHandedMaces, OneHandedAxes, TwoHandedAxes, OneHandedSwords, TwoHandedSwords, Polearms);

    AddSimpleMapping(self.HeldInOffhandMap, "WARLOCK");
    AddSimpleMapping(self.HeldInOffhandMap, "MAGE");
    AddSimpleMapping(self.HeldInOffhandMap, "PRIEST");
    AddSimpleMapping(self.HeldInOffhandMap, "DRUID");
    AddSimpleMapping(self.HeldInOffhandMap, "MONK");
    AddSimpleMapping(self.HeldInOffhandMap, "SHAMAN");
    AddSimpleMapping(self.HeldInOffhandMap, "PALADIN");

    self.UniqueGroups = {
        ["Solium Band of Endurance"] = 1,
        ["Solium Band of Wisdom"] = 1,
        ["Solium Band of Dexterity"] = 1,
        ["Solium Band of Mending"] = 1,
        ["Solium Band of Might"] = 1,
        ["Timeless Solium Band of the Archmage"] = 1,
        ["Timeless Solium Band of the Bulwark"] = 1,
        ["Timeless Solium Band of Brutality"] = 1,
        ["Timeless Solium Band of Lifegiving"] = 1,
        ["Timeless Solium Band of the Assassin"] = 1,
        ["Spellbound Solium Band of Fatal Strikes"] = 1,
        ["Spellbound Solium Band of the Kirin-Tor"] = 1,
        ["Spellbound Solium Band of Sorcerous Strength"] = 1,
        ["Spellbound Solium Band of the Immortal Spirit"] = 1,
        ["Spellbound Solium Band of Sorcerous Invincibility"] = 1,
        ["Spellbound Runic Band of the All-Seeing Eye"] = 1,
        ["Spellbound Runic Band of Unrelenting Slaughter"] = 1,
        ["Spellbound Runic Band of Infinite Preservation"] = 1,
        ["Spellbound Runic Band of Elemental Power"] = 1,
        ["Spellbound Runic Band of Elemental Invincibility"] = 1
    };

    self.SlotMap = {
        INVTYPE_AMMO = {0},
        INVTYPE_HEAD = {1},
        INVTYPE_NECK = {2},
        INVTYPE_SHOULDER = {3},
        INVTYPE_BODY = {4},
        INVTYPE_CHEST = {5},
        INVTYPE_ROBE = {5},
        INVTYPE_WAIST = {6},
        INVTYPE_LEGS = {7},
        INVTYPE_FEET = {8},
        INVTYPE_WRIST = {9},
        INVTYPE_HAND = {10},
        INVTYPE_FINGER = {11,12},
        INVTYPE_TRINKET = {13,14},
        INVTYPE_CLOAK = {15},
        INVTYPE_WEAPON = {16,17},
        INVTYPE_SHIELD = {16,17},
        INVTYPE_2HWEAPON = {16,17},
        INVTYPE_WEAPONMAINHAND = {16},
        INVTYPE_WEAPONOFFHAND = {17},
        INVTYPE_HOLDABLE = {16,17},
        INVTYPE_RANGED = {16},
        INVTYPE_THROWN = {18},
        INVTYPE_RANGEDRIGHT = {16},
        INVTYPE_RELIC = {18},
        INVTYPE_TABARD = {19},
    };

    self.Tier17Map = {
        ["119322"] = { -- Shoulders of Iron Protector
            ["HUNTER"] = "115547",
            ["WARRIOR"] = "115581",
            ["SHAMAN"] = "115576",
            ["MONK"] = "115559"
        },
        ["119318"] = { -- Chest of Iron Protector
            ["HUNTER"] = "115548",
            ["WARRIOR"] = "115582",
            ["SHAMAN"] = "115577",
            ["MONK"] = "115558"
        },
        ["119321"] = { -- Helm of Iron Protector
            ["HUNTER"] = "115545",
            ["WARRIOR"] = "115584",
            ["SHAMAN"] = "115579",
            ["MONK"] = "115556"
        },
        ["119319"] = { -- Gauntlets of Iron Protector
            ["HUNTER"] = "115549",
            ["WARRIOR"] = "115583",
            ["SHAMAN"] = "115578",
            ["MONK"] = "115555"
        },
        ["119320"] = { -- Leggins of Iron Protector
            ["HUNTER"] = "115546",
            ["WARRIOR"] = "115580",
            ["SHAMAN"] = "115575",
            ["MONK"] = "115557"
        },
        ["119314"] = { -- Shoulders of Iron Vanquisher
            ["ROGUE"] = "115574",
            ["DEATHKNIGHT"] = "115536",
            ["MAGE"] = "115551",
            ["DRUID"] = "115544"
        },
        ["119315"] = { -- Chest of Iron Vanquisher
            ["ROGUE"] = "115570",
            ["DEATHKNIGHT"] = "115537",
            ["MAGE"] = "115550",
            ["DRUID"] = "115540"
        },
        ["119312"] = { -- Helm of Iron Vanquisher
            ["ROGUE"] = "115572",
            ["DEATHKNIGHT"] = "115539",
            ["MAGE"] = "115553",
            ["DRUID"] = "115542"
        },
        ["119311"] = { -- Gauntlets of Iron Vanquisher
            ["ROGUE"] = "115571",
            ["DEATHKNIGHT"] = "115538",
            ["MAGE"] = "115552",
            ["DRUID"] = "115541"
        },
        ["119313"] = { -- Leggins of Iron Vanquisher
            ["ROGUE"] = "115573",
            ["DEATHKNIGHT"] = "115535",
            ["MAGE"] = "115554",
            ["DRUID"] = "115543"
        },
        ["119309"] = { -- Shoulders of Iron Conqueror
            ["PALADIN"] = "115566",
            ["PRIEST"] = "115561",
            ["WARLOCK"] = "115588"
        },
        ["119305"] = { -- Chest of Iron Conqueror
            ["PALADIN"] = "115565",
            ["PRIEST"] = "115560",
            ["WARLOCK"] = "115589"
        },
        ["119308"] = { -- Helm of Iron Conqueror
            ["PALADIN"] = "115568",
            ["PRIEST"] = "115563",
            ["WARLOCK"] = "115586"
        },
        ["119306"] = { -- Gauntlets of Iron Conqueror
            ["PALADIN"] = "115567",
            ["PRIEST"] = "115562",
            ["WARLOCK"] = "115585"
        },
        ["119307"] = { -- Leggins of Iron Conqueror
            ["PALADIN"] = "115569",
            ["PRIEST"] = "115564",
            ["WARLOCK"] = "115587"
        }
    };

    self.Tier17BonusMap = {
        ["570"] = "566", -- heroic
        ["569"] = "567" -- mythic
    };
end

function ItemModule:OnInitialize()
    Utils = StatWeightScore.Utils;

    self:CreateMaps();
end

function ItemModule:IsItemForClass(itemType, itemSubType, locStr, class)
    if(itemType == Armor) then
        if(locStr == INVTYPE_CLOAK) then
            return true;
        end

        if(itemSubType == Miscellaneous) then
            if(locStr == INVTYPE_HOLDABLE) then
                return self.HeldInOffhandMap[class] == true;
            end

            return true;
        end

        return self.ClassArmorMap[class][itemSubType] == true;
    end

    if(itemType == Weapon) then
        return self.ClassWeaponMap[class][itemSubType] == true;
    end

    return true;
end


function ItemModule:AreUniquelyExclusive(item1, item2)
    if(item1 == item2) then
        return true;
    end

    local item1Group = self.UniqueGroups[item1];
    local item2Group = self.UniqueGroups[item2];

    if(item1Group and item2Group and item1Group == item2Group) then
        return true;
    end

    return false;
end

function ItemModule:GetItemLinkInfo(itemLink)
    if(not itemLink) then
        return nil;
    end

    local itemString = string.match(itemLink, "item[%-?%d:]+");
    local _, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, linkLevel, upgradeId, _, instanceDifficulty, numBonus, bonus1 = strsplit(":", itemString)

    return itemId, bonus1;
end

function ItemModule:GetTierId(itemId, class)
    if(self.Tier17Map[itemId]) then
        return self.Tier17Map[itemId][class];
    end

    return nil;
end

function ItemModule:GetTierBonus(bonus)
    return self.Tier17BonusMap[bonus];
end

function ItemModule:IsTierToken(itemId, class)
    return self:GetTierId(itemId, class) ~= nil;
end

function ItemModule:ConvertTierToken(itemId, class, bonus)
    local tierId = self:GetTierId(itemId, class);
    local name, link = GetItemInfo(tierId);

    if(bonus) then
        link = link:gsub(":0|h%[", ":1:"..ItemModule:GetTierBonus(bonus).."|[");
    end

    return tierId, link, name;
end