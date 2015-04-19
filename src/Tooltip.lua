local SWS_ADDON_NAME, StatWeightScore = ...;
local TooltipModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Tooltip");

local SpecModule;
local ScoreModule;
local ScanningTooltipModule;
local ItemModule;
local CharacterModule;

local L;
local Utils;

local function FormatScore(score, diff, disabled, characterScore, percentageType)
    local disabledColor = "";
    if(disabled) then
        disabledColor = GRAY_FONT_COLOR_CODE;
    end

    local str = disabledColor..string.format("%.2f", score);
    if(diff ~= 0) then
        local color;
        local sign = "";

        if(diff < 0) then
            color = RED_FONT_COLOR_CODE;
            sign = "";
        else
            color = GREEN_FONT_COLOR_CODE;
            sign = "+";
        end

        if(disabled) then
            color = "";
        end

        local percentDiff;
        local oldScore;
        local newScore;
        local precision;

        if(characterScore ~= nil) then
            newScore = characterScore + diff;
            oldScore = characterScore;
            precision = "2";
        else
            newScore = score;
            oldScore = score - diff;
            precision = ""
        end

        if(percentageType == "diff") then
            percentDiff = (newScore - oldScore) / ((newScore + oldScore) / 2);
        else
            percentDiff = (newScore - oldScore) / oldScore;
        end

        str = str.." ("..color..sign..string.format("%.2f ", diff)..(((score == diff and characterScore == nil) or characterScore == 0) and "+inf%" or string.format("%s%."..precision.."f%%", sign, percentDiff * 100)).."|r"..disabledColor..")";
    end

    return str;
end

local function GetScoreTableValue(scoreTable, slot)
    local score = scoreTable[slot];
    if(score) then
        if(slot == 17 and score.Offhand) then
            return score.Offhand, true;
        end

        return score.Score, true;
    end

    return 0, false;
end

function TooltipModule:OnInitialize()
    SpecModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Spec");
    ScoreModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Score");
    ScanningTooltipModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ScanningTooltip");
    ItemModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Item");
    CharacterModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Character");
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
    local itemId, bonus = ItemModule:GetItemLinkInfo(link);
    local _, class = UnitClass("player");
    local translatedTo;

    if(ItemModule:IsTierToken(itemId, class)) then
        itemId, link, translatedTo = ItemModule:ConvertTierToken(itemId, class, bonus);
    end

    if IsEquippableItem(link) then
        local itemName, _, _, itemLevel, _, itemType, itemSubType, _, loc = GetItemInfo(link);
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

        local specs = SpecModule:GetSpecs();
        for _, specKey in ipairs(Utils.OrderKeysBy(specs, "Order")) do
            count = count + 1;
            local spec = specs[specKey];
            if(spec.Enabled) then
                local characterScore;
                if(db.ScoreCompareType == "total" and not cmMode) then
                    characterScore = CharacterModule:CalculateTotalScore(spec);
                end

                local score = calculateScore(link, loc, spec, tooltip);

                local isEquippedItem = function(comparedItemId, comparedItemLevel, comparedScore)
                    local scoreGem = score.Gem and score.Gem.Value..score.Gem.Stat or "";
                    local comparedScoreGem = comparedScore.Gem and comparedScore.Gem.Value..comparedScore.Gem.Stat or "";

                    return comparedItemId == itemId and comparedItemLevel == itemLevel and scoreGem == comparedScoreGem;
                end

                local diff = 0;
                local offhandDiff = 0;

                local slots = ItemModule.SlotMap[loc];
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
                            local equippedItemId = ItemModule:GetItemLinkInfo(equippedLink);
                            oneHand = oneHand or (equippedLocStr == INVTYPE_WEAPON or (SpecModule:IsDualWielding2h() and locStr == INVTYPE_2HWEAPON));

                            local equippedScore = calculateScore(equippedLink, equippedLoc, spec, nil);
                            if(equippedScore) then
                                scoreTable[slot] = equippedScore;

                                if(uniqueFamily == -1 and maxUniqueEquipped == 1 and ItemModule:AreUniquelyExclusive(itemName, GetItemInfo(equippedLink))) then
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
                            elseif(cmMode) then
                                isEquipped = true;
                            end
                        elseif(slot ~= 17) then
                            minEquippedScore = 0
                        end
                    end

                    if(isEquipped) then
                        diff = 0
                    elseif(locStr == INVTYPE_WEAPON or (SpecModule:IsDualWielding2h() and locStr == INVTYPE_2HWEAPON)) then
                        local mainHandScore = GetScoreTableValue(scoreTable, 16);
                        diff = score.Score - mainHandScore;

                        if(score.Offhand) then
                            if(oneHand) then
                                offhandDiff = score.Offhand - GetScoreTableValue(scoreTable, 17);
                            else
                                offhandDiff = score.Offhand - mainHandScore;
                            end
                        end
                    elseif(locStr == INVTYPE_2HWEAPON) then
                        diff = score.Score - GetScoreTableValue(scoreTable, 16) - GetScoreTableValue(scoreTable, 17);
                    elseif(locStr == INVTYPE_HOLDABLE or locStr == INVTYPE_SHIELD) then
                        local offhandScore, offhandExists = GetScoreTableValue(scoreTable, 17);
                        if(offhandExists) then
                            diff = score.Score - offhandScore;
                        else
                            if(not oneHand) then
                                diff = score.Score - GetScoreTableValue(scoreTable, 16);
                            else
                                diff = score.Score;
                            end
                        end
                    else
                        if(minEquippedScore == -1) then
                            minEquippedScore = 0;
                        end

                        diff = score.Score - minEquippedScore;
                    end
                end

                local disabled = not ItemModule:IsItemForClass(itemType, itemSubType, locStr, class);

                if(not blankLineHandled) then
                    if((compare and db.BlankLineMainAbove) or (not compare and db.BlankLineRefAbove)) then
                        tooltip:AddLine(" ");
                    end

                    if(translatedTo) then
                        tooltip:AddLine("|c"..select(4, GetItemQualityColor(4)).."["..translatedTo.."]");
                    end

                    blankLineHandled = true;
                end

                tooltip:AddDoubleLine(L["TooltipMessage_StatScore"].." ("..spec.Name..")", FormatScore(score.Score, diff, disabled, characterScore, db.PercentageCalculationType));
                if(score.Offhand ~= nil) then
                    tooltip:AddDoubleLine(L["Offhand_Score"], FormatScore(score.Offhand, offhandDiff, disabled, characterScore, db.PercentageCalculationType))
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