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
    local textColor = "";
    if(disabled) then
        textColor = GRAY_FONT_COLOR_CODE;
    end

    local str = textColor..string.format("%.2f", score);
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

        str = str.." ("..color..sign..string.format("%.2f ", diff)..(((score == diff and characterScore == nil) or characterScore == 0) and "+inf%" or string.format("%s%."..precision.."f%%", sign, percentDiff * 100)).."|r"..textColor..")";
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

    WorldMapTooltip.ItemTooltip.Tooltip:HookScript("OnTooltipSetItem", addToPrimaryTooltip);

    if IsAddOnLoaded("AtlasLoot") then
        AtlasLootTooltip:HookScript("OnTooltipSetItem", addToPrimaryTooltip);
    end
end

local function calculateScore(link, loc, spec, tooltip, equippedItemHasSabersEye)
    return ScoreModule:CalculateItemScore(link, loc, ScanningTooltipModule:ScanTooltip(link), spec, equippedItemHasSabersEye);
end

local function GetComparedItem(link, spec)
    local itemName, _, _, itemLevel, _, _, _, _, loc = GetItemInfo(link);
    local slots = ItemModule.SlotMap[loc];
    if(not slots) then
        return nil;
    end

    local minEquippedScore;
    local minEquippedLink;
    local equipmentSet;

    local scoreTable = {};
    local isEquipped = false;
    local oneHand = false;

    local linkInfo = ItemModule:GetItemLinkInfo(link);

    local isEquippedItem = function(equippedLinkInfo, equippedItemLevel)
        return linkInfo.itemId == equippedLinkInfo.itemId and linkInfo.gem1Id == equippedLinkInfo.gem1Id and itemLevel == equippedItemLevel;
    end

    local equipmentSetID = spec.EquipmentSet and C_EquipmentSet.GetEquipmentSetID(spec.EquipmentSet);
    local _, _, _, setEquipped = equipmentSetID and C_EquipmentSet.GetEquipmentSetInfo(equipmentSetID);
    for _, slot in pairs(slots) do
        local equippedLink, set;

        if spec.EquipmentSet and spec.EquipmentSet ~= "" and not setEquipped then
            local locations = GetEquipmentSetLocations(spec.EquipmentSet);
            if locations then
                local location = locations[slot];
                if location then
                    local _, _, _, _, bagSlot, bag = EquipmentManager_UnpackLocation(location);
                    if bag then
                        equippedLink = GetContainerItemLink(bag, bagSlot);
                        set = spec.EquipmentSet;
                    end
                end
            else
                Utils.PrintError(string.format('Warning: set \'%s\' not found. Check if you didn\'t delete or rename it and ajust Associated Equipment Set option of \'%s\' spec.', spec.EquipmentSet, spec.Name));
                spec.EquipmentSet = nil;
            end
        end
        if not equippedLink then
            equippedLink = GetInventoryItemLink("player", slot);
        end

        if(equippedLink) then
            local _, _, _, equippedItemLevel, _, _, _, _, equippedLoc = GetItemInfo(equippedLink);
            local equippedLinkInfo = ItemModule:GetItemLinkInfo(equippedLink);
            local equippedLocStr = getglobal(equippedLoc);

            oneHand = oneHand or (equippedLocStr == INVTYPE_WEAPON or (SpecModule:IsDualWielding2h() and locStr == INVTYPE_2HWEAPON));

            local equippedScore = calculateScore(equippedLink, equippedLoc, spec, nil);
            if(equippedScore) then
                scoreTable[slot] = equippedScore;

                local uniqueFamily, maxUniqueEquipped = GetItemUniqueness(link);
                if(uniqueFamily == -1 and maxUniqueEquipped == 1 and ItemModule:AreUniquelyExclusive(itemName, GetItemInfo(equippedLink))) then
                    minEquippedScore = equippedScore;
                    minEquippedLink = equippedLink;
                    equipmentSet = set;
                    break;
                end

                if(not isEquippedItem(equippedLinkInfo, equippedItemLevel)) then
                    if(not minEquippedScore or equippedScore.Score < minEquippedScore.Score) then
                        minEquippedScore = equippedScore;
                        minEquippedLink = equippedLink;
                        equipmentSet = set;
                    end
                else
                    isEquipped = true;
                    minEquippedLink = equippedLink;
                    minEquippedScore = equippedScore;
                    equipmentSet = set;
                end
            end
        end
    end

    return minEquippedLink, minEquippedScore, scoreTable, equipmentSet, isEquipped, oneHand;
end

local function GetScoreDiff(link, score, equippedScore, isUpgradePath, scoreTable, isEquipped, oneHand)
    local _, _, _, _, _, _, _, _, loc = GetItemInfo(link);
    local locStr = getglobal(loc);

    local diff = 0;
    local offhandDiff = 0;

    if(isEquipped and not isUpgradePath) then
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
        diff = score.Score - (equippedScore and equippedScore.Score or 0);
    end

    return diff, offhandDiff;
end

function TooltipModule:AddToTooltip(tooltip, compare)
    local db = StatWeightScore.db.profile;

    if(not db.EnableTooltip) then
        return;
    end

    local _, link = tooltip:GetItem();
    local _, class = UnitClass("player");

    if IsEquippableItem(link) then
        local _, _, _, _, _, itemType, itemSubType, _, loc = GetItemInfo(link);
        local blankLineHandled = false;
        local count = 0;
        local maxCount = 0;
        for _, _ in pairs(db.Specs) do
            maxCount = maxCount + 1;
        end

        local locStr = getglobal(loc);
        local upgrades = ItemModule:GetUpgrades(itemType, itemSubType, locStr, link);

        local specs = SpecModule:GetSpecs();
        for _, specKey in ipairs(Utils.OrderKeysBy(specs, "Order")) do
            count = count + 1;
            local spec = specs[specKey];
            if(spec.Enabled) then
                local characterScore;
                if(db.ScoreCompareType == "total") then
                    characterScore = CharacterModule:CalculateTotalScore(spec);
                end

                local minEquippedLink, minEquippedScore, scoreTable, equipmentSet, isEquipped, oneHand = GetComparedItem(link, spec);

                local score = calculateScore(link, loc, spec, tooltip, minEquippedScore and minEquippedScore.HasSabersEye);

                local diff = 0;
                local offhandDiff = 0;

                if(compare) then
                    diff, offhandDiff = GetScoreDiff(link, score, minEquippedScore, false, scoreTable, isEquipped, oneHand);
                end

                local disabled = not ItemModule:IsItemForClass(itemType, itemSubType, locStr, class);

                if(not blankLineHandled) then
                    if((compare and db.BlankLineMainAbove) or (not compare and db.BlankLineRefAbove)) then
                        tooltip:AddLine(" ");
                    end

                    blankLineHandled = true;
                end

                local specColor = spec.ColorHex or "";
                local scoreStr = FormatScore(score.Score, diff, disabled, characterScore, db.PercentageCalculationType);
                local compact = db.CompactMode and not IsControlKeyDown();

                if(not compact) then
                    tooltip:AddDoubleLine(specColor..(spec.Icon and (spec.Icon.." ") or "")..L["TooltipMessage_StatScore"].." ("..spec.Name..")", scoreStr);
                    if(equipmentSet) then
                        tooltip:AddLine(string.format(L["TooltipMessage_EquipmentSetCompare"], minEquippedLink, equipmentSet));
                    end
                    if(score.ArtifactOffhand) then
                        tooltip:AddLine(L["TooltipMessage_ArtifactOffhand"]);
                    end
                    if(score.Offhand ~= nil) then
                        tooltip:AddDoubleLine(L["Offhand_Score"], FormatScore(score.Offhand, offhandDiff, disabled, characterScore, db.PercentageCalculationType))
                    end
                    if(score.Gems) then
                        for _, gem in ipairs(score.Gems) do
                            tooltip:AddDoubleLine(L["TooltipMessage_WithGem"], string.format("+%i %s", gem.Value, gem.Stat))
                        end
                    end
                    if(score.Proc) then
                        tooltip:AddDoubleLine(L["TooltipMessage_WithProcAverage"], string.format("+%i %s", score.Proc.AverageValue, score.Proc.Stat))
                    end
                    if(score.Use) then
                        tooltip:AddDoubleLine(L["TooltipMessage_WithUseAverage"], string.format("+%i %s", score.Use.AverageValue, score.Use.Stat))
                    end

                    if(#upgrades ~= 0 and db.ShowUpgrades) then
                        for _, upgrade in ipairs(upgrades) do
                            local upgradeScore = calculateScore(upgrade.Link, loc, spec, tooltip, minEquippedScore and minEquippedScore.HasSabersEye);
                            local upgradeDiff = 0;
                            local upgradeOffhandDiff = 0;

                            if(compare) then
                                upgradeDiff, upgradeOffhandDiff = GetScoreDiff(upgrade.Link, upgradeScore, minEquippedScore, true, scoreTable, isEquipped);
                            end

                            tooltip:AddDoubleLine(upgrade.Desc, FormatScore(upgradeScore.Score, upgradeDiff, disabled, characterScore, db.PercentageCalculationType));

                            if(score.Offhand ~= nil) then
                                tooltip:AddDoubleLine(string.format(L["TooltipMessage_Offhand"], upgrade.Desc), FormatScore(upgradeScore.Score, upgradeDiff, disabled, characterScore, db.PercentageCalculationType));
                            end
                        end
                    end
                else
                    tooltip:AddDoubleLine(specColor..(spec.Icon and (spec.Icon.." ") or "")..spec.Name, scoreStr);
                end

                if(count == maxCount) then
                    if((compare and db.BlankLineMainBelow) or (not compare and db.BlankLineRefBelow)) then
                        tooltip:AddLine(" ");
                    end
                else
                    if(not compact) then
                        tooltip:AddLine(" ");
                    end
                end
            end
        end
    end
end
