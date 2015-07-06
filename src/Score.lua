local SWS_ADDON_NAME, StatWeightScore = ...;
local ScoreModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Score");

local SpecModule;
local StatsModule;
local GemsModule;
local ScanningTooltipModule;

local Utils;
local L;

function ScoreModule:OnInitialize()
    SpecModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Spec");
    StatsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Stats");
    GemsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Gems");
    ScanningTooltipModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ScanningTooltip");
    Utils = StatWeightScore.Utils;
    L = StatWeightScore.L;

    self.Matcher = {
        Stats = {
        },
        PreCheck = {
            L["Matcher_Precheck_Equip"],
            L["Matcher_Precheck_Use"],
            gsub(L["Matcher_Precheck_BonusArmor"], "BONUS_ARMOR", BONUS_ARMOR)
        },
        Partial = {
            ["cdmin"] = L["Matcher_Partial_CdMin"],
            ["cdsec"] = L["Matcher_Partial_CdSec"]
        },
        Matchers = {
        }
    };

    self:RegisterStatMatcher("Armor", function(pattern)
        return gsub(pattern, "RESISTANCE0_NAME", RESISTANCE0_NAME);
    end);
    self:RegisterStatMatcher("DPS");
    self:RegisterStatMatcher("Stat");

    self:RegisterMatcher("RPPM", "rppm");
    self:RegisterMatcher("RPPM2", "rppm");
    self:RegisterMatcher("RPPM3", "rppm");
    self:RegisterMatcher("RPPM4", "rppm");
    self:RegisterMatcher("SoliumBand", "soliumband");
    self:RegisterMatcher("ICD", "icd");
    self:RegisterMatcher("ICD2", "icd");
    self:RegisterMatcher("ICD3", "icd");
    self:RegisterMatcher("InsigniaOfConquest", "insigniaofconquest");
    self:RegisterMatcher("InsigniaOfConquest2", "insigniaofconquest");
    self:RegisterMatcher("Use", "use");
    self:RegisterMatcher("Use2", "use");
    self:RegisterMatcher("Use3", "use");
    self:RegisterMatcher("Use4", "use");
    self:RegisterMatcher("BonusArmor", "bonusarmor", function(pattern)
        return gsub(pattern, "BONUS_ARMOR", BONUS_ARMOR);
    end);
    self:RegisterMatcher("BlackhandTrinket", "blackhandtrinket");
    self:RegisterMatcher("BlackhandTrinket2", "blackhandtrinket");
    self:RegisterMatcher("BlackhandTrinket3", "blackhandtrinket");
    self:RegisterMatcher("StoneOfFire", "stoneoffire");
end


function ScoreModule:RegisterStatMatcher(name, patternModFunc)
    local pattern = L["Matcher_StatTooltipParser_"..name];
    if(patternModFunc) then
        pattern = patternModFunc(pattern);
    end

    pattern = Utils.UnescapeUnicode(pattern);

    self.Matcher.Stats[name] = {
        Pattern = pattern,
        ArgOrder = Utils.SplitString(L["Matcher_StatTooltipParser_"..name.."_ArgOrder"])
    };
end

function ScoreModule:RegisterMatcher(name, fx, patternModFunc)
    local pattern = L["Matcher_"..name.."_Pattern"];
    if(not pattern or pattern:len() == 0) then
        return;
    end

    if(patternModFunc) then
        pattern = patternModFunc(pattern);
    end

    pattern = Utils.UnescapeUnicode(pattern);

    self.Matcher.Matchers[name] = {
        Pattern = pattern,
        Fx = fx,
        ArgOrder = Utils.SplitString(L["Matcher_"..name.."_ArgOrder"])
    };
end

local function UpdateResult(result, type, stat, averageStatValue, weight)
    result.Score = result.Score + averageStatValue * weight
    result[type] = {
        AverageValue = averageStatValue;
        Stat = stat.DisplayName;
    };
end

function ScoreModule:GetStatsFromTooltip(tooltip)
    local stats = {};

    if(tooltip) then
        for l = 1,tooltip:NumLines() do
            local tooltipText = getglobal(tooltip:GetName().."TextLeft"..l);
            if(tooltipText) then
                local line = (tooltipText:GetText() or "");
                local value, stat;

                for _, matcher in pairs(self.Matcher.Stats) do
                    local match = Utils.Pack(line:match(matcher.Pattern));

                    if(match) then
                        local argOrder = matcher.ArgOrder;
                        local args = {};

                        for i = 1, match.n do
                            local argName = argOrder[i];
                            local argValue = match[i]

                            args[argName] = argValue;
                        end

                        value = args["value"];
                        stat = args["stat"];
                        break;
                    end
                end

                if(value and stat) then
                    local statInfo = StatsModule:GetStatInfoByDisplayName(stat);
                    if(statInfo) then
                        stats[statInfo.Key] = Utils.ToNumber(value);
                    end
                end
            end
        end
    end

    return stats;
end

local function GetStatsFromLink(link)
    return GetItemStats(link);
end

local primaryStatIndex = {
    ["str"] = 1,
    ["agi"] = 2,
    ["int"] = 4
};

local function GetPrimaryStatForSpec(weights)
    local primaryStatValue, primaryStat;

    for _, alias in ipairs({"str","agi","int"}) do
        if(weights[alias]) then
            primaryStatValue = UnitStat("player", primaryStatIndex[alias]);
            primaryStat = alias;
            break;
        end
    end

    return primaryStat, primaryStatValue;
end

ScoreModule.Fx = {
    ["rppm"] = function(result, stats, weights, args)
        local statInfo = StatsModule:GetStatInfoByDisplayName(args["stat"]);
        if(not statInfo or not weights[statInfo.Alias]) then
            return;
        end

        local value = Utils.ToNumber(args["value"]);
        local duration = tonumber(args["duration"]);
        local ppm = Utils.ToNumber(args["ppm"]);
        local haste = GetCombatRatingBonus(CR_HASTE_RANGED);

        local uptime = ppm * duration * (1 + haste / 100) / 60;
        local averageStatValue = uptime * value;

        UpdateResult(result, "Proc", statInfo, averageStatValue, weights[statInfo.Alias]);
    end,
    ["icd"] = function(result, stats, weights, args)
        local statInfo = StatsModule:GetStatInfoByDisplayName(args["stat"]);
        if(not statInfo or not weights[statInfo.Alias]) then
            return;
        end

        local value = Utils.ToNumber(args["value"]);
        local duration = tonumber(args["duration"]);
        local cd = tonumber(args["cd"]);
        local chance = tonumber(args["chance"])/100;

        local attackSpeed = UnitAttackSpeed("player");
        local assumedAttacksPerSecond = 1/(attackSpeed/2);

        local uptime = duration / (cd + (1/chance) * assumedAttacksPerSecond);
        local averageStatValue = uptime * value;

        UpdateResult(result, "Proc", statInfo, averageStatValue, weights[statInfo.Alias]);
    end,
    ["use"] = function(result, stats, weights, args)
        local statInfo = StatsModule:GetStatInfoByDisplayName(args["stat"]);
        if(not statInfo or not weights[statInfo.Alias]) then
            return;
        end

        local value = Utils.ToNumber(args["value"]);
        local duration = tonumber(args["duration"]);
        local cd = args["cd"]
        local cdmin = tonumber(cd:match(ScoreModule.Matcher.Partial["cdmin"]));
        local cdsec = tonumber(cd:match(ScoreModule.Matcher.Partial["cdsec"]) or 0);
        local cooldown = cdmin * 60 + cdsec;

        local uptime = duration / cooldown;
        local averageStatValue = uptime * value;

        UpdateResult(result, "Use", statInfo, averageStatValue, weights[statInfo.Alias]);
    end,
    ["bonusarmor"] = function(result, stats, weights, args)
        local armorKey = StatsModule:AliasToKey("armor");
        local value = tonumber(args["value"]);
        stats[armorKey] = stats[armorKey] - value;
        stats[StatsModule:AliasToKey("bonusarmor")] = value;
    end,
    ["insigniaofconquest"] = function(result, stats, weights, args)
        args["chance"] = 15;
        args["cd"] = 55;

        ScoreModule.Fx["icd"](result, stats, weights, args);
    end,
    ["soliumband"] = function(result, stats, weights, args)
        local primaryStat, primaryStatValue = GetPrimaryStatForSpec(weights);

        local buff = 0.1;
        if(args["type"] == L["Matcher_SoliumBand_BuffType_Greater"]) then
            buff = 0.15;
        end

        local statInfo = StatsModule:GetStatInfo(primaryStat);

        if(not statInfo)
        then
            return;
        end

        args["stat"] = statInfo.DisplayName;
        args["value"] = primaryStatValue * buff;

        ScoreModule.Fx["rppm"](result, stats, weights, args);
    end,
    ["blackhandtrinket"] = function(result, stats, weights, args)
        local overtimeValue = 0;
        local currentTick = 0;

        local duration = tonumber(args["duration"]);
        local tick = Utils.ToNumber(args["tick"]);
        local maxStack = tonumber(args["maxstack"]);
        local tickValue = tonumber(args["value"]);

        while(currentTick * tick < duration) do
            currentTick = currentTick + 1;
            if(currentTick < maxStack) then
                overtimeValue = overtimeValue + currentTick * tickValue;
            else
                overtimeValue = overtimeValue + maxStack * tickValue;
            end
        end

        args["value"] = overtimeValue / (duration / tick);

        ScoreModule.Fx["rppm"](result, stats, weights, args);
    end,
    ["stoneoffire"] = function(result, stats, weights, args)
        local primaryStat = GetPrimaryStatForSpec(weights);
        local statInfo = StatsModule:GetStatInfo(primaryStat);

        if(not statInfo)
        then
            return;
        end

        args["chance"] = 35;
        args["cd"] = 55;
        args["stat"] = statInfo.DisplayName;

        ScoreModule.Fx["icd"](result, stats, weights, args);
    end
};

function ScoreModule:CalculateItemScore(link, loc, tooltip, spec)
    local fixBonusArmor = StatWeightScore.db.profile.GetStatsMethod == "api";

    return self:CalculateItemScoreCore(link, loc, tooltip, spec, function()
        if(StatWeightScore.db.profile.GetStatsMethod == "tooltip") then
            return self:GetStatsFromTooltip(tooltip);
        else
            return GetStatsFromLink(link);
        end

    end, false, fixBonusArmor);
end

function ScoreModule:CalculateItemScoreCM(link, loc, tooltip, spec)
    if(tooltip == nil) then
        return nil
    end

    return self:CalculateItemScoreCore(link, loc, tooltip, spec, function()
        return self:GetStatsFromTooltip(tooltip);
    end, true, false);
end

function ScoreModule:CalculateItemScoreCore(link, loc, tooltip, spec, getStatsFunc, ignoreCm, fixBonusArmor)
    local weights = SpecModule:GetWeights(spec);
    local stats = getStatsFunc() or {};
    local secondaryStat = StatsModule:GetBestGemStat(spec);
    local locStr = getglobal(loc);
    local db = StatWeightScore.db.profile;

    local result = {
        Score = 0;
    };

    local socketStats = GetStatsFromLink(link) or {};

    if(not ignoreCm) then
        if(socketStats[StatsModule:AliasToKey("socket")]) then
            local _, gemLink = GetItemGem(link, 1);
            local enchantLevel;
            local gemStatWeight;
            local gemStat;
            local statValue;

            if(not db.ForceSelectedGemStat and gemLink) then
                local gemStats = self:GetStatsFromTooltip(ScanningTooltipModule:ScanTooltip(gemLink));
                for stat, value in pairs(gemStats) do
                    local alias = StatsModule:KeyToAlias(stat);
                    local weight = weights[alias];
                    if(weight) then
                        statValue = value;
                        gemStat = StatsModule:GetStatInfo(alias);
                        gemStatWeight = weight;
                    end
                end
            elseif(secondaryStat) then
                statValue = GemsModule:GetGemValue(db.EnchantLevel);
                gemStat = secondaryStat.Stat;
                gemStatWeight = secondaryStat.Weight;
            end

            if(gemStat) then
                result.Score = result.Score + statValue * gemStatWeight;
                result.Gem = {
                    Stat = gemStat.Alias;
                    Value = statValue;
                };
            end
        end
    end

    if((ignoreCm and locStr == INVTYPE_TRINKET) or (not ignoreCm and (locStr == INVTYPE_TRINKET or locStr == INVTYPE_FINGER or weights["bonusarmor"]))) then
        if(tooltip) then
            for l = 1,tooltip:NumLines() do
                local tooltipText = getglobal(tooltip:GetName().."TextLeft"..l);
                if(tooltipText) then
                    local line = (tooltipText:GetText() or "");

                    local precheck = false;
                    for _, preCheckPattern in ipairs(self.Matcher.PreCheck) do
                        if(line:match(preCheckPattern)) then
                            precheck = true;
                            break;
                        end
                    end

                    if(precheck) then
                        for _, matcher in pairs(self.Matcher.Matchers) do
                            if(matcher.Fx == "bonusarmor" and not fixBonusArmor) then
                            else
                                local match = Utils.Pack(line:match(matcher.Pattern));

                                if(match) then
                                    local argOrder = matcher.ArgOrder;
                                    local args = {};

                                    for i = 1, match.n do
                                        local argName = argOrder[i];
                                        local argValue = match[i]
                                        if(argName == "stat" and argValue:lower() == RESISTANCE0_NAME:lower()) then
                                            -- armor procs actually add bonus armor
                                            argValue = BONUS_ARMOR;
                                        end
                                        args[argName] = argValue;
                                    end

                                    self.Fx[matcher.Fx](result, stats, weights, args);
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if((locStr == INVTYPE_WEAPON  or (SpecModule:IsDualWielding2h() and locStr == INVTYPE_2HWEAPON)) and weights["wohdps"]) then
        result.Offhand = result.Score;
    end

    for stat, value in pairs(stats) do
        local alias = StatsModule:KeyToAlias(stat);
        local weight = weights[alias];
        if(weight) then
            if(result.Offhand ~= nil) then
                if(alias == "dps") then
                    result.Offhand = result.Offhand + value * weights["wohdps"];
                else
                    result.Offhand = result.Offhand + value * weight;
                end
            end

            result.Score = result.Score + value * weight;
        end
    end

    return result;
end