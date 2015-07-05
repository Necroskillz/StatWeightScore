local SWS_ADDON_NAME, StatWeightScore = ...;
local GemsModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Gems");

local L = StatWeightScore.L;

local GemRepository = {
    [1] = {
        Value = 35,
        Name = string.format(L["GemsDisplayFormat"], ITEM_QUALITY_COLORS[2].hex.."+35"..FONT_COLOR_CODE_CLOSE)
    },
    [2] = {
        Value = 50,
        Name = string.format(L["GemsDisplayFormat"], ITEM_QUALITY_COLORS[3].hex.."+50"..FONT_COLOR_CODE_CLOSE);
    },
    [3] = {
        Value = 75,
        Name = string.format(L["GemsDisplayFormat"], ITEM_QUALITY_COLORS[4].hex.."+75"..FONT_COLOR_CODE_CLOSE);
    }
};

function GemsModule:GetGems()
    return GemRepository;
end

function GemsModule:GetGemValue(enchantLevel)
    local gem = GemRepository[enchantLevel];
    if(gem) then
        return gem.Value;
    end

    return nil;
end