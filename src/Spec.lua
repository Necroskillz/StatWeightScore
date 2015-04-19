local SWS_ADDON_NAME, StatWeightScore = ...;
local SpecModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Spec");

local StatsModule;

local WeightsCache = {};

function SpecModule:OnInitialize()
    StatsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Stats");

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