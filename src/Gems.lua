local SWS_ADDON_NAME, StatWeightScore = ...;
local GemsModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Gems");
local StatsModule;
local ItemLinkModule;

local L = StatWeightScore.L;

local GemRepository = {
    [1] = {
        Value = 30,
        Name = string.format(L["GemsDisplayFormat"], ITEM_QUALITY_COLORS[2].hex.."+30"..FONT_COLOR_CODE_CLOSE)
    },
    [2] = {
        Value = 40,
        Name = string.format(L["GemsDisplayFormat"], ITEM_QUALITY_COLORS[3].hex.."+40"..FONT_COLOR_CODE_CLOSE);
    }
--    [3] = {
--        Value = 50,
--        Name = string.format(L["GemsDisplayFormat"], ITEM_QUALITY_COLORS[4].hex.."+50"..FONT_COLOR_CODE_CLOSE);
--    }
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

    return 0;
end

local UniqueGemIds = {
    ["153707"] = 1,
    ["153708"] = 1,
    ["153709"] = 1,
};

function GemsModule:IsUniqueGem(gemLink)
    local parsedLink = ItemLinkModule:Parse(gemLink);

    return UniqueGemIds[parsedLink.itemId];
end

function GemsModule:GetEquippedUniqueGemSlot()
    for i = 0, 19 do
        local link = GetInventoryItemLink("player", i);
        if(link) then
            local stats = GetItemStats(link);
            if(stats and stats[StatsModule:AliasToKey("socket")]) then
                local _, gemLink = GetItemGem(link, 1);
                if(self:IsUniqueGem(gemLink)) then
                    local _, _, _, _, _, _, _, _, loc = GetItemInfo(link);

                    return getglobal(loc), i;
                end
            end
        end
    end

    return nil;
end