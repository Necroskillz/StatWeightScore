local SWS_ADDON_NAME, StatWeightScore = ...;
local ItemModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Item");

local ItemLinkModule;

local B = LibStub("LibBabble-Inventory-3.0");
local BL = B:GetLookupTable();

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
--local Warglaives = BL["Warglaives"];

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
    -- TODO: replace warglaives when LibBabble-Inventory is updated
    AddMapping(self.ClassWeaponMap, "DEMONHUNTER", "Warglaives", FistWeapons, Daggers, OneHandedAxes, OneHandedSwords);

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
        ["Spellbound Runic Band of Elemental Invincibility"] = 1,
        ["Sanctus, Sigil of the Unbroken"] = 1,
        ["Nithramus, the All-Seer"] = 1,
        ["Etheralus, the Eternal Reward"] = 1,
        ["Thorasus, the Stone Heart of Draenor"] = 1,
        ["Maalus, the Blood Drinker"] = 1,
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

    self.WeaponCraftingUpgradeMap = {
        ["525"] = {
            To = "558",
            Desc = string.format(L["Crafting_Upgrade_Label"], 2, 6)
        },
        ["558"] = {
            To = "559",
            Desc = string.format(L["Crafting_Upgrade_Label"], 3, 6)
        },
        ["559"] = {
            To = "594",
            Desc = string.format(L["Crafting_Upgrade_Label"], 4, 6)
        },
        ["594"] = {
            To = "619",
            Desc = string.format(L["Crafting_Upgrade_Label"], 5, 6)
        },
        ["619"] = {
            To = "620",
            Desc = string.format(L["Crafting_Upgrade_Label"], 6, 6)
        }
    };

    self.ArmorCraftingUpgradeMap = {
        ["525"] = {
            To = "526",
            Desc = string.format(L["Crafting_Upgrade_Label"], 2, 6)
        },
        ["526"] = {
            To = "527",
            Desc = string.format(L["Crafting_Upgrade_Label"], 3, 6)
        },
        ["527"] = {
            To = "593",
            Desc = string.format(L["Crafting_Upgrade_Label"], 4, 6)
        },
        ["593"] = {
            To = "617",
            Desc = string.format(L["Crafting_Upgrade_Label"], 5, 6)
        },
        ["617"] = {
            To = "618",
            Desc = string.format(L["Crafting_Upgrade_Label"], 6, 6)
        }
    };

    self.BalefulUpgradeMap = {
        ["BASE"] = {
            To = "651",
            Desc =  ITEM_QUALITY4_DESC
        },
        ["651"] = {
            To = "648",
            Desc = L["Empowered_Upgrade_Label"]
        },
    };

    self.DreanorValorUpgradeMap = {
        ["529"] = {
            To = "530",
            Desc = L["Upgrade_1_Label"]
        },
        ["530"] = {
            To = "531",
            Desc = L["Upgrade_2_Label"]
        }
    };

    self.InvasionUpgradeMap = {
        ["1816"] = {
            To = "3331",
            Desc = string.format(L["Crafting_Upgrade_Label"], 2, 6)
        },
        ["3331"] = {
            To = "1817",
            Desc = string.format(L["Crafting_Upgrade_Label"], 3, 6)
        },
        ["1817"] = {
            To = "1819",
            Desc = string.format(L["Crafting_Upgrade_Label"], 4, 6)
        },
        ["1819"] = {
            To = "1818",
            Desc = string.format(L["Crafting_Upgrade_Label"], 5, 6)
        },
        ["1818"] = {
            To = "1820",
            Desc = string.format(L["Crafting_Upgrade_Label"], 6, 6)
        }
    };
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
    local parsed = ItemLinkModule:Parse(link);
    link = parsed:ToString();

    if(bonus) then
        local parsed = ItemLinkModule:Parse(link);
        table.insert(parsed.bonuses, self:GetTierBonus(bonus));
        link = parsed:ToString();
    end

    return tierId, link, name;
end

function ItemModule:GetCraftingMap(itemType, itemSubType, locStr)
    if(itemType == Weapon or itemSubType == Shields or locStr == INVTYPE_HOLDABLE) then
        return self.WeaponCraftingUpgradeMap;
    else
        return self.ArmorCraftingUpgradeMap;
    end
end

local function GetUpgradeBonus(map, itemLink)
    for b, _ in pairs(map) do
        if(itemLink:HasBonus(b)) then
            return b;
        end
    end

    return nil;
end

function ItemModule:GetCraftedUpgradeBonus(itemType, itemSubType, locStr, itemLink)
    return GetUpgradeBonus(self:GetCraftingMap(itemType, itemSubType, locStr), itemLink);
end

function ItemModule:GetBalefulUpgradeBonus(itemLink)
    if(not (itemLink:HasBonus("652") or itemLink:HasBonus("653"))) then
        return nil;
    end

    local bonus = GetUpgradeBonus(self.BalefulUpgradeMap, itemLink);
    if(bonus) then
        return bonus
    end

    if(not itemLink:HasBonus("648")) then
        return "BASE";
    end

    return nil;
end

function ItemModule:GetDreanorValorUpgrade(itemLink)
    if(itemLink.upgradeType ~= "4") then
        return nil;
    end

    local upgrade = self.DreanorValorUpgradeMap[itemLink.upgradeId];
    if(upgrade) then
        return itemLink.upgradeId;
    end

    return nil;
end

function ItemModule:GetInvasionUpgradeBonus(itemLink)
    return GetUpgradeBonus(self.InvasionUpgradeMap, itemLink);
end

local function GenerateUpgrades(map, from, link, type, descPrefix)
    local upgrades = {};
    descPrefix = descPrefix or '';

    while(true) do
        local upgradeInfo = map[from];
        if(not upgradeInfo) then
            break;
        end

        if(type == "bonus") then
            link:RemoveBonus(from);
            link:AddBonus(upgradeInfo.To);
        elseif(type == "upgrade") then
            link.upgradeId = upgradeInfo.To;
        end

        local upgrade = {
            Desc = descPrefix..upgradeInfo.Desc,
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

    local craftedBonus = self:GetCraftedUpgradeBonus(itemType, itemSubType, locStr, itemLink);
    local balefulBonus = self:GetBalefulUpgradeBonus(itemLink);
    local invasionBonus = self:GetInvasionUpgradeBonus(itemLink);
    local dreanorValorUpgrade = self:GetDreanorValorUpgrade(itemLink);

    if(craftedBonus) then
        upgrades = Utils.TableConcat(upgrades, GenerateUpgrades(self:GetCraftingMap(itemType, itemSubType, locStr), craftedBonus, itemLink, "bonus"));
    elseif(balefulBonus) then
        upgrades = Utils.TableConcat(upgrades, GenerateUpgrades(self.BalefulUpgradeMap, balefulBonus, itemLink, "bonus"));
    elseif(invasionBonus) then
        upgrades = Utils.TableConcat(upgrades, GenerateUpgrades(self.InvasionUpgradeMap, invasionBonus, itemLink, "bonus"));
    end

    if(dreanorValorUpgrade) then
        local descPrefix = '';
        if(upgrades) then
            local lastUpgrade = upgrades[#upgrades];
            if(lastUpgrade) then
                descPrefix = lastUpgrade.Desc..' + ';
            end
        end

        upgrades = Utils.TableConcat(upgrades, GenerateUpgrades(self.DreanorValorUpgradeMap, dreanorValorUpgrade, itemLink, "upgrade", descPrefix));
    end

    return upgrades;
end