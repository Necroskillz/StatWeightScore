local SWS_ADDON_NAME, StatWeightScore = ...;
local TooltipModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Tooltip");

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

    local _, _, _, _, id, _, gem1, _, _, _, _, _, _, _ =
    string.find(itemLink,
        "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?");

    return id, gem1;
end

function TooltipModule:OnInitialize()
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

    if IsEquippableItem(link) then
        local itemName, _, _, itemLevel, _, _, _, _, loc = GetItemInfo(link);
        local itemId, itemGem1 = GetItemLinkInfo(link);
        local uniqueFamily, maxUniqueEquipped = GetItemUniqueness(link);
        local blankLineHandled = false;
        local count = 0;
        local maxCount = 0;
        for _, _ in ipairs(db.Specs) do
            maxCount = maxCount + 1;
        end

        local locStr = getglobal(loc);

        local isEquippedItem = function(comparedItemId, comparedItemLevel, comparedGem1)
            return comparedItemId == itemId and comparedItemLevel == itemLevel and ((comparedGem1 ~= 0 and itemGem1 ~= 0) or (comparedGem1 == 0 and itemGem1 == 0));
        end

        for _, specKey in ipairs(Utils.SortedKeys(db.Specs, function(key1, key2)
            return db.Specs[key1].Order < db.Specs[key2].Order;
        end)) do
            count = count + 1;
            local spec = db.Specs[specKey];
            if(spec.Enabled) then
                local score = ScoreModule:CalculateItemScore(link, loc, tooltip, spec);
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
                            local equippedItemId, equippedItemGem1 = GetItemLinkInfo(equippedLink);
                            oneHand = oneHand or (equippedLocStr == INVTYPE_WEAPON);

                            local equippedScore = ScoreModule:CalculateItemScore(equippedLink, loc, ScanningTooltipModule:ScanTooltip(equippedLink), spec);

                            scoreTable[slot] = equippedScore;

                            if(uniqueFamily == -1 and maxUniqueEquipped == 1 and AreUniquelyExclusive(itemName, GetItemInfo(equippedLink))) then
                                minEquippedScore = equippedScore.Score;
                                break;
                            end

                            if(not isEquippedItem(equippedItemId, equippedItemLevel, equippedItemGem1)) then
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

                if(count == maxCount and blankLineHandled) then
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