local SWS_ADDON_NAME, StatWeightScore = ...;
local Utils = {};

StatWeightScore.Utils = Utils;

Utils.SortedKeys = function(t, sortFunction)
    local keys, len = {}, 0;
    for k,_ in pairs(t) do
        len = len + 1;
        keys[len] = k;
    end

    table.sort(keys, sortFunction);
    return keys;
end


Utils.Print = function(text)
    if(text == nil) then
        text = "-nil-";
    end

    if(type(text) == "table") then
        print("StatWeightScore (table):")
        for i,v in pairs(text) do
            print(i.." : "..tostring(v));
        end
    else
        print("StatWeightScore: "..tostring(text));
    end
end