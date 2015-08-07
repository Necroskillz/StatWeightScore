local SWS_ADDON_NAME, StatWeightScore = ...;
local ImportExportModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."ImportExport");

local XmlModule;
local StatsModule;

local Utils;

ImportExportModule.ImportTypes = {};
ImportExportModule.ExportTypes = {};

local Importers = {};
local Exporters = {};

local function CreateAmrMaps()
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
    map("Avoidance", "avoidance");
    map("Leech", "leech");
    map("MovementSpeed", "none");

    return askMrRobotStatMap, reverseAskMrRobotStatMap;
end

local function CreatePawnMap()
    local pawnMap = {};

    local map = function (from, to)
        pawnMap[from] = to;
    end

    map("Dps", "dps");
    map("Agility", "agi");
    map("Intellect", "int");
    map("Stamina", "sta");
    map("Spirit", "spi");
    map("Strength", "str");
    map("MasteryRating", "mastery");
    map("Armor", "armor");
    map("BonusArmor", "bonusarmor");
    map("CritRating", "crit");
    map("Ap", "ap");
    map("SpellPower", "sp");
    map("HasteRating", "haste");
    map("Multistrike", "multistrike");
    map("Versatility", "versatility");
    map("Avoidance", "avoidance");
    map("Leech", "leech");

    return pawnMap;
end

local function ImportSimulationCraftXML(input)
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

local function ImportAskMrRobotShare(input)
    local parsed = {};
    local current, stage, f;
    local count = 0;
    local len = #input;

    for c in input:gmatch(".") do
        count = count + 1;
        if(current == nil) then
            current = {
                Name = ""
            };
            stage = "name";
        end

        if(stage == "name") then
            if(c == " ") then
                if(parsed[current.Name]) then
                    current = parsed[current.Name];
                    stage = "capc"
                else
                    if(current.Name == "set") then
                        stage = "set";
                    else
                        parsed[current.Name] = current;

                        stage = "wait";
                    end
                end
            else
                current.Name = current.Name..c;
            end
        elseif(stage == "wait") then
            if(c == "<") then
                current.Cap = "";
                stage = "cap";
            elseif(c:match("%d")) then
                current.Value = c;
                stage = "value";
            end
        elseif(stage == "cap") then
            if(c == "%") then
                current.Cap = tonumber(current.Cap);
                stage = "wait";
            else
                current.Cap = current.Cap..c;
            end
        elseif(stage == "value" or stage == "valuepc") then
            local field;
            if(stage == "valuepc") then
                field = "ValuePostCap";
            else
                field = "Value";
            end

            if(c == "\n" or count == len) then
                if(count == len) then
                    current[field] = current[field]..c;
                end

                current[field] = tonumber(current[field]);
                current = nil;
                stage = "name";
            else
                current[field] = current[field]..c;
            end
        elseif(stage == "capc") then
            if(c == "+") then
                f = true;
            elseif(f and c:match("%d")) then
                f = false;
                current.ValuePostCap = c;
                stage = "valuepc";
            end
        elseif(stage == "set") then
            -- ignore this
            if(c == "\n") then
                current = nil;
                stage = "name";
            end
        end
    end

    local matched = false;
    local result = {};
    local map = CreateAmrMaps();

    for _, stat in pairs(parsed) do
        matched = true;
        local alias = map[stat.Name];

        if(alias ~= "none") then
            if(StatsModule:GetStatInfo(alias)) then
                result[alias] = stat.Value;
            else
                error("Unknown stat "..stat.Name);
            end
        end
    end

    if(not matched) then
        error("Found no stat to import")
    end

    return result;
end

local function ExportAskMrRobotShare(spec)
    local result = "";
    local _, map = CreateAmrMaps();

    for _, alias in ipairs(Utils.SortedKeys(spec.Weights, function (key1, key2)
        return spec.Weights[key1] > spec.Weights[key2];
    end)) do
        local stat = map[alias];
        result = result..stat.." "..Utils.FormatNumber(spec.Weights[alias], 2).."\n";
    end

    return result;
end

local function ImportPawnString(input)
    local valuesString = input:match("^%s*%(%s*Pawn%s*:%s*v%d+%s*:%s*\"[^\"]+\"%s*:%s*(.+)%s*%)%s*$");

    if(not valuesString or valuesString == "") then
        error("Input sting is not a valid Pawn string");
    end

    local values = Utils.SplitString(valuesString, "[^,]+");
    local result = {};
    local map = CreatePawnMap();

    for _, valuePair in pairs(values) do
        local stat, value = valuePair:match("^%s*([%a%d]+)%s*=%s*(%-?[%d%.]+)%s*$");
        if(not stat or not value) then
            error("Invalid Pawn string format");
        end

        value = tonumber(value);

        local alias = map[stat];
        if(alias ~= "none") then
            if(not alias) then
                Utils.PrintError("Unknown stat "..stat);
            else
                result[alias] = value;
            end
        end
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
    Importers[key] = importFunc;
end

function ImportExportModule:RegisterExport(key, exportTitle, exportFunc)
    self.ExportTypes[key] = exportTitle;
    Exporters[key] = exportFunc;
end

function ImportExportModule:Import(importType, input)
    return Importers[importType](input);
end

function ImportExportModule:Export(exportType, spec)
    return Exporters[exportType](spec);
end

function ImportExportModule:RegisterDefaultImportExport()
    self:RegisterImport("sim", "SimulationCraft xml", ImportSimulationCraftXML);
    self:RegisterImport("amr", "Ask Mr. Robot share", ImportAskMrRobotShare);
    self:RegisterImport("pawn", "Pawn string", ImportPawnString)

    self:RegisterExport("amr", "Ask Mr. Robot share", ExportAskMrRobotShare);
end