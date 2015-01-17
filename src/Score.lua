local SWS_ADDON_NAME, StatWeightScore = ...;
local ScoreModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Score");

local StatsModule;
local GemsModule;

local Utils;

function ScoreModule:OnInitialize()
    StatsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Stats");
    GemsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Gems");
    Utils = StatWeightScore.Utils;
    local L = StatWeightScore.L;

    self.Regex = L["Tooltip_Regex"];
end

local updateResult = function(result, type, stat, averageStatValue, weight)
    result.Score = result.Score + averageStatValue * weight
    result[type] = {
        AverageValue = averageStatValue;
        Stat = stat.DisplayName;
    };
end;

local primaryStatIndex = {
    [1] = "str",
    [2] = "agi",
    [4] = "int"
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

        updateResult(result, "Proc", statInfo, averageStatValue, weights[statInfo.Alias]);
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

        updateResult(result, "Proc", statInfo, averageStatValue, weights[statInfo.Alias]);
        end,
    ["use"] = function(result, stats, weights, args)
        local statInfo = StatsModule:GetStatInfoByDisplayName(args["stat"]);
        if(not statInfo or not weights[statInfo.Alias]) then
            return;
        end

        local value = Utils.ToNumber(args["value"]);
        local duration = tonumber(args["duration"]);
        local cd = args["cd"]
        local cdmin = tonumber(cd:match(ScoreModule.Regex.Partial["cdmin"]));
        local cdsec = tonumber(cd:match(ScoreModule.Regex.Partial["cdsec"]) or 0);
        local cooldown = cdmin * 60 + cdsec;

        local uptime = duration / cooldown;
        local averageStatValue = uptime * value;

        updateResult(result, "Use", statInfo, averageStatValue, weights[statInfo.Alias]);
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

        for _, i in ipairs({1,2,4}) do
            local value = UnitStat("player", i);
            if(value > primaryStatValue) then
                primaryStatValue = value;
                primaryStat = i;
            end
        end

        local statInfo = StatsModule:GetStatInfo(primaryStatIndex[primaryStat]);
        if(not statInfo) then
            return
        end

        args["stat"] = statInfo.DisplayName;
        args["value"] = primaryStatValue / 10;

        ScoreModule.Fx["rppm"](result, stats, weights, args);
    end
};

function ScoreModule:CalculateItemScore(link, loc, tooltip, spec)
    local weights = spec.Weights;
    local stats = GetItemStats(link);
    local secondaryStat = StatsModule:GetBestGemStat(spec);
    local locStr = getglobal(loc);
    local db = StatWeightScore.db.profile;

    local result = {
        Score = 0;
    };

    if(stats[StatsModule:AliasToKey("socket")]) then
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
                local statInfo = StatsModule:GetStatInfo(stat);
                if(statInfo.Gem and string.find(gemName, statInfo.DisplayName)) then
                    gemStatWeight = weight;
                    gemStat = statInfo;
                end
            end
        elseif(secondaryStat) then
            enchantLevel = db.EnchantLevel;
            gemStatWeight = secondaryStat.Weight;
            gemStat = secondaryStat.Stat;
        end

        if(gemStat) then
            local statValue = GemsModule:GetGemValue(enchantLevel);
            result.Score = result.Score + statValue * gemStatWeight;
            result.Gem = {
                Stat = gemStat.Alias;
                Value = statValue;
            };
        end
    end

    if(locStr == INVTYPE_TRINKET or locStr == INVTYPE_FINGER or weights["bonusarmor"]) then
        if(tooltip) then
            for l = 1,tooltip:NumLines() do
                local tooltipText = getglobal(tooltip:GetName().."TextLeft"..l);
                if(tooltipText) then
                    local line = (tooltipText:GetText() or ""):lower();

                    local precheck = false;
                    for _, preCheckPattern in ipairs(self.Regex.PreCheck) do
                        if(line:match(preCheckPattern)) then
                            precheck = true;
                            break;
                        end
                    end

                    if(precheck) then
                        for _, matcher in ipairs(self.Regex.Matchers) do
                            local match =  Utils.Pack(line:match(matcher.Pattern));

                            if(match) then
                                local argOrder = matcher.ArgOrder;
                                local args = {};

                                for i = 1, match.n do
                                    args[argOrder[i]] = match[i];
                                end

                                self.Fx[matcher.Fx](result, stats, weights, args);
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