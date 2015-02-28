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

    self:AddToStatsPane();

    self:RegisterMessage(SWS_ADDON_NAME.."ConfigChanged", "UpdateStatCategory");

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

function CharacterModule:UpdateStatCategory()
    self:InvalidateScoreCache();

    if(StatWeightScore.db.profile.ShowStatsPane) then
        self:AddToStatsPane();
    else
        PAPERDOLL_STATCATEGORIES[SWS_ADDON_NAME] = nil;
        for i, k in pairs(PAPERDOLL_STATCATEGORY_DEFAULTORDER) do
            if(k == SWS_ADDON_NAME) then
                table.remove(PAPERDOLL_STATCATEGORY_DEFAULTORDER, i);
                break;
            end
        end

        return;
    end

    local category = PAPERDOLL_STATCATEGORIES[SWS_ADDON_NAME];
    table.wipe(category.stats);

    for key, _ in pairs(PAPERDOLL_STATINFO) do
        if(string.find(key, SWS_ADDON_NAME)) then
            PAPERDOLL_STATINFO[key] = nil;
        end
    end

    local specs = SpecModule:GetSpecs();

    for _, specKey in ipairs(Utils.OrderKeysBy(specs, "Order")) do
        local spec = specs[specKey];
        local key = SWS_ADDON_NAME..spec.Name;

        PAPERDOLL_STATINFO[key] = {
            updateFunc = function(statFrame, unit)
                local score = self:CalculateTotalScore(spec);
                local color = "";

                -- not correct in CM
                if(select(3, GetInstanceInfo()) == 8) then
                    color = GRAY_FONT_COLOR_CODE;
                    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..L["Warning"];
                    statFrame.tooltip2 = L["CharacterPane_CM_Tooltip"];
                else
                    statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..L["CharacterPane_Tooltip_Title"];
                    statFrame.tooltip2 = string.format(L["CharacterPane_Tooltip_Title_Text"], spec.Name);
                end

                PaperDollFrame_SetLabelAndText(statFrame, L["TooltipMessage_StatScore"].." ("..spec.Name..")", color..string.format("%.2f", score), false);
            end
        };

        table.insert(category.stats, key);
    end
end

function CharacterModule:AddToStatsPane()
    if(not StatWeightScore.db.profile.ShowStatsPane or PAPERDOLL_STATCATEGORIES[SWS_ADDON_NAME]) then
        return;
    end

    local lastId = -1;

    for _, cat in pairs(PAPERDOLL_STATCATEGORIES) do
        if(cat.id > lastId) then
            lastId = cat.id;
        end
    end

    local category = {
        id = lastId + 1,
        stats = {
        }
    };

    PAPERDOLL_STATCATEGORIES[SWS_ADDON_NAME] = category;
    table.insert(PAPERDOLL_STATCATEGORY_DEFAULTORDER, 2, SWS_ADDON_NAME);

    self:UpdateStatCategory();

    local frameName = "CharacterStatsPaneCategory"..category.id;
    if(not getglobal(frameName)) then
        _G["STAT_CATEGORY_"..SWS_ADDON_NAME] = L["StatPaneCategoryTitle"];
        CreateFrame("Frame", frameName, CharacterStatsPaneScrollChild, "StatGroupTemplate");
    end
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