local SWS_ADDON_NAME, StatWeightScore = ...;
local OptionsModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."Options");

local AceConfig = LibStub("AceConfig-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local AceDB = LibStub("AceDB-3.0");
local AceDBOptions = LibStub("AceDBOptions-3.0");

local XmlModule;
local GemsModule;
local StatsModule;

local Utils;
local L;

local ImportTypes = {
    ["sim"] = "SimulationCraft xml"
};

function OptionsModule:CreateOptions()
    self.Defaults = {
        profile = {
            EnableTooltip = true,
            EnchantLevel = 1,
            BlankLineMainAbove = true,
            BlankLineMainBelow = false,
            BlankLineRefAbove = true,
            BlankLineRefBelow = false,
            Specs = {}
        }
    };

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
                    EnchantLevel = {
                        order = 20,
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
                            },
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
    XmlModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Xml");
    GemsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Gems");
    StatsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Stats");
    L = StatWeightScore.L;
    Utils = StatWeightScore.Utils;

    self.ImportType = "sim";

    local db = AceDB:New(SWS_ADDON_NAME.."DB", self.Defaults);
    StatWeightScore.db = db;

    self:MigrateLegacySettings();

    self:CreateOptions();

    self.Options.args.profiles = AceDBOptions:GetOptionsTable(db);

    for name, _ in pairs(db.profile.Specs) do
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

function OptionsModule:ToggleOptions(subcategory)
    local panel = SWS_ADDON_NAME;
    if(subcategory) then
        panel = subcategory;
    end

    InterfaceOptionsFrame_OpenToCategory(panel);
    InterfaceOptionsFrame_OpenToCategory(panel); -- bug in blizz interface options
end

function OptionsModule:CreateOptionsForSpec(key)
    local db = StatWeightScore.db.profile.Specs;
    local options = self.Options.args.Weights.args;

    local spec = db[key];

    options[key] = {
        type = "group",
        get = function(info)
            return spec[info[#info]];
        end,
        set = function(info, value)
            spec[info[#info]] = value;
        end,
        name = function () return spec.Name end,
        order = spec.Order;
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

                    for _, statKey in ipairs(Utils.SortedKeys(stats, function (key1, key2)
                        return stats[key1].Order < stats[key2].Order;
                    end)) do
                        local stat = stats[statKey];
                        if(stat.Gem and spec.Weights[StatsModule:KeyToAlias(statKey)]) then
                            v[stat.Alias] = stat.DisplayName;
                        end
                    end

                    return v;
                end,
                order = 15
            },
            Remove = {
                type = "execute",
                name = L["Options_DeleteSpec"],
                confirm = function()
                    return string.format(L["Options_DeleteSpec_Confirm"], db[key].Name);
                end,
                func = function()
                    db[key] = nil;
                    options[key] = nil;
                end,
                order = 20
            },
            Stats = {
                type = "multiselect",
                name = L["Options_SelectStats_Label"],
                desc = L["Options_SelectStats_Tooltip"],
                dialogControl = "Dropdown",
                set = function(info, index, value)
                    if(value) then
                        spec.Weights[index] = 0;
                        self:CreateOptionsForStatWeight(spec, index);
                    else
                        spec.Weights[index] = nil;
                        local section = options[key].args.Weights.args;
                        local stat = section[index];
                        section[index..stat.order] = nil;
                        section[index] = nil;
                    end
                end,
                get = function(info, index)
                    return spec.Weights[index] ~= nil;
                end,
                values = function ()
                    local v = {};
                    local stats = StatsModule:GetStats();

                    for _, statKey in ipairs(Utils.SortedKeys(stats, function (key1, key2)
                        return stats[key1].Order < stats[key2].Order;
                    end)) do
                        local stat = stats[statKey];
                        v[stat.Alias] = stat.DisplayName;
                    end

                    return v;
                end,
                order = 25
            },
            Weights = {
                type = "group",
                inline = true,
                name = L["Options_Weights_Section"],
                args = {

                },
                order = 30
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
                        end,
                        values = ImportTypes,
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
                        end,
                        order = 20
                    }
                },
                order = 35
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

function OptionsModule:CreateNewSpec()
    local index = 1;
    for _,_ in pairs(StatWeightScore.db.profile.Specs) do
        index = index + 1;
    end

    local spec = {
        Name = "New spec "..index,
        Enabled = true,
        Weights = {},
        GemStat = "best",
        Order = index;
    };

    StatWeightScore.db.profile.Specs[spec.Name] = spec;

    self:CreateOptionsForSpec(spec.Name);
end

function OptionsModule:Import(spec, input)
    if(not input or input == "") then
        return;
    end

    local result;

    if(self.ImportType == "sim") then
        result = self:ImportSimulationCraftXML(input);
    end

    if(not result) then
        error("Import unsuccesfull");
    end

    spec.Weights = {};

    for stat, weight in pairs(result) do
        if(StatsModule:GetStatInfo(stat)) then
            spec.Weights[stat] = weight;
            self:CreateOptionsForStatWeight(spec, stat);
        end
    end
end

function OptionsModule:ImportSimulationCraftXML(input)
    local result = {};
    local x = XmlModule:Parse(input);

    local root = x[1];
    if(root.label ~= "weights") then
        error("Couldn't find root element 'weights' in the xml");
    end

    local simulationCraftStatMap = {
        ["Wdps"] = "dps",
        ["Mult"] = "multistrike",
        ["Vers"] = "versatility",
    };

    for _, e in ipairs(root) do
        if(e.label == "stat") then
            local statName = e.xarg.name;
            local alias = simulationCraftStatMap[statName] or statName:lower();
            result[alias] = tonumber(e.xarg.value);
        end
    end

    return result;
end

function OptionsModule:MigrateLegacySettings()
    if(StatWeightScore_Settings) then
        local realm = GetRealmName();
        local name = UnitName("player");

        if(not StatWeightScore_Settings[realm] or not StatWeightScore_Settings[realm][name]) then
            return
        end

        local profile = StatWeightScore_Settings[realm][name];

        local db = StatWeightScore.db.profile;
        db.EnableTooltip = profile.Options.EnableTooltip;
        db.EnchantLevel = profile.Options.EnchantLevel;
        db.BlankLineMainAbove = profile.Options.BlankLineMainAbove;
        db.BlankLineMainBelow = profile.Options.BlankLineMainBelow;
        db.BlankLineRefAbove = profile.Options.BlankLineRefAbove;
        db.BlankLineRefBelow = profile.Options.BlankLineRefBelow;

        db.Specs = {};
        local order = 1;
        for _, spec in pairs(profile.Weights) do
            spec.Order = order;
            order = order + 1;
            db.Specs[spec.Name] = spec;
        end

        StatWeightScore_Settings[realm][name] = nil;
    end
end