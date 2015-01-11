local SWS_ADDON_NAME, StatWeightScore = ...;
local GemsModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Gems");

local L = StatWeightScore.L;

local GemRepository = {
    [1] = {
        Value = 35,
        Name = string.format(L["GemsDisplayFormat"], "+35");
    },
    [2] = {
        Value = 50,
        Name = string.format(L["GemsDisplayFormat"], "+50");
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