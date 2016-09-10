local SWS_ADDON_NAME, StatWeightScore = ...;
local SpecModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Spec");

local StatsModule;
local Utils;

local WeightsCache = {};

function SpecModule:OnInitialize()
    StatsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Stats");
    Utils = StatWeightScore.Utils;

    self.db = StatWeightScore.db;

    self:RegisterMessage(SWS_ADDON_NAME.."ConfigChanged", "InvalidateWeightsCache");

    self:BuildWeightsCache();
end

function SpecModule:InvalidateWeightsCache()
    table.wipe(WeightsCache);
end

function SpecModule:GetSpecs()
    return self.db.profile.Specs;
end

function SpecModule:SetSpec(spec)
    self.db.profile.Specs[spec.Name] = spec;
end

function SpecModule:RemoveInvalidStats()
    local specs = self:GetSpecs();

    for _, spec in pairs(specs) do
        for stat, _ in pairs(spec.Weights) do
            local statInfo = StatsModule:GetStatInfo(stat);

            if(not statInfo) then
                Utils.PrintError(string.format("Found invalid stat %s in spec %s, removing", stat, spec.Name))
                spec.Weights[stat] = nil;
            end
        end

        self:SetSpec(spec);
    end
end

function SpecModule:BuildWeightsCache()
    local specs = self:GetSpecs();

    for name, spec in pairs(specs) do
        if(not spec.Normalize) then
            WeightsCache[name] = spec.Weights;
        else
            local normalized = {};
            local primaryStat, primaryWeight;

            for stat, weight in pairs(spec.Weights) do
                local statInfo = StatsModule:GetStatInfo(stat);

                if(not statInfo) then
                    self:RemoveInvalidStats();
                    self:InvalidateWeightsCache();
                    self:BuildWeightsCache();
                    return;
                end

                if(statInfo.Primary) then
                    primaryStat = stat;
                    primaryWeight = weight;
                    break;
                end
            end

            if(not primaryStat) then
                WeightsCache[name] = spec.Weights;
            else
                for stat, weight in pairs(spec.Weights) do
                    normalized[stat] = weight / primaryWeight;
                end

                WeightsCache[name] = normalized;
            end
        end
    end
end

function SpecModule:GetWeights(spec)
    if(not WeightsCache[spec.Name]) then
        self:BuildWeightsCache();
    end

    return WeightsCache[spec.Name] or {};
end

function SpecModule:IsDualWielding2h()
    return select(2, UnitClass("player")) == "WARRIOR" and GetSpecialization() == 2;
end

local primaryStatIndex = {
    ["str"] = 1,
    ["agi"] = 2,
    ["int"] = 4
};

function SpecModule:GetPrimaryStat(weights)
    local primaryStatValue, primaryStat, primaryStatWeight;

    for _, alias in ipairs({"str","agi","int"}) do
        if(weights[alias]) then
            primaryStatValue = UnitStat("player", primaryStatIndex[alias]);
            primaryStat = alias;
            primaryStatWeight = weights[alias];
            break;
        end
    end

    return primaryStat, primaryStatValue, primaryStatWeight;
end