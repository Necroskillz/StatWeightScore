local SWS_ADDON_NAME, StatWeightScore = ...;
local GemsModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Gems");
local StatsModule;
local ItemLinkModule;

local L = StatWeightScore.L;

local GemRepository = {
    [1] = {
        Value = 100,
        Name = string.format(L["GemsDisplayFormat"], ITEM_QUALITY_COLORS[2].hex.."+100"..FONT_COLOR_CODE_CLOSE)
    },
    [2] = {
        Value = 150,
        Name = string.format(L["GemsDisplayFormat"], ITEM_QUALITY_COLORS[3].hex.."+150"..FONT_COLOR_CODE_CLOSE);
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

    return 0;
end

local SabersEye = {
    ["130246"] = 1,
    ["130247"] = 1,
    ["130248"] = 1,
};

function GemsModule:IsSabersEye(gemLink)
    local parsedLink = ItemLinkModule:Parse(gemLink);

    return SabersEye[parsedLink.itemId];
end

function GemsModule:GetEquippedSabersEyeSlot()
    for i = 0, 19 do
        local link = GetInventoryItemLink("player", i);
        if(link) then
            local stats = GetItemStats(link);
            if(stats and stats[StatsModule:AliasToKey("socket")]) then
                local _, gemLink = GetItemGem(link, 1);
                if(self:IsSabersEye(gemLink)) then
                    local _, _, _, _, _, _, _, _, loc = GetItemInfo(link);

                    return getglobal(loc), i;
                end
            end
        end
    end

    return nil;
end