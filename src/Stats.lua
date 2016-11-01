local SWS_ADDON_NAME, StatWeightScore = ...;
local StatsModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Stats");

local SpecModule;

local L;
local Utils;

local StatRepository = {};
local StatAliasMap = {};

local function AddAlias(alias, key)
    StatAliasMap[alias] = key;
    StatAliasMap[key] = alias;
end

local function AddStat(alias, key, options)
    options = options or {};
    AddAlias(alias, key);
    StatRepository[key] = {
        Key = key,
        Alias = alias,
        DisplayName = options.DisplayName or getglobal(key),
        Gem = not not options.Gem,
        Primary = not not options.Primary,
        AltDisplayNames = options.AltDisplayNames and Utils.SplitString(options.AltDisplayNames, "[^,]+") or {};
    };
end

function StatsModule:OnInitialize()
    SpecModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Spec");
    L = StatWeightScore.L;
    Utils = StatWeightScore.Utils;

    AddStat("dps", "ITEM_MOD_DAMAGE_PER_SECOND_SHORT");
    AddStat("wohdps", "OFFHAND_DPS", { DisplayName = L["Offhand_DPS"]});

    AddStat("agi", "ITEM_MOD_AGILITY_SHORT", { Primary = true });
    AddStat("int", "ITEM_MOD_INTELLECT_SHORT", { Primary = true });
    AddStat("sta", "ITEM_MOD_STAMINA_SHORT");
    AddStat("str", "ITEM_MOD_STRENGTH_SHORT", { Primary = true });
    AddStat("mastery", "ITEM_MOD_MASTERY_RATING_SHORT", { Gem = true });

    AddStat("armor", "RESISTANCE0_NAME");

    AddStat("ap", "ITEM_MOD_ATTACK_POWER_SHORT");
    AddStat("crit", "ITEM_MOD_CRIT_RATING_SHORT", { Gem = true, AltDisplayNames = L["AlternativeStatDisplayNames_Crit"] });
    AddStat("haste", "ITEM_MOD_HASTE_RATING_SHORT", { Gem = true });
    AddStat("versatility", "ITEM_MOD_VERSATILITY", { Gem = true });

    AddStat("avoidance", "ITEM_MOD_CR_AVOIDANCE_SHORT");
    AddStat("leech", "ITEM_MOD_CR_LIFESTEAL_SHORT");
    AddStat("speed", "ITEM_MOD_CR_SPEED_SHORT");

    AddAlias("socket", "EMPTY_SOCKET_PRISMATIC");

    local order = 10;
    for _, statKey in ipairs(Utils.OrderKeysBy(StatRepository, "DisplayName")) do
        StatRepository[statKey].Order = order;
        order = order + 10;
    end
end

function StatsModule:GetStats()
    return StatRepository;
end

function StatsModule:GetStatInfo(key)
    if(StatRepository[key]) then
        return StatRepository[key];
    elseif(StatAliasMap[key]) then
        local alias = StatAliasMap[key];
        return StatRepository[alias];
    end

    return nil;
end

function StatsModule:AliasToKey(alias)
    return StatAliasMap[alias];
end

function StatsModule:KeyToAlias(key)
    return StatAliasMap[key];
end

function StatsModule:GetStatInfoByDisplayName(displayName)
    displayName = displayName:lower();

    for _, stat in pairs(StatRepository) do
        if(stat.DisplayName:lower() == displayName) then
            return stat;
        end

        for _, altName in pairs(stat.AltDisplayNames) do
            if(altName:lower() == displayName) then
                return stat;
            end
        end
    end
end

function StatsModule:GetBestGemStat(spec)
    local bestStat;
    local bestStatWeight = 0;
    local weights = SpecModule:GetWeights(spec);

    if(not spec.GemStat or spec.GemStat == "best") then
        for stat, weight in pairs(weights) do
            local statInfo = self:GetStatInfo(stat);
            if(statInfo and statInfo.Gem) then
                if(weight > bestStatWeight) then
                    bestStatWeight = weight;
                    bestStat = statInfo;
                end
            end
        end
    else
        bestStat = self:GetStatInfo(spec.GemStat);
        bestStatWeight = weights[spec.GemStat];
    end

    return {
        Stat = bestStat;
        Weight = bestStatWeight;
    };
end