local SWS_ADDON_NAME, StatWeightScore = ...;
local OptionsModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Options", "AceEvent-3.0");

local AceConfig = LibStub("AceConfig-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local AceDBOptions = LibStub("AceDBOptions-3.0");

local ImportExportModule;
local GemsModule;
local SpecModule;
local StatsModule;

local Utils;
local L;

OptionsModule.Defaults = {
    profile = {
        EnableTooltip = true,
        EnchantLevel = 1,
        BlankLineMainAbove = true,
        BlankLineMainBelow = false,
        BlankLineRefAbove = true,
        BlankLineRefBelow = false,
        EnableCmMode = true,
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
                    StatWeightScore.db.profile[info[#info]] = value;
                end,
                name = GetAddOnMetadata(SWS_ADDON_NAME, "Title").." v"..StatWeightScore.Version,
                args = {
                    EnableTooltip = {
                        order = 10,
                        type = "toggle",
                        name = L["Options_Enabled"],
                        desc = L["Options_EnabledGlobal_Tooltip"],
                    },

                    EnableCmMode = {
                        order = 15,
                        type = "toggle",
                        name = L["Options_EnableCmMode_Label"],
                        desc = L["Options_EnableCmMode_Tooltip"],
                    },
                    NewLine1 = {
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
                                order = 30,
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
                                order = 40,
                                type = "toggle",
                                name = L["Options_BlankLineRefBelow_Label"],
                                desc = L["Options_BlankLineRefBelow_Tooltip"],
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
    L = StatWeightScore.L;
    Utils = StatWeightScore.Utils;

    self.ImportType = "sim";
    self.ExportType = "amr";

    local db = StatWeightScore.db;
    db.RegisterCallback(self, "OnProfileChanged", "NotifyConfigChanged");
    db.RegisterCallback(self, "OnProfileCopied", "NotifyConfigChanged");
    db.RegisterCallback(self, "OnProfileReset", "NotifyConfigChanged");


    self:CreateOptions();

    self.Options.args.profiles = AceDBOptions:GetOptionsTable(db);

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

            if(field == "Normalize") then
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
                order = 15
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
                order = 20
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
                order = 25
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

    if(options[alias]) then
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
        Normalize = false
    };

    SpecModule:SetSpec(spec);

    self:CreateOptionsForSpec(spec.Name);
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