local SWS_ADDON_NAME, StatWeightScore = ...;
local CharacterModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Character");

local ScoreModule;
local SpecModule;
local ScanningTooltipModule;

local L;
local Utils;

local ScoreCache = {};

function CharacterModule:OnInitialize()
    ScoreModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Score");
    SpecModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Spec");
    ScanningTooltipModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ScanningTooltip");
    L = StatWeightScore.L;
    Utils = StatWeightScore.Utils;

    local eventFrame = CreateFrame("Frame");
    eventFrame:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player");
    eventFrame:RegisterUnitEvent("UNIT_AURA", "player");
    eventFrame:RegisterUnitEvent("UNIT_STATS", "player");
    eventFrame:RegisterUnitEvent("UNIT_SPELL_HASTE", "player");

    eventFrame:SetScript("OnEvent", function()
        self:InvalidateScoreCache();
    end)
end

function CharacterModule:InvalidateScoreCache()
    table.wipe(ScoreCache);
end

function CharacterModule:GetCharacterScores()
    local specs = SpecModule:GetSpecs();
    local scores = {};

    for _, specKey in ipairs(Utils.OrderKeysBy(specs, "Order")) do
        local spec = specs[specKey];

        local score = {
            Score = self:CalculateTotalScore(spec),
            Spec = spec.Name
        };

        table.insert(scores, score);
    end

    return scores;
end

function CharacterModule:CalculateTotalScore(spec)
    if(ScoreCache[spec.Name]) then
        return ScoreCache[spec.Name]
    end

    local specScore = 0;

    for i = 0, 19 do
        local link = GetInventoryItemLink("player", i);
        if(link) then
            local _, _, _, _, _, _, _, _, loc = GetItemInfo(link);
            local score = ScoreModule:CalculateItemScore(link, loc, ScanningTooltipModule:ScanTooltip(link), spec);
            if(score) then
                if(i == 17 and score.Offhand) then
                    specScore = specScore + score.Offhand;
                else
                    specScore = specScore + score.Score;
                end
            end
        end
    end

    ScoreCache[spec.Name] = specScore;
    return specScore;
end