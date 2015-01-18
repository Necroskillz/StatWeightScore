local SWS_ADDON_NAME, StatWeightScore = ...;
local ImportExportModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."ImportExport");

local XmlModule;
local StatsModule;

local Utils;

ImportExportModule.ImportTypes = {};
ImportExportModule.ExportTypes = {};

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

            if(StatsModule:GetStatInfo(alias)) then
                result[alias] = tonumber(e.xarg.value);
            else
                error("Unknown stat "..statName);
            end

        end
    end

    return result;
end

local function importAskMrRobotShare(input)
    local matches = input:gmatch("(%w+)%s+([%d%.]+)");
    local result = {};
    local matched = false;
    local map = createAmrMaps();

    for stat, weight in matches do
        matched = true;
        local alias = map[stat];

        if(StatsModule:GetStatInfo(alias)) then
            result[alias] = tonumber(weight);
        else
            error("Unknown stat "..stat);
        end
    end

    if(not matched) then
        error("Found no stat to import")
    end

    return result;
end

local function exportAskMrRobotShare(spec)
    local result = "";
    local _, map = createAmrMaps();

    for _, alias in ipairs(Utils.SortedKeys(spec.Weights, function (key1, key2)
        return spec.Weights[key1] > spec.Weights[key2];
    end)) do
        local stat = map[alias];
        result = result..stat.." "..spec.Weights[alias].."\n";
    end

    return result;
end

function ImportExportModule:OnInitialize()
    XmlModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Xml");
    StatsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Stats");
    Utils = StatWeightScore.Utils;

    self:RegisterDefaultImportExport();
end

function ImportExportModule:RegisterImport(key, importTitle, importFunc)
    self.ImportTypes[key] = importTitle;
    importers[key] = importFunc;
end

function ImportExportModule:RegisterExport(key, exportTitle, exportFunc)
    self.ExportTypes[key] = exportTitle;
    exporters[key] = exportFunc;
end

function ImportExportModule:Import(importType, input)
    return importers[importType](input);
end

function ImportExportModule:Export(exportType, spec)
    return exporters[exportType](spec);
end

function ImportExportModule:RegisterDefaultImportExport()
    self:RegisterImport("sim", "SimulationCraft xml", importSimulationCraftXML);
    self:RegisterImport("amr", "Ask Mr. Robot share", importAskMrRobotShare);

    self:RegisterExport("amr", "Ask Mr. Robot share", exportAskMrRobotShare);
end