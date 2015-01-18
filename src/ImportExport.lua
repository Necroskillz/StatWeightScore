local SWS_ADDON_NAME, StatWeightScore = ...;
local ImportExportModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."ImportExport");

local XmlModule;

local importers = {};
local exporters = {};

local function createAmrMaps()
    local askMrRobotStatMap = {};
    local reverseAskMrRobotStatMap = {};

    local map = function (from, to)
        askMrRobotStatMap[from] = to;
        reverseAskMrRobotStatMap[to] = from;
    end

    map("MainHandDps", "dps");
    map("OffHandDps", "wohdps");
    map("Agility", "agi");
    map("Intellect", "int");
    map("Stamina", "sta");
    map("Spirit", "spi");
    map("Strength", "str");
    map("Mastery", "mastery");
    map("Armor", "armor");
    map("BonusArmor", "bonusarmor");
    map("CriticalStrike", "crit");
    map("AttackPower", "ap");
    map("SpellPower", "sp");
    map("Haste", "haste");
    map("Multistrike", "multistrike");
    map("Versatility", "versatility");

    return askMrRobotStatMap, reverseAskMrRobotStatMap;
end

local function importSimulationCraftXML(input)
    local result = {};
    local x = XmlModule:Parse(input);

    local simulationCraftStatMap = {
        ["Wdps"] = "dps",
        ["Mult"] = "multistrike",
        ["Vers"] = "versatility",
    };

    local root = x[1];
    if(root.label ~= "weights") then
        error("Couldn't find root element 'weights' in the xml");
    end

    for _, e in ipairs(root) do
        if(e.label == "stat") then
            local statName = e.xarg.name;
            local alias = simulationCraftStatMap[statName] or statName:lower();
            result[alias] = tonumber(e.xarg.value);
        end
    end

    return result;
end

local function importAskMrRobotShare(input)
    local matches = input:gmatch("(%w+)%s+([%d%.]+)");
    local result = {};
    local map = createAmrMaps();

    for stat, weight in matches do
        local alias = map[stat] or stat:lower();
        result[alias] = tonumber(weight);
    end

    return result;
end

local function exportAskMrRobotShare(spec)
    local result = "";
    local _, map = createAmrMaps();

    for alias, weight in pairs(spec.Weights) do
        local stat = map[alias];
        result = result..stat.." "..weight.."\n";
    end

    return result;
end

function ImportExportModule:OnInitialize()
    XmlModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Xml");

    importers["sim"] = importSimulationCraftXML;
    importers["amr"] = importAskMrRobotShare;

    exporters["amr"] = exportAskMrRobotShare;
end

function ImportExportModule:Import(importType, input)
    return importers[importType](input);
end

function ImportExportModule:Export(exportType, spec)
    return exporters[exportType](spec);
end