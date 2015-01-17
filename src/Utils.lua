local SWS_ADDON_NAME, StatWeightScore = ...;
local Utils = {};

local L = StatWeightScore.L;

StatWeightScore.Utils = Utils;

Utils.SortedKeys = function(t, sortFunction)
    local keys, len = {}, 0;
    for k,_ in pairs(t) do
        len = len + 1;
        keys[len] = k;
    end

    table.sort(keys, sortFunction);
    return keys;
end;

Utils.OrderKeysBy = function(array, property)
    return Utils.SortedKeys(array, function(key1, key2)
        return array[key1][property] < array[key2][property];
    end)
end;

Utils.ToNumber = function(s)
    if(type(s) == "number") then
        return s
    end

    s = s:gsub(L["ThousandSeparator"], ""):gsub(L["DecimalSeparator"], ".");

    return tonumber(s);
end;

Utils.Pack = function(...)
    if(... == nil) then
        return nil
    end

    return { n = select("#", ...), ... };
end;

Utils.Print = function(text)
    if(text == nil) then
        text = "-nil-";
    end

    if(type(text) == "table") then
        print(SWS_ADDON_NAME.." (table):")
        for i,v in pairs(text) do
            print(i.." : "..tostring(v));
        end
    else
        print(SWS_ADDON_NAME..": "..tostring(text));
    end
end;