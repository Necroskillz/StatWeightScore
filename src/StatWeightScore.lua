StatWeightScore = {
    Version = "0.3"
};

StatWeightScore_Settings = nil;

StatWeightScore.Options = nil;
StatWeightScore.Weights = nil;

StatWeightScore.StatRepository = {};
StatWeightScore.StatAliasMap = {};

local L = LibStub("AceLocale-3.0"):GetLocale("StatWeightScore");

StatWeightScore.SlotMap = {
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

StatWeightScore.Gem = {
    [1] = {
        Value = 35,
        Name = string.format(L["GemsDisplayFormat"], "+35");
    },
    [2] = {
        Value = 50,
        Name = string.format(L["GemsDisplayFormat"], "+50");
    }
};

StatWeightScore.UniqueGroups = {
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

StatWeightScore.Cache = {};

function StatWeightScore.OnEvent(_, event, arg1, arg2)
    if(event == "ADDON_LOADED" and arg1 == "StatWeightScore") then
        StatWeightScore.Initialize();
        StatWeightScore.InitializeOptions();
    end
end

function StatWeightScore.Initialize()
    SLASH_SWS1 = "/sws";

    SlashCmdList["SWS"] = function(args)
        InterfaceOptionsFrame_OpenToCategory("Stat Weight Score");
        InterfaceOptionsFrame_OpenToCategory("Stat Weight Score"); -- bug in blizz interface options
    end

    ItemRefTooltip:HookScript("OnTooltipSetItem", StatWeightScore.AddToPrimaryTooltip);

    ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", StatWeightScore.AddToCompareTooltip);
    ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", StatWeightScore.AddToCompareTooltip);

    GameTooltip:HookScript("OnTooltipSetItem", StatWeightScore.AddToPrimaryTooltip);

    ShoppingTooltip1:HookScript("OnTooltipSetItem", StatWeightScore.AddToCompareTooltip);
    ShoppingTooltip2:HookScript("OnTooltipSetItem", StatWeightScore.AddToCompareTooltip);

    StatWeightScore.PopulateStatRepository();
    StatWeightScore.LoadProfile();

    local scanningTooltip = CreateFrame("GameTooltip", "StatWeightScore_ScanningTooltip", nil, "GameTooltipTemplate");

    StatWeightScore.Print(string.format(L["WelcomeMessage"], StatWeightScore.Version));
end

function StatWeightScore.ScanTooltip(link)
    local scanningTooltip = StatWeightScore_ScanningTooltip;
    scanningTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
    scanningTooltip:SetHyperlink(link);

    return scanningTooltip;
end

function StatWeightScore.EnsureOptions(profile)
    if(not profile.Options) then
        profile.Options = {};
    end

    local set = function(option, value)
        if(profile.Options[option] == nil) then
            profile.Options[option] = value;
        end
    end;

    set("EnableTooltip", true);
    set("EnchantLevel", 1);
    set("BlankLineMainAbove", true);
    set("BlankLineMainBelow", true);
    set("BlankLineRefAbove", true);
    set("BlankLineRefBelow", true);

    return profile.Options;
end

function StatWeightScore.SaveProfile()
    local realm = GetRealmName();
    local name = UnitName("player");
    local profile = StatWeightScore_Settings[realm][name];
    profile.Options = StatWeightScore.Options;
    profile.Weights = StatWeightScore.Weights;
end

function StatWeightScore.LoadProfile()
    if(not StatWeightScore_Settings) then
        StatWeightScore_Settings = {};
    end

    local realm = GetRealmName();
    local name = UnitName("player");

    StatWeightScore_Settings[realm] = StatWeightScore_Settings[realm] or {};
    StatWeightScore_Settings[realm][name] = StatWeightScore_Settings[realm][name] or {};

    local profile = StatWeightScore_Settings[realm][name];

    StatWeightScore.Options = StatWeightScore.EnsureOptions(profile);

    StatWeightScore.Weights = profile.Weights or {};
end

function StatWeightScore.PopulateStatRepository()
    local addAlias = function(alias, key)
        StatWeightScore.StatAliasMap[alias] = key;
        StatWeightScore.StatAliasMap[key] = alias;
    end

    local addStat = function(alias, key, options)
        options = options or {};
        addAlias(alias, key);
        StatWeightScore.StatRepository[key] = {
            Key = key;
            Alias = alias;
            DisplayName = getglobal(key);
            Gem = not not options.Gem;
        };
    end

    addStat("dps", "ITEM_MOD_DAMAGE_PER_SECOND_SHORT");

    addStat("agi", "ITEM_MOD_AGILITY_SHORT");
    addStat("int", "ITEM_MOD_INTELLECT_SHORT");
    addStat("sta", "ITEM_MOD_STAMINA_SHORT", { Gem = true });
    addStat("spi", "ITEM_MOD_SPIRIT_SHORT");
    addStat("str", "ITEM_MOD_STRENGTH_SHORT");
    addStat("mastery", "ITEM_MOD_MASTERY_RATING_SHORT", { Gem = true });

    addStat("armor", "RESISTANCE0_NAME");
    addStat("bonusarmor", "BONUS_ARMOR");

    addStat("ap", "ITEM_MOD_ATTACK_POWER_SHORT");
    addStat("crit", "ITEM_MOD_CRIT_RATING_SHORT", { Gem = true });
    addStat("haste", "ITEM_MOD_HASTE_RATING_SHORT", { Gem = true });
    addStat("sp", "ITEM_MOD_SPELL_POWER_SHORT");
    addStat("multistrike", "ITEM_MOD_CR_MULTISTRIKE_SHORT", { Gem = true });
    addStat("versatility", "ITEM_MOD_VERSATILITY", { Gem = true });

    addAlias("socket", "EMPTY_SOCKET_PRISMATIC");
end

function StatWeightScore.GetStatInfo(alias)
    return StatWeightScore.StatRepository[StatWeightScore.StatAliasMap[alias]];
end

function StatWeightScore.GetStatInfoByDisplayName(displayName)
    for _, stat in pairs(StatWeightScore.StatRepository) do
        if(stat.DisplayName:lower() == displayName) then
            return stat;
        end
    end
end

function StatWeightScore.GetBestGemStat(weights)
    local cacheKey = "BestGemStat";

    if(StatWeightScore.Cache[cacheKey]) then
        return StatWeightScore.Cache[cacheKey];
    end

    local bestStat;
    local bestStatWeight = 0;

    for stat, weight in pairs(weights) do
        local statInfo = StatWeightScore.GetStatInfo(stat);
        if(statInfo.Gem) then
            if(weight > bestStatWeight) then
                bestStatWeight = weight;
                bestStat = statInfo;
            end
        end
    end

    StatWeightScore.Cache[cacheKey] = {
        Stat = bestStat;
        Weight = bestStatWeight;
    };

    return StatWeightScore.Cache[cacheKey];
end

function StatWeightScore.CalculateItemScore(link, loc, tooltip, weights)
    local stats = GetItemStats(link);
    local secondaryStat = StatWeightScore.GetBestGemStat(weights);

    local result = {
        Score = 0;
    };

    if(stats[StatWeightScore.StatAliasMap["socket"]]) then
        local _, gemLink = GetItemGem(link, 1);
        local enchantLevel;
        local gemStatWeight;
        local gemStat;
        if(gemLink) then
            local gemName, _, gemQuality = GetItemInfo(gemLink);

            if(gemQuality == 2) then
                enchantLevel = 1
            elseif(gemQuality == 3) then
                enchantLevel = 2
            end

            for stat, weight in pairs(weights) do
                local statInfo = StatWeightScore.GetStatInfo(stat);
                if(statInfo.Gem and string.find(gemName, statInfo.DisplayName)) then
                    gemStatWeight = weight;
                    gemStat = statInfo;
                end
            end
        elseif(secondaryStat) then
            enchantLevel = StatWeightScore.Options.EnchantLevel;
            gemStatWeight = secondaryStat.Weight;
            gemStat = secondaryStat.Stat;
        end

        if(gemStat) then
            local statValue = StatWeightScore.Gem[enchantLevel].Value;
            result.Score = result.Score + statValue * gemStatWeight;
            result.Gem = {
                Stat = gemStat.Alias;
                Value = statValue;
            };
        end
    end

    -- Use: Increases your <stat> by <value> for <dur> sec. (<cd> Min Cooldown)
    -- Use: Increases <stat> by <value> for <dur> sec. (<cdm> Min <cds> Sec Cooldown)
    -- Use: Grants <value> <stat> for <dur> sec. (<cdm> Min <cds> Sec Cooldown)
    -- Equip: Your attacks have a chance to grant <value> <stat> for <dur> sec.  (Approximately <procs> procs per minute)
    -- Equip: Each time your attacks hit, you have a chance to gain <value> <stat> for <dur> sec. (<chance>% chance, <cd> sec cooldown)
    -- +<value> Bonus Armor

    if((getglobal(loc) == INVTYPE_TRINKET) or weights["bonusarmor"]) then
        if(tooltip) then
            for l = 1,tooltip:NumLines() do
                local tooltipText = getglobal(tooltip:GetName().."TextLeft"..l);
                if(tooltipText) then
                    local line = (tooltipText:GetText() or ""):lower():gsub(",", "");
                    if(line:match("^equip:") or line:match("^use:") or line:match("bonus armor")) then
                        local match, len, value, stat, duration, ppm, cd, chance, averageStatValue, statInfo, weight;

                        local addResult = function(type)
                            result.Score = result.Score + averageStatValue * weight
                            result[type] = {
                                AverageValue = averageStatValue;
                                Stat = statInfo.Alias;
                            };
                        end;

                        match,len,value,stat,duration,ppm = line:find("^equip: your attacks have a chance to grant (%d+) ([%l ]-) for (%d+) sec%.  %(approximately ([%d%.]+) procs per minute%)$");

                        if(match) then
                            statInfo = StatWeightScore.GetStatInfoByDisplayName(stat);
                            if(statInfo) then
                                weight = weights[statInfo.Alias];

                                if(weight) then
                                    value = tonumber(value);
                                    duration = tonumber(duration);
                                    ppm = tonumber(ppm);
                                    local haste = GetCombatRatingBonus(CR_HASTE_RANGED);

                                    local uptime = ppm * duration * (1 + haste / 100) / 60;
                                    averageStatValue = uptime * value;

                                    addResult("Proc");
                                end
                            end
                        end

                        match,len,value,stat,duration,chance,cd = line:find("^equip: each time your attacks hit you have a chance to gain (%d+) ([%l ]-) for (%d+) sec%.  %((%d+)%% chance (%d+) sec cooldown%)$");

                        if(match) then
                            statInfo = StatWeightScore.GetStatInfoByDisplayName(stat);
                            if(statInfo) then
                                weight = weights[statInfo.Alias];

                                if(weight) then
                                    value = tonumber(value);
                                    duration = tonumber(duration);
                                    cd = tonumber(cd);
                                    chance = tonumber(chance)/100;

                                    local attackSpeed = UnitAttackSpeed("player");
                                    local assumedAttacksPerSecond = 1/(attackSpeed/2);

                                    local uptime = duration / (cd + (1/chance) * assumedAttacksPerSecond);
                                    averageStatValue = uptime * value;

                                    addResult("Proc");
                                end
                            end
                        end

                        match, len, stat, value, duration, cd = line:find("^use: increases y?o?u?r? ?([%l ]-) by (%d+) for (%d+) sec%. %(([%d%l ]-) cooldown%)$");

                        if(not match) then
                            match, len, value, stat , duration, cd = line:find("^use: grants (%d+) ([%l ]-) for (%d+) sec%. %(([%d%l ]-) cooldown%)$");
                        end

                        if(match) then
                            statInfo = StatWeightScore.GetStatInfoByDisplayName(stat);
                            if(statInfo) then
                                weight = weights[statInfo.Alias];

                                if(weight) then
                                    value = tonumber(value);
                                    duration = tonumber(duration);
                                    local cdmin = tonumber(cd:match("(%d+) min"));
                                    local cdsec = tonumber(cd:match("(%d+) sec") or 0);
                                    local cooldown = cdmin * 60 + cdsec;

                                    local uptime = duration / cooldown;
                                    averageStatValue = uptime * value;

                                    addResult("Use");
                                end
                            end
                        end

                        match, len, value = line:find("^%+(%d+) bonus armor$");

                        if(match) then
                            local armorKey = StatWeightScore.StatAliasMap["armor"];
                            stats[armorKey] = stats[armorKey] - value;
                            stats[StatWeightScore.StatAliasMap["bonusarmor"]] = value;
                        end
                    end
                end
            end
        end
    end

    for stat, value in pairs(stats) do
        local alias = StatWeightScore.StatAliasMap[stat];
        local weight = weights[alias];
        if(weight) then
            result.Score = result.Score + value * weight;
        end
    end

    return result;
end

function StatWeightScore.AddToPrimaryTooltip(self)
    StatWeightScore.AddToTooltip(self, true);
end

function StatWeightScore.AddToCompareTooltip(self)
    StatWeightScore.AddToTooltip(self, false);
end

function StatWeightScore.AddToTooltip(tooltip, compare)
    if(not StatWeightScore.Options.EnableTooltip) then
        return;
    end

    local _, link = tooltip:GetItem();

    if IsEquippableItem(link) then
        local itemName, _, _, _, _, _, _, _, loc = GetItemInfo(link);
        local uniqueFamily, maxUniqueEquipped = GetItemUniqueness(link);
        local blankLineHandled = false;
        local count = 0;
        local maxCount = #StatWeightScore.Weights;

        for _, spec in ipairs(StatWeightScore.Weights) do
            count = count + 1;
            if(spec.Enabled) then
                local score = StatWeightScore.CalculateItemScore(link, loc, tooltip, spec.Weights);
                local diff = 0;

                local slots = StatWeightScore.SlotMap[loc];
                if(not slots) then
                    return;
                end

                if(compare) then
                    local minEquippedScore = -1;

                    for _, slot in pairs(slots) do
                        local equippedLink = GetInventoryItemLink("player", slot);
                        if(equippedLink) then
                            local equippedScore = StatWeightScore.CalculateItemScore(equippedLink, loc, StatWeightScore.ScanTooltip(equippedLink), spec.Weights);

                            if(uniqueFamily == -1 and maxUniqueEquipped == 1 and StatWeightScore.AreUniquelyExclusive(itemName, GetItemInfo(equippedLink))) then
                                minEquippedScore = equippedScore.Score;
                                break;
                            end

                            if(equippedScore.Score < minEquippedScore or minEquippedScore == -1) then
                                minEquippedScore = equippedScore.Score;
                            end
                        end
                    end

                    if(minEquippedScore ~= -1) then
                        diff = score.Score - minEquippedScore;
                    end
                end

                if(not blankLineHandled) then
                    if((compare and StatWeightScore.Options["BlankLineMainAbove"]) or (not compare and StatWeightScore.Options["BlankLineRefAbove"])) then
                        tooltip:AddLine(" ");
                    end

                    blankLineHandled = true;
                end

                tooltip:AddDoubleLine(L["TooltipMessage_StatScore"].." ("..spec.Name..")", StatWeightScore.FormatScore(score.Score, diff));
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
                    if((compare and StatWeightScore.Options["BlankLineMainBelow"]) or (not compare and StatWeightScore.Options["BlankLineRefBelow"])) then
                        tooltip:AddLine(" ");
                    end
                else
                    tooltip:AddLine(" ");
                end
            end
        end
    end
end

function StatWeightScore.AreUniquelyExclusive(item1, item2)
    if(item1 == item2) then
        return true;
    end

    local item1Group = StatWeightScore.UniqueGroups[item1];
    local item2Group = StatWeightScore.UniqueGroups[item2];

    if(item1Group and item2Group and item1Group == item2Group) then
        return true;
    end

    return false;
end

function StatWeightScore.GetItemLinkInfo(itemLink)
    if(not itemLink) then
        return nil;
    end

    local _, _, _, _, id, _, _, _, _, _, _, _, _, _ =
    string.find(itemLink,
        "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?");

    return id;
end

function StatWeightScore.FormatScore(score, diff)
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

        str = str.." ("..color..string.format("%.2f ", diff)..string.format("%s%.f%%", sign, (score / (score - diff) - 1) * 100).."|r)";
    end

    return str;
end

local frame = CreateFrame("Frame", "StatWeightScore_Main", UIParent);
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("SHOW_COMPARE_TOOLTIP");
frame:SetScript("OnEvent", StatWeightScore.OnEvent);

function StatWeightScore.Print(text)
    if(text == nil) then
        text = "-nil-";
    end

    if(type(text) == "table") then
        print("StatWeightScore (table):")
        for i,v in pairs(text) do
            print(i.." : "..tostring(v));
        end
    else
        print("StatWeightScore: "..tostring(text));
    end
end