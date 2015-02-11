local SWS_ADDON_NAME, StatWeightScore = ...;
local TooltipModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Tooltip");

local SpecModule;
local ScoreModule;
local ScanningTooltipModule;

local L;
local Utils;

local UniqueGroups = {
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
};

local TierMap = {
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
        ["PRIEST"] = "115560",
        ["WARLOCK"] = "115588"
    },
    ["119305"] = { -- Chest of Iron Conqueror
        ["PALADIN"] = "115565",
        ["PRIEST"] = "115561",
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

local TierBonusMap = {
    ["570"] = "566", -- heroic
    ["569"] = "567" -- mythic
}

local SlotMap = {
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
    INVTYPE_SHIELD = {17},
    INVTYPE_2HWEAPON = {16},
    INVTYPE_WEAPONMAINHAND = {16},
    INVTYPE_WEAPONOFFHAND = {17},
    INVTYPE_HOLDABLE = {17},
    INVTYPE_RANGED = {16,18},
    INVTYPE_THROWN = {18},
    INVTYPE_RANGEDRIGHT = {16,18},
    INVTYPE_RELIC = {18},
    INVTYPE_TABARD = {19},
};

local function FormatScore(score, diff)
    local str = string.format("%.2f", score);
    if(diff ~= 0) then
        local color;
        local sign;

        if(diff < 0) then
            color = "|cFFFF0000";
            sign = "";
        else
            color = "|cFF00FF00+";
            sign = "+";
        end

        str = str.." ("..color..string.format("%.2f ", diff)..((score == diff) and "+inf%" or string.format("%s%.f%%", sign, (score / (score - diff) - 1) * 100)).."|r)";
    end

    return str;
end

local function AreUniquelyExclusive(item1, item2)
    if(item1 == item2) then
        return true;
    end

    local item1Group = UniqueGroups[item1];
    local item2Group = UniqueGroups[item2];

    if(item1Group and item2Group and item1Group == item2Group) then
        return true;
    end

    return false;
end

local function GetItemLinkInfo(itemLink)
    if(not itemLink) then
        return nil;
    end

    local itemString = string.match(itemLink, "item[%-?%d:]+");
    local _, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, linkLevel, reforgeId, _, _, bonus = strsplit(":", itemString)

    return itemId, bonus;
end

function TooltipModule:OnInitialize()
    SpecModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Spec");
    ScoreModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Score");
    ScanningTooltipModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ScanningTooltip");
    L = StatWeightScore.L;
    Utils = StatWeightScore.Utils;

    local addToPrimaryTooltip = function(tooltip)
        self:AddToTooltip(tooltip, true);
    end

    local addToComapreTooltip = function(tooltip)
        self:AddToTooltip(tooltip, false);
    end

    ItemRefTooltip:HookScript("OnTooltipSetItem", addToPrimaryTooltip);

    ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", addToComapreTooltip);
    ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", addToComapreTooltip);

    GameTooltip:HookScript("OnTooltipSetItem", addToPrimaryTooltip);

    ShoppingTooltip1:HookScript("OnTooltipSetItem", addToComapreTooltip);
    ShoppingTooltip2:HookScript("OnTooltipSetItem", addToComapreTooltip);

    if IsAddOnLoaded("AtlasLoot") then
        AtlasLootTooltip:HookScript("OnTooltipSetItem", addToPrimaryTooltip);
    end
end

function TooltipModule:AddToTooltip(tooltip, compare)
    local db = StatWeightScore.db.profile;

    if(not db.EnableTooltip) then
        return;
    end

    local _, link = tooltip:GetItem();
    local itemId, bonus = GetItemLinkInfo(link);
    local _, class = UnitClass("player");
    local translatedTo;

    if(TierMap[itemId] and TierMap[itemId][class]) then
        itemId = TierMap[itemId][class];
        translatedTo, link = GetItemInfo(itemId);

        if(bonus) then
            link = link:gsub(":0|h%[", ":1:"..TierBonusMap[bonus].."|[");
        end
    end

    if IsEquippableItem(link) then
        local itemName, _, _, itemLevel, _, _, _, _, loc = GetItemInfo(link);
        local uniqueFamily, maxUniqueEquipped = GetItemUniqueness(link);
        local blankLineHandled = false;
        local count = 0;
        local maxCount = 0;
        for _, _ in pairs(db.Specs) do
            maxCount = maxCount + 1;
        end

        local locStr = getglobal(loc);
        local cmMode = db.EnableCmMode and select(3, GetInstanceInfo()) == 8;

        local calculateScore = function(link, loc, spec, tooltip)
            if(cmMode) then
                if(not tooltip) then
                    for i = 1,2 do
                        local shoppingTooltip = getglobal("ShoppingTooltip"..i);
                        if(select(2, shoppingTooltip:GetItem()) == link) then
                            tooltip = shoppingTooltip;
                            break;
                        end
                    end
                end
                return ScoreModule:CalculateItemScoreCM(link, loc, tooltip, spec);
            else
                return ScoreModule:CalculateItemScore(link, loc, ScanningTooltipModule:ScanTooltip(link), spec);
            end
        end

        for _, specKey in ipairs(Utils.OrderKeysBy(SpecModule:GetSpecs(), "Order")) do
            count = count + 1;
            local spec = db.Specs[specKey];
            if(spec.Enabled) then
                local score = calculateScore(link, loc, spec, tooltip);

                local isEquippedItem = function(comparedItemId, comparedItemLevel, comparedScore)
                    local scoreGem = score.Gem and score.Gem.Value..score.Gem.Stat or "";
                    local comparedScoreGem = comparedScore.Gem and comparedScore.Gem.Value..comparedScore.Gem.Stat or "";

                    return comparedItemId == itemId and comparedItemLevel == itemLevel and scoreGem == comparedScoreGem;
                end

                local diff = 0;
                local offhandDiff = 0;

                local slots = SlotMap[loc];
                if(not slots) then
                    return;
                end

                if(compare) then
                    local minEquippedScore = -1;

                    local scoreTable = {};
                    local oneHand = false;
                    local isEquipped = false;

                    for _, slot in pairs(slots) do
                        local equippedLink = GetInventoryItemLink("player", slot);
                        if(equippedLink) then
                            local equippedItemName, _, _, equippedItemLevel, _, _, _, _,equippedLoc = GetItemInfo(equippedLink);
                            local equippedLocStr = getglobal(equippedLoc);
                            local equippedItemId = GetItemLinkInfo(equippedLink);
                            oneHand = oneHand or (equippedLocStr == INVTYPE_WEAPON);

                            local equippedScore = calculateScore(equippedLink, equippedLoc, spec, nil);
                            if(equippedScore == nil) then
                                break
                            end

                            scoreTable[slot] = equippedScore;

                            if(uniqueFamily == -1 and maxUniqueEquipped == 1 and AreUniquelyExclusive(itemName, GetItemInfo(equippedLink))) then
                                minEquippedScore = equippedScore.Score;
                                break;
                            end

                            if(not isEquippedItem(equippedItemId, equippedItemLevel, equippedScore)) then
                                if(equippedScore.Score < minEquippedScore or minEquippedScore == -1) then
                                    minEquippedScore = equippedScore.Score;
                                end
                            else
                                isEquipped = true;
                            end
                        end
                    end

                    if(isEquipped) then
                        diff = 0
                    elseif(locStr == INVTYPE_WEAPON) then
                        if(oneHand) then
                            local mainhandScore =  scoreTable[16];

                            if(not mainhandScore) then
                                diff = 0;
                            else
                                diff = score.Score - mainhandScore.Score;
                            end

                            local offhandScore = scoreTable[17];
                            if(not offhandScore) then
                                offhandDiff = 0;
                            else
                                offhandDiff = (score.Offhand or score.Score) - (offhandScore.Offhand or offhandScore.Score);
                            end
                        else
                            diff = 0; -- uncomparable
                        end
                    elseif(oneHand) then
                        diff = 0;
                    elseif(minEquippedScore ~= -1) then
                        diff = score.Score - minEquippedScore;
                    end
                end

                if(not blankLineHandled) then
                    if((compare and db.BlankLineMainAbove) or (not compare and db.BlankLineRefAbove)) then
                        tooltip:AddLine(" ");
                    end

                    if(translatedTo) then
                        tooltip:AddLine(link);
                    end

                    blankLineHandled = true;
                end

                tooltip:AddDoubleLine(L["TooltipMessage_StatScore"].." ("..spec.Name..")", FormatScore(score.Score, diff));
                if(score.Offhand ~= nil) then
                    tooltip:AddDoubleLine(L["Offhand_Score"], FormatScore(score.Offhand, offhandDiff))
                end
                if(score.Gem)then
                    tooltip:AddDoubleLine(L["TooltipMessage_WithGem"], string.format("+%i %s", score.Gem.Value, score.Gem.Stat))
                end
                if(score.Proc)then
                    tooltip:AddDoubleLine(L["TooltipMessage_WithProcAverage"], string.format("+%i %s", score.Proc.AverageValue, score.Proc.Stat))
                end
                if(score.Use)then
                    tooltip:AddDoubleLine(L["TooltipMessage_WithUseAverage"], string.format("+%i %s", score.Use.AverageValue, score.Use.Stat))
                end

                if(count == maxCount) then
                    if((compare and db.BlankLineMainBelow) or (not compare and db.BlankLineRefBelow)) then
                        tooltip:AddLine(" ");
                    end
                else
                    tooltip:AddLine(" ");
                end
            end
        end
    end
end