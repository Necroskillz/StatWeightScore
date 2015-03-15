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
        PreCheck = {
            L["Matcher_Precheck_Equip"],
            L["Matcher_Precheck_Use"],
            L["Matcher_Precheck_BonusArmor"]
        },
        Partial = {
            ["cdmin"] = L["Matcher_Partial_CdMin"],
            ["cdsec"] = L["Matcher_Partial_CdSec"]
        },
        Matchers = {
        }
    };

    self:RegisterMatcher("RPPM", "rppm");
    self:RegisterMatcher("SoliumBand", "soliumband");
    self:RegisterMatcher("ICD", "icd");
    self:RegisterMatcher("ICD2", "icd");
    self:RegisterMatcher("InsigniaOfConquest", "insigniaofconquest");
    self:RegisterMatcher("Use", "use");
    self:RegisterMatcher("Use2", "use");
    self:RegisterMatcher("BonusArmor", "bonusarmor");
    self:RegisterMatcher("BlackhandTrinket", "blackhandtrinket");
end

function ScoreModule:RegisterMatcher(name, fx)
    table.insert(self.Matcher.Matchers, {
        Pattern = L["Matcher_"..name.."_Pattern"],
        Fx = fx,
        ArgOrder = Utils.SplitString(L["Matcher_"..name.."_ArgOrder"])
    });
end

local function UpdateResult(result, type, stat, averageStatValue, weight)
    result.Score = result.Score + averageStatValue * weight
    result[type] = {
        AverageValue = averageStatValue;
        Stat = stat.DisplayName;
    };
end

local function GetStatsFromTooltip(tooltip)
    local stats = {};

    if(tooltip) then
        for l = 1,tooltip:NumLines() do
            local tooltipText = getglobal(tooltip:GetName().."TextLeft"..l);
            if(tooltipText) then
                local line = (tooltipText:GetText() or "");
                local value, stat;

                value, stat = line:match(L["Matcher_StatTooltipParser_Stat"]);
                if(not value) then
                    value, stat = line:match(L["Matcher_StatTooltipParser_Armor"]);
                end
                if(not value) then
                    value, stat = line:match(L["Matcher_StatTooltipParser_DPS"]);
                end

                if(value and stat) then
                    local statInfo = StatsModule:GetStatInfoByDisplayName(stat);
                    if(statInfo) then
                        stats[statInfo.Key] = tonumber(value);
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
        local primaryStat;
        local primaryStatValue = 0;

        for _, alias in ipairs({"str","agi","int"}) do
            local stat = StatsModule:GetStatInfo(alias);

            if(stats[stat.Key]) then
                primaryStatValue = UnitStat("player", primaryStatIndex[alias]);
                primaryStat = alias;
                break;
            end
        end

        local statInfo = StatsModule:GetStatInfo(primaryStat);

        args["stat"] = statInfo.DisplayName;
        args["value"] = primaryStatValue / 10;

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
    end
};

function ScoreModule:CalculateItemScore(link, loc, tooltip, spec)
    return self:CalculateItemScoreCore(link, loc, tooltip, spec, function()
        return GetStatsFromLink(link);
    end, false, true);
end

function ScoreModule:CalculateItemScoreCM(link, loc, tooltip, spec)
    if(tooltip == nil) then
        return nil
    end

    return self:CalculateItemScoreCore(link, loc, tooltip, spec, function()
        return GetStatsFromTooltip(tooltip);
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

    if(not ignoreCm) then
        if(stats[StatsModule:AliasToKey("socket")]) then
            local _, gemLink = GetItemGem(link, 1);
            local enchantLevel;
            local gemStatWeight;
            local gemStat;
            local statValue;

            if(not db.ForceSelectedGemStat and gemLink) then
                local gemStats = GetStatsFromTooltip(ScanningTooltipModule:ScanTooltip(gemLink));
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
                        for _, matcher in ipairs(self.Matcher.Matchers) do
                            if(matcher.Fx == "bonusarmor" and not fixBonusArmor) then
                            else
                                local match =  Utils.Pack(line:match(matcher.Pattern));

                                if(match) then
                                    local argOrder = matcher.ArgOrder;
                                    local args = {};

                                    for i = 1, match.n do
                                        local argName = argOrder[i];
                                        local argValue = match[i]
                                        if(argName == "stat" and argValue == RESISTANCE0_NAME) then
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

    if((locStr == INVTYPE_WEAPON) and weights["wohdps"]) then
        result.Offhand = 0;
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