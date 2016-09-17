local SWS_ADDON_NAME, StatWeightScore = ...;
local OptionsModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Options");

local AceDB = LibStub("AceDB-3.0");
local AceConfig = LibStub("AceConfig-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local AceDBOptions = LibStub("AceDBOptions-3.0");

local ImportExportModule;
local GemsModule;
local SpecModule;
local StatsModule;
local CharacterModule;
local ItemLinkModule;

local Utils;
local L;

local ScoreCompareTypes;
local PercentageCalculationTypes;
local GetStatsMethods;

OptionsModule.Defaults = {
    profile = {
        EnableTooltip = true,
        EnchantLevel = 1,
        BlankLineMainAbove = true,
        BlankLineMainBelow = false,
        BlankLineRefAbove = true,
        BlankLineRefBelow = false,
        ForceSelectedGemStat = true,
        ScoreCompareType = "total",
        PercentageCalculationType = "change",
        ShowStatsPane = true,
        ShowUpgrades = true,
        SuggestSabersEye = false,
        Specs = {}
    }
};

function OptionsModule:CreateOptions()
    self.Options = {
        type = "group",
        args = {
            General = {
                type = "group",
                get = function(info)
                    return StatWeightScore.db.profile[info[#info]];
                end,
                set = function(info, value)
                    local field = info[#info];
                    StatWeightScore.db.profile[field] = value;

                    if(field == "EnchantLevel" or field == "ForceSelectedGemStat" or field == "ShowStatsPane") then
                        self:NotifyConfigChanged();
                    end
                end,
                name = GetAddOnMetadata(SWS_ADDON_NAME, "Title").." v"..StatWeightScore.Version,
                args = {
                    EnableTooltip = {
                        order = 10,
                        type = "toggle",
                        name = L["Options_Enabled"],
                        desc = L["Options_EnabledGlobal_Tooltip"],
                    },
                    GetStatsMethod = {
                        order = 13,
                        type = "select",
                        name = L["Options_GetStats_Label"],
                        desc = L["Options_GetStats_Tooltip"],
                        values = GetStatsMethods
                    },
                    NewLine1 = {
                        type= 'description',
                        order = 25,
                        name= '',
                    },
                    NewLine2 = {
                        type= 'description',
                        order = 20,
                        name= '',
                    },
                    EnchantLevel = {
                        order = 25,
                        type = "select",
                        name = L["Options_EnchantLevel_Label"],
                        desc = L["Options_EnchantLevel_Tooltip"],
                        values = function()
                            local v = {};
                            for i, gem in ipairs(GemsModule:GetGems()) do
                                v[i] = gem.Name;
                            end

                            return v;
                        end,
                    },
                    ForceSelectedGemStat = {
                        order = 27,
                        type = "toggle",
                        name = L["Options_ForceSelectedGemStat_Label"],
                        desc = L["Options_ForceSelectedGemStat_Tooltip"],
                    },
                    SuggestSabersEye = {
                        order = 27,
                        type = "toggle",
                        name = L["Options_SuggestSabersEye_Label"],
                        desc = L["Options_SuggestSabersEye_Tooltip"],
                    },
                    Display = {
                        type = "group",
                        name = "Display",
                        inline = true,
                        args = {
                            BlankLineMainAbove = {
                                order = 30,
                                type = "toggle",
                                name = L["Options_BlankLineMainAbove_Label"],
                                desc = L["Options_BlankLineMainAbove_Tooltip"],
                            },
                            BlankLineMainBelow = {
                                order = 31,
                                type = "toggle",
                                name = L["Options_BlankLineMainBelow_Label"],
                                desc = L["Options_BlankLineMainBelow_Tooltip"],
                            },
                            NewLine1 = {
                                type= 'description',
                                order = 35,
                                name= '',
                            },
                            BlankLineRefAbove = {
                                order = 40,
                                type = "toggle",
                                name = L["Options_BlankLineRefAbove_Label"],
                                desc = L["Options_BlankLineRefAbove_Tooltip"],
                            },
                            BlankLineRefBelow = {
                                order = 41,
                                type = "toggle",
                                name = L["Options_BlankLineRefBelow_Label"],
                                desc = L["Options_BlankLineRefBelow_Tooltip"],
                            },
                            NewLine2 = {
                                type= 'description',
                                order = 45,
                                name= '',
                            },
                            ShowUpgrades = {
                                order = 47,
                                type = "toggle",
                                name = L["Options_ShowUpgrades_Label"],
                                desc = L["Options_ShowUpgrades_Tooltip"],
                            },
                            NewLine4 = {
                                type= 'description',
                                order = 48,
                                name= '',
                            },
                            NewLine5 = {
                                type= 'description',
                                order = 49,
                                name= '',
                            },
                            ScoreCompareType = {
                                order = 50,
                                type = "select",
                                name = L["Options_Compare_Label"],
                                desc = L["Options_Compare_Tooltip"],
                                values = ScoreCompareTypes
                            },
                            PercentageCalculationType = {
                                order = 55,
                                type = "select",
                                name = L["Options_Percentage_Label"],
                                desc = L["Options_Percentage_Tooltip"],
                                values = PercentageCalculationTypes
                            }
                        }
                    }
                }
            },
            Weights = {
                type = "group",
                name = L["Options_StatWeightsSetup"],
                args = {
                    CreateNew = {
                        type = "execute",
                        name = L["Options_CreateNewSpec"],
                        func = function()
                            self:CreateNewSpec();
                        end
                    },
                }
            },
            commands = {
                type = "group",
                args = {
                    config = {
                        type = "execute",
                        name = L["Options_Open"],
                        func = function()
                            self:ToggleOptions();
                        end
                    },
                    weights = {
                        type = "execute",
                        name = L["Options_Weights_Open"],
                        func = function()
                            self:ToggleOptions(L["Options_Weights_Section"]);
                        end
                    },
                    character_score = {
                        type = "execute",
                        name = L["CharacterScore_Command"],
                        func = function ()
                            local scores = CharacterModule:GetCharacterScores();

                            -- not correct in CM
                            if(select(3, GetInstanceInfo()) == 8) then
                                print(L["Warning"]..": "..L["CharacterPane_CM_Tooltip"]);
                            end

                            print(L["CharacterScore_Info"]);
                            for _, score in pairs(scores) do
                                print(NORMAL_FONT_COLOR_CODE..score.Spec.."|r"..": "..string.format("%.2f", score.Score));
                            end
                        end
                    },
                    replace_bonuses = {
                        type = "execute",
                        name = "Replace bonuses in item link - for debugging",
                        func = function(args)
                            local params = string.match(args.input, '|r .*'):sub(3);
                            local parsed = StatWeightScore:GetModule(SWS_ADDON_NAME.."ItemLink"):Parse(args.input:sub(11));

                            parsed.bonuses = Utils.SplitString(params);
                            local link = parsed:ToString();
                            print(link);
                        end
                    },
                    parse_link = {
                        type = "execute",
                        name = "Parse item link",
                        func = function(args)
                            local parsed = ItemLinkModule:Parse(args.input);
                            Utils.Print(parsed);
                        end
                    },
                    test = {
                        type = "execute",
                        name = "Run test suite",
                        func = function()
                            local testSuite = StatWeightScore:GetModule(SWS_ADDON_NAME.."Test");
                            Utils.Print("Running test suit...");
                            local results = testSuite:RunTests();
                            local totalOk = 0;
                            local totalFail = 0;
                            local totalIgnored = 0;

                            for _, result in pairs(results) do
                                local color;
                                if(result.status == "OK") then
                                    totalOk = totalOk + 1;
                                    color = GREEN_FONT_COLOR_CODE;
                                elseif(result.status == "FAIL") then
                                    totalFail = totalFail + 1;
                                    color = RED_FONT_COLOR_CODE;
                                else
                                    totalIgnored = totalIgnored + 1;
                                    color = YELLOW_FONT_COLOR_CODE;
                                end

                                local line = string.format("[%s%s|r] %s %s", color, result.status, result.name, result.message);
                                print(line);
                            end

                            local totalStatus;
                            local totalColor;
                            if(totalFail == 0) then
                                totalStatus = "SUCCESS";
                                totalColor = GREEN_FONT_COLOR_CODE;
                            else
                                totalStatus = "FAILED";
                                totalColor = RED_FONT_COLOR_CODE;
                            end

                            print();
                            Utils.Print(string.format("Test suite %s%s|r. %d success %d failed %d ignored.", totalColor, totalStatus, totalOk, totalFail, totalIgnored));
                        end
                    }
                }
            }
        }
    };
end

function OptionsModule:OnInitialize()
    GemsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Gems");
    StatsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Stats");
    SpecModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Spec");
    ImportExportModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ImportExport");
    CharacterModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Character");
    ItemLinkModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ItemLink");
    L = StatWeightScore.L;
    Utils = StatWeightScore.Utils;

    self.ImportType = "pawn";
    self.ExportType = "amr";

    ScoreCompareTypes = {
        ["item"] = L["Options_Compare_Item"],
        ["total"] = L["Options_Compare_Character"]
    };

    PercentageCalculationTypes = {
        ["change"] = L["Options_Percentage_Change"],
        ["diff"] = L["Options_Percentage_Difference"]
    };

    GetStatsMethods = {
        ["api"] = L["Options_GetStats_WoWAPI"],
        ["tooltip"] = L["Options_GetStats_ParseTooltip"]
    };

    self:CreateOptions();

    self.Options.args.profiles = AceDBOptions:GetOptionsTable(StatWeightScore.db);

    for name, _ in pairs(SpecModule:GetSpecs()) do
        self:CreateOptionsForSpec(name);
    end

    AceConfig:RegisterOptionsTable(SWS_ADDON_NAME, self.Options.args.General);
    AceConfig:RegisterOptionsTable(SWS_ADDON_NAME.." Weights", self.Options.args.Weights);
    AceConfig:RegisterOptionsTable(SWS_ADDON_NAME.." Profiles", self.Options.args.profiles);
    AceConfig:RegisterOptionsTable(SWS_ADDON_NAME.." Commands", self.Options.args.commands, "sws");

    AceConfigDialog:AddToBlizOptions(SWS_ADDON_NAME)
    AceConfigDialog:AddToBlizOptions(SWS_ADDON_NAME.." Weights", L["Options_Weights_Section"], SWS_ADDON_NAME);
    AceConfigDialog:AddToBlizOptions(SWS_ADDON_NAME.." Profiles", "Profiles", SWS_ADDON_NAME);
end

function OptionsModule:InitializeDatabase()
    if(OptionsModule.Defaults.profile.GetStatsMethod == nil) then
        local locale = GetLocale();
        if(locale == "enGB") then
            locale = "enUS";
        end
        
        if(StatWeightScore.L["Culture"] == locale) then
            OptionsModule.Defaults.profile.GetStatsMethod = "tooltip"
        else
            OptionsModule.Defaults.profile.GetStatsMethod = "api"
        end
    end

    local db = AceDB:New(SWS_ADDON_NAME.."DB", OptionsModule.Defaults);
    StatWeightScore.db = db;
    db.RegisterCallback(self, "OnProfileChanged", "NotifyConfigChanged");
    db.RegisterCallback(self, "OnProfileCopied", "NotifyConfigChanged");
    db.RegisterCallback(self, "OnProfileReset", "NotifyConfigChanged");
end

function OptionsModule:NotifyConfigChanged()
    self:SendMessage(SWS_ADDON_NAME.."ConfigChanged");
end

function OptionsModule:ToggleOptions(subcategory)
    local panel = SWS_ADDON_NAME;
    if(subcategory) then
        panel = subcategory;
    end

    InterfaceOptionsFrame_OpenToCategory(panel);
    InterfaceOptionsFrame_OpenToCategory(panel); -- bug in blizz interface options
end

function OptionsModule:CreateOptionsForSpec(key)
    local db = SpecModule:GetSpecs();
    local options = self.Options.args.Weights.args;

    local spec = db[key];

    options[key] = {
        type = "group",
        get = function(info)
            return spec[info[#info]];
        end,
        set = function(info, value)
            local field = info[#info];
            spec[field] = value;

            if(field == "Normalize" or field == "GemStat") then
                self:NotifyConfigChanged();
            end
        end,
        name = function () return spec.Name end,
        order = function () return spec.Order end,
        args = {
            Name = {
                type = "input",
                name = L["Options_Specialization_Label"],
                desc = L["Options_Specialization_Tooltip"],
                set = function(info, value)
                    if db[value] then
                        return;
                    end

                    db[value] = db[key];
                    spec.Name = value;
                    db[key] = nil;

                    options[value] = options[key];
                    options[key] = nil;
                    key = value;

                    AceConfigDialog:SelectGroup(SWS_ADDON_NAME.." Weights", key);

                    self:NotifyConfigChanged();
                end,
                order = 10
            },
            Enabled = {
                type = "toggle",
                name = L["Options_Enabled"],
                desc = L["Options_EnabledSpec_Tooltip"],
                order = 13
            },
            EquipmentSet = {
                type = "select",
                style = "dropdown",
                values = function()
                    local dropdownTable = {[""] = ""};
                    for setIndex = 1, GetNumEquipmentSets() do
                        local setName = GetEquipmentSetInfo(setIndex);
                        dropdownTable[setName] = setName;
                    end
                    return dropdownTable;
                end,
                name = L["Options_AssociatedSet_Label"],
                desc = L["Options_AssociatedSet_Tooltip"],
                order = 14
            },
            GemStat = {
                type = "select",
                name = L["Options_GemStat_Label"],
                desc = L["Options_GemStat_Tooltip"],
                values = function ()
                    local v = {};
                    v["best"] = L["Options_GemStat_Best"];
                    local stats = StatsModule:GetStats();

                    for _, statKey in ipairs(Utils.OrderKeysBy(stats, "Order")) do
                        local stat = stats[statKey];
                        if(stat.Gem and spec.Weights[StatsModule:KeyToAlias(statKey)]) then
                            v[stat.Alias] = stat.DisplayName;
                        end
                    end

                    if(not v[spec.GemStat]) then
                        spec.GemStat = "best";
                    end

                    return v;
                end,
                order = 17
            },
            Remove = {
                type = "execute",
                name = L["Options_DeleteSpec"],
                confirm = function()
                    return string.format(L["Options_DeleteSpec_Confirm"], spec.Name);
                end,
                func = function()
                    self:RemoveSpec(key);
                end,
                order = 15
            },
            Stats = {
                type = "multiselect",
                name = L["Options_SelectStats_Label"],
                desc = L["Options_SelectStats_Tooltip"],
                dialogControl = "Dropdown",
                get = function(info, index)
                    return spec.Weights[index] ~= nil;
                end,
                set = function(info, index, value)
                    if(value) then
                        spec.Weights[index] = 0;
                        self:CreateOptionsForStatWeight(spec, index);
                    else
                        spec.Weights[index] = nil;
                        self:RemoveOptionsForStatWeight(spec, index);
                    end

                    self:NotifyConfigChanged();
                end,
                validate = function(options, index, value)
                    local statInfo = StatsModule:GetStatInfo(index);

                    if(statInfo.Primary and value) then
                        local primary = {};
                        table.insert(primary, statInfo)
                        for stat, _ in pairs(spec.Weights) do
                            local info = StatsModule:GetStatInfo(stat);
                            if(info.Primary) then
                                table.insert(primary, info);
                            end
                        end

                        if(#primary > 1) then
                            Utils.PrintError(L["Error_MultiplePrimaryStatsSelected"]); -- workaround a 6yo bug in Ace
                            return L["Error_MultiplePrimaryStatsSelected"];
                        end
                    end

                    return true;
                end,
                values = function ()
                    local v = {};
                    local stats = StatsModule:GetStats();

                    for _, statKey in ipairs(Utils.OrderKeysBy(stats, "Order")) do
                        local stat = stats[statKey];
                        v[stat.Alias] = stat.DisplayName;
                    end

                    return v;
                end,
                order = 16
            },
            SpecOrder = {
                type = "select",
                name = L["Options_Order_Label"],
                get = function(info)
                    return spec.Order;
                end,
                set = function(info, value)
                    local original = spec.Order;
                    for _, specKey in ipairs(Utils.OrderKeysBy(db, "Order")) do
                        local s = db[specKey];
                        if(s == spec) then
                            s.Order = value;
                        elseif(s.Order >= value and s.Order < original) then
                            s.Order = s.Order + 1;
                        elseif(s.Order > original and s.Order <= value) then
                            s.Order = s.Order - 1;
                        end
                    end

                    self:NotifyConfigChanged();
                end,
                values = function()
                    local v = {};

                    for _, specKey in ipairs(Utils.OrderKeysBy(db, "Order")) do
                        local order = db[specKey].Order;
                        v[order] = order;
                    end

                    return v;
                end,
                order = 27
            },
            Weights = {
                type = "group",
                inline = true,
                name = L["Options_Weights_Section"],
                args = {
                },
                order = 30
            },
            Normalize = {
                type = "toggle",
                name = L["Options_NormalizeWeights_Label"],
                desc = L["Options_NormalizeWeights_Tooltip"],
                order = 32
            },
            Import = {
                type = "group",
                name = L["Options_Import_Title"],
                inline = true,
                args = {
                    ImportType = {
                        type = "select",
                        name = L["Options_ImportType_Label"],
                        desc = L["Options_ImportType_Tooltip"],
                        get = function(info)
                            return self.ImportType;
                        end,
                        set = function(info, value)
                            self.ImportType = value;
                            self:NotifyConfigChanged();
                        end,
                        values = ImportExportModule.ImportTypes,
                        order = 10
                    },
                    Import = {
                        type = "input",
                        name = L["Options_Import_Label"],
                        desc = L["Options_Import_Tooltip"],
                        multiline = true,
                        width = "full",
                        set = function(info, value)
                            self:Import(spec, value)
                            self.LastExport = nil;
                        end,
                        order = 20
                    }
                },
                order = 35
            },
            Export = {
                type = "group",
                name = L["Options_Export_Title"],
                inline = true,
                args = {
                    ExportType = {
                        type = "select",
                        name = L["Options_ExportType_Label"],
                        desc = L["Options_ExportType_Tooltip"],
                        get = function(info)
                            return self.ExportType;
                        end,
                        set = function(info, value)
                            self.ExportType = value;
                            self.LastExport = nil;
                        end,
                        values = ImportExportModule.ExportTypes,
                        order = 10
                    },
                    ExportButton = {
                        type = "execute",
                        name = L["Options_Export"],
                        func = function()
                            self.LastExport = ImportExportModule:Export(self.ExportType, spec);
                        end,
                        order = 11
                    },
                    Export = {
                        type = "input",
                        name = L["Options_Export_Label"],
                        multiline = true,
                        width = "full",
                        set = function(info, value)
                        end,
                        get = function(info)
                            return self.LastExport;
                        end,
                        order = 20
                    }
                },
                order = 40
            }
        }
    };

    for stat, _ in pairs(spec.Weights) do
        self:CreateOptionsForStatWeight(spec, stat);
    end
end

function OptionsModule:CreateOptionsForStatWeight(spec, alias)
    local options = self.Options.args.Weights.args[spec.Name].args.Weights.args;

    local stat = StatsModule:GetStatInfo(alias);

    if(options[alias] or not stat) then
        return;
    end

    options[alias] = {
        type = "input",
        name = stat.DisplayName,
        set = function(info, value)
            spec.Weights[alias] = tonumber(value);
            self:NotifyConfigChanged();
        end,
        get = function(info)
            return tostring(spec.Weights[alias]);
        end,
        width = "half",
        order = stat.Order,
        pattern = "^[%d]+[,%.]?[%d]-$"
    };

    options[alias..stat.Order] = {
        type = "description",
        name = "",
        order = stat.Order + 1,
        width = "half"
    };
end

function OptionsModule:RemoveOptionsForStatWeight(spec, alias)
    local options = self.Options.args.Weights.args[spec.Name].args.Weights.args;
    local stat = options[alias];
    if(stat) then
        options[alias..stat.order] = nil;
        options[alias] = nil;
    end
end

function OptionsModule:CreateNewSpec()
    local db = SpecModule:GetSpecs();
    local order = 1;

    local ordered = Utils.OrderKeysBy(db, "Order");

    if(#ordered ~= 0) then
        order = db[ordered[#ordered]].Order + 1;
    end

    local name;
    local nameIndex = 1;
    while(name == nil) do
        local n = "New spec "..nameIndex;
        if(not db[n]) then
            name = n;
        end
        nameIndex = nameIndex + 1;
    end

    local spec = {
        Name = name,
        Enabled = true,
        Weights = {},
        GemStat = "best",
        Order = order,
        Normalize = true
    };

    SpecModule:SetSpec(spec);

    self:CreateOptionsForSpec(spec.Name);
    self:NotifyConfigChanged();
    AceConfigDialog:SelectGroup(SWS_ADDON_NAME.." Weights", spec.Name);
end

function OptionsModule:RemoveSpec(key)
    local db = SpecModule:GetSpecs();
    local options = self.Options.args.Weights.args;

    options[key] = nil;
    db[key] = nil;

    local order = 1;
    for _, specKey in ipairs(Utils.OrderKeysBy(db, "Order")) do
        db[specKey].Order = order;
        order = order + 1;
    end

    self:NotifyConfigChanged();
end

function OptionsModule:Import(spec, input)
    if(not input or input == "") then
        return;
    end

    local result = Utils.Try(function()
        return ImportExportModule:Import(self.ImportType, input);
    end, function(err)
        Utils.PrintError("Import error: "..err);
    end)

    if(not result) then
        return;
    end

    spec.Weights = {};
    self.Options.args.Weights.args[spec.Name].args.Weights.args = {};

    for stat, weight in pairs(result) do
        spec.Weights[stat] = weight;
        self:CreateOptionsForStatWeight(spec, stat);
    end
end