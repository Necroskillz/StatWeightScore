local SWS_ADDON_NAME, StatWeightScore = ...;
local ScanningTooltipModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."ScanningTooltip");

local ScanningTooltip;

function ScanningTooltipModule:OnInitialize()
    ScanningTooltip = CreateFrame("GameTooltip", "StatWeightScore_ScanningTooltip", nil, "GameTooltipTemplate");
end


function ScanningTooltipModule:ScanTooltip(link)
    ScanningTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
    ScanningTooltip:SetHyperlink(link);

    return ScanningTooltip;
end