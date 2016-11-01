local SWS_ADDON_NAME, StatWeightScore = ...;
local ItemModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Item");

local ItemLinkModule;

local B = LibStub("LibBabble-Inventory-3.0");
local BL = B:GetUnstrictLookupTable();

local Utils;
local L;

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
local Warglaives = BL["Warglaives"] or "Warglaives";

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
    self.UpgradeMaps = {};

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
    AddMapping(self.ClassArmorMap, "DEMONHUNTER", Leather);

    AddMapping(self.ClassWeaponMap, "WARLOCK", OneHandedSwords, Daggers, Staves, Wands);
    AddMapping(self.ClassWeaponMap, "MAGE", OneHandedSwords, Daggers, Staves, Wands);
    AddMapping(self.ClassWeaponMap, "PRIEST", OneHandedMaces, Daggers, Staves, Wands);
    AddMapping(self.ClassWeaponMap, "DRUID", OneHandedMaces, TwoHandedMaces, Daggers, FistWeapons, Polearms, Staves);
    AddMapping(self.ClassWeaponMap, "ROGUE", OneHandedMaces, OneHandedSwords, OneHandedAxes, FistWeapons, Daggers);
    AddMapping(self.ClassWeaponMap, "MONK", OneHandedMaces, OneHandedSwords, OneHandedAxes, FistWeapons, Polearms, Staves);
    AddMapping(self.ClassWeaponMap, "SHAMAN", OneHandedMaces, TwoHandedMaces, OneHandedAxes, TwoHandedAxes, FistWeapons, Daggers, Staves);
    AddMapping(self.ClassWeaponMap, "HUNTER", Bows, Guns, Crossbows, Polearms);
    AddMapping(self.ClassWeaponMap, "WARRIOR", OneHandedMaces, TwoHandedMaces, OneHandedAxes, TwoHandedAxes, OneHandedSwords, TwoHandedSwords, FistWeapons, Daggers, Polearms);
    AddMapping(self.ClassWeaponMap, "PALADIN", OneHandedMaces, TwoHandedMaces, OneHandedAxes, TwoHandedAxes, OneHandedSwords, TwoHandedSwords, Polearms);
    AddMapping(self.ClassWeaponMap, "DEATHKNIGHT", OneHandedMaces, TwoHandedMaces, OneHandedAxes, TwoHandedAxes, OneHandedSwords, TwoHandedSwords, Polearms);
    AddMapping(self.ClassWeaponMap, "DEMONHUNTER", Warglaives, FistWeapons, Daggers, OneHandedAxes, OneHandedSwords);

    AddSimpleMapping(self.HeldInOffhandMap, "WARLOCK");
    AddSimpleMapping(self.HeldInOffhandMap, "MAGE");
    AddSimpleMapping(self.HeldInOffhandMap, "PRIEST");
    AddSimpleMapping(self.HeldInOffhandMap, "DRUID");
    AddSimpleMapping(self.HeldInOffhandMap, "MONK");
    AddSimpleMapping(self.HeldInOffhandMap, "SHAMAN");
    AddSimpleMapping(self.HeldInOffhandMap, "PALADIN");

    self.UniqueGroups = {
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

    local obliterumUpgradeMap = {
        Path = {
            ["596"] = {
                To = "597",
                Desc = string.format(L["Obliterum_Upgrade_Label"], 1, 8)
            },
            ["597"] = {
                To = "598",
                Desc = string.format(L["Obliterum_Upgrade_Label"], 2, 8)
            },
            ["598"] = {
                To = "599",
                Desc = string.format(L["Obliterum_Upgrade_Label"], 3, 8)
            },
            ["599"] = {
                To = "666",
                Desc = string.format(L["Obliterum_Upgrade_Label"], 4, 8)
            },
            ["666"] = {
                To = "667",
                Desc = string.format(L["Obliterum_Upgrade_Label"], 5, 8)
            },
            ["667"] = {
                To = "668",
                Desc = string.format(L["Obliterum_Upgrade_Label"], 6, 8)
            },
            ["668"] = {
                To = "669",
                Desc = string.format(L["Obliterum_Upgrade_Label"], 7, 8)
            },
            ["669"] = {
                To = "670",
                Desc = string.format(L["Obliterum_Upgrade_Label"], 8, 8)
            }
        }
    };

    local classHallUpgradeMap = {
        Path = {
            ["3381"] = {
                To = "3382",
                Desc = string.format(L["ItemLevel_Upgrade_Label"], 820)
            },
            ["3382"] = {
                To = "3383",
                Desc = string.format(L["ItemLevel_Upgrade_Label"], 830)
            },
            ["3383"] = {
                To = "3384",
                Desc = string.format(L["ItemLevel_Upgrade_Label"], 840)
            },
        }
    };

    table.insert(self.UpgradeMaps, obliterumUpgradeMap);
    table.insert(self.UpgradeMaps, classHallUpgradeMap);
end

function ItemModule:OnInitialize()
    ItemLinkModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ItemLink");
    Utils = StatWeightScore.Utils;
    L = StatWeightScore.L;

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
    return ItemLinkModule:Parse(itemLink);
end

local function GetUpgradeBonus(map, itemLink)
    for b, _ in pairs(map.Path) do
        if(itemLink:HasBonus(b)) then
            return b;
        end
    end

    return nil;
end

local function GenerateUpgrades(map, from, link)
    local upgrades = {};

    while(true) do
        local upgradeInfo = map.Path[from];
        if(not upgradeInfo) then
            break;
        end

        link:RemoveBonus(from);
        link:AddBonus(upgradeInfo.To);

        local upgrade = {
            Desc = upgradeInfo.Desc,
            Link = link:ToString()
        };

        table.insert(upgrades, upgrade);

        from = upgradeInfo.To;
    end

    return upgrades;
end

function ItemModule:GetUpgrades(itemType, itemSubType, locStr, link)
    local itemLink = ItemLinkModule:Parse(link);
    local upgrades = {};

    for _, map in pairs(self.UpgradeMaps) do
        local upgrade = GetUpgradeBonus(map, itemLink);

        if(upgrade) then
            upgrades = Utils.TableConcat(upgrades, GenerateUpgrades(map, upgrade, itemLink));
        end
    end

    return upgrades;
end