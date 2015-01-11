local SWS_ADDON_NAME, StatWeightScore = ...;
local ScoreModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Score");

local StatsModule;
local GemsModule;

function ScoreModule:OnInitialize()
    StatsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Stats");
    GemsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Gems");
end

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

    -- Use: Increases your <stat> by <value> for <dur> sec. (<cd> Min Cooldown)
    -- Use: Increases <stat> by <value> for <dur> sec. (<cdm> Min <cds> Sec Cooldown)
    -- Use: Grants <value> <stat> for <dur> sec. (<cdm> Min <cds> Sec Cooldown)
    -- Equip: Your attacks have a chance to grant <value> <stat> for <dur> sec.  (Approximately <procs> procs per minute)
    -- Equip: Each time your attacks hit, you have a chance to gain <value> <stat> for <dur> sec. (<chance>% chance, <cd> sec cooldown)
    -- +<value> Bonus Armor

    if((locStr == INVTYPE_TRINKET) or weights["bonusarmor"]) then
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
                            statInfo = StatsModule:GetStatInfoByDisplayName(stat);
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
                            statInfo = StatsModule:GetStatInfoByDisplayName(stat);
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
                            statInfo = StatsModule:GetStatInfoByDisplayName(stat);
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
                            local armorKey = StatsModule:AliasToKey("armor");
                            stats[armorKey] = stats[armorKey] - value;
                            stats[StatsModule:AliasToKey("bonusarmor")] = value;
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