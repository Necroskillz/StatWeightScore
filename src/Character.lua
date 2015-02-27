local SWS_ADDON_NAME, StatWeightScore = ...;
local CharacterModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Character");

local ScoreModule;
local SpecModule;
local ItemModule;
local ScanningTooltipModule;

local L;
local Utils;

local ScoreCache = {};

function CharacterModule:OnInitialize()
    ScoreModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Score");
    SpecModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Spec");
    ItemModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Item");
    ScanningTooltipModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ScanningTooltip");
    L = StatWeightScore.L;
    Utils = StatWeightScore.Utils;

    self:AddToStatsPane();

    self:RegisterMessage(SWS_ADDON_NAME.."ConfigChanged", "UpdateStatCategory");
end

function CharacterModule:UpdateStatCategory()
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
    local category = {
        id = 846684247, -- hopefully unique
        stats = {
        }
    };

    PAPERDOLL_STATCATEGORIES[SWS_ADDON_NAME] = category;

    self:UpdateStatCategory();

    table.insert(PAPERDOLL_STATCATEGORY_DEFAULTORDER, 2, SWS_ADDON_NAME);
    _G["STAT_CATEGORY_"..SWS_ADDON_NAME] = L["StatPaneCategoryTitle"];

    CreateFrame("Frame", "CharacterStatsPaneCategory"..category.id, CharacterStatsPaneScrollChild, "StatGroupTemplate")
end

function CharacterModule:CalculateTotalScore(spec)
    local specScore = 0;

    for i = 0, 19 do
        local link = GetInventoryItemLink("player", i);
        if(link) then
            local _, _, _, _, _, _, _, _, loc = GetItemInfo(link);
            local score = ScoreModule:CalculateItemScore(link, loc, ScanningTooltipModule:ScanTooltip(link), spec);
            if(score) then
                specScore = specScore + score.Score;
            end
        end
    end

    return specScore;
end