local SWS_ADDON_NAME, StatWeightScore = ...;
local GemsModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Gems");
local StatsModule;
local ItemLinkModule;

local L = StatWeightScore.L;

local GemRepository = {
    [1] = {
        Value = 150,
        Name = string.format(L["GemsDisplayFormat"], ITEM_QUALITY_COLORS[2].hex.."+150"..FONT_COLOR_CODE_CLOSE)
    },
    [2] = {
        Value = 200,
        Name = string.format(L["GemsDisplayFormat"], ITEM_QUALITY_COLORS[3].hex.."+200"..FONT_COLOR_CODE_CLOSE);
    }
};

function GemsModule:OnInitialize()
    StatsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Stats");
    ItemLinkModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ItemLink");
end

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

local SabersEye = {
    ["130246"] = 1,
    ["130247"] = 1,
    ["130248"] = 1,
};

function GemsModule:IsSabersEyeEquipped()
    for i = 0, 19 do
        local link = GetInventoryItemLink("player", i);
        if(link) then
            local stats = GetItemStats(link);
            if(stats[StatsModule:AliasToKey("socket")]) then
                local _, gemLink = GetItemGem(link, 1);
                local link = ItemLinkModule:Parse(gemLink);
                if(SabersEye[link.itemId]) then
                    return true;
                end
            end
        end
    end

    return false;
end