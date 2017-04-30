local SWS_ADDON_NAME, StatWeightScore = ...;
local SimcModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Simc");

local ItemModule;

local Utils;

function SimcModule:OnInitialize()
    ItemModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Item");
    Utils = StatWeightScore.Utils;
end

function SimcModule:GenerateTrinketCombos(fixed)
    local combos = {};
    local trinketMap = {};

    local insertUniqueTrinket = function (itemLink)
        if(itemLink == nil) then
            return
        end

        local parsedLink = ItemModule:GetItemLinkInfo(itemLink);

        local hasGem = parsedLink.gem1Id ~= "0" and 'g' or '';
        local key = parsedLink.itemId..hasGem;

        if(trinketMap[key] == nil) then
            trinketMap[key] = parsedLink;
            return;
        end

        local _, _, _, newItemIlvl = GetItemInfo(parsedLink:ToString());
        local _, _, _, existingItemIlvl = GetItemInfo(trinketMap[key]:ToString());

        if(newItemIlvl > existingItemIlvl) then
            trinketMap[key] = parsedLink;
        end
    end

    insertUniqueTrinket(GetInventoryItemLink("player", ItemModule.SlotMap["INVTYPE_TRINKET"][1]));
    insertUniqueTrinket(GetInventoryItemLink("player", ItemModule.SlotMap["INVTYPE_TRINKET"][2]));

    for bag=0, NUM_BAG_SLOTS do
        for bagSlot=1, GetContainerNumSlots(bag) do
            local itemlink = GetContainerItemLink(bag, bagSlot)
            if (itemlink) then
                local _, _, _, _, _, _, _, _, loc = GetItemInfo(itemlink)
                local locStr = getglobal(loc);

                if(locStr == INVTYPE_TRINKET) then
                    insertUniqueTrinket(itemlink);
                end
            end
        end
    end

    local trinkets = {};

    for _, trinket in pairs(trinketMap) do
        if(trinket.itemId == "144259" and trinket.itemId ~= fixed) then
            -- skip KJ unless its fixed
        else
            table.insert(trinkets, trinket);
        end
    end

    local combinations = {};

    for i, trinket1 in ipairs(trinkets) do
        for j = i + 1, #trinkets do
            local trinket2 = trinkets[j];

            table.insert(combinations, { trinket1, trinket2 });
        end
    end

    if(fixed ~= "") then
        local filtered = {};

        for _, combo in pairs(combinations) do
            if(combo[1].itemId == fixed or combo[2].itemId == fixed) then
                table.insert(filtered, combo);
            end
        end

        combinations = filtered;
    end

    for _, combo in pairs(combinations) do
        local link1 = combo[1];
        local link2 = combo[2];

        local _, _, _, item1Ilvl = GetItemInfo(link1:ToString());
        local _, _, _, item2Ilvl = GetItemInfo(link2:ToString());

        local text1 = link1.text.."("..item1Ilvl..")";
        local text2 = link2.text.."("..item2Ilvl..")";
        local title;

        if(fixed == "") then
            title = text1.."+"..text2;
        else
            title = link1.itemId == fixed and text2 or text1;
        end

        local title = gsub("copy="..title, " ", "_");

        table.insert(combos, {
            title = title,
            trinket1 = string.format("trinket1=%s", link1:ToSimC()),
            trinket2 = string.format("trinket2=%s", link2:ToSimC()),
        });
    end

    return combos;
end
