local SWS_ADDON_NAME, StatWeightScore = ...;
local TooltipModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Tooltip");

local SpecModule;
local ScoreModule;
local ScanningTooltipModule;
local ItemModule;

local L;
local Utils;

local function FormatScore(score, diff, disabled)
    local disabledColor = "";
    if(disabled) then
        disabledColor = "|cFFCCCCCC";
    end

    local str = disabledColor..string.format("%.2f", score);
    if(diff ~= 0) then
        local color;
        local sign = "";

        if(diff < 0) then
            color = "|cFFFF0000";
            sign = "";
        else
            color = "|cFF00FF00+";
            sign = "+";
        end

        if(disabled) then
            color = "";
        end

        str = str.." ("..color..string.format("%.2f ", diff)..((score == diff) and "+inf%" or string.format("%s%.f%%", sign, (score / (score - diff) - 1) * 100)).."|r"..disabledColor..")";
    end

    return str;
end

function TooltipModule:OnInitialize()
    SpecModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Spec");
    ScoreModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Score");
    ScanningTooltipModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ScanningTooltip");
    ItemModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Item");
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
                            oneHand = oneHand or (equippedLocStr == INVTYPE_WEAPON);

                            local equippedScore = calculateScore(equippedLink, equippedLoc, spec, nil);
                            if(equippedScore == nil) then
                                break
                            end

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

                tooltip:AddDoubleLine(L["TooltipMessage_StatScore"].." ("..spec.Name..")", FormatScore(score.Score, diff, disabled));
                if(score.Offhand ~= nil) then
                    tooltip:AddDoubleLine(L["Offhand_Score"], FormatScore(score.Offhand, offhandDiff, disabled))
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