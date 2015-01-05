local L = LibStub("AceLocale-3.0"):GetLocale("StatWeightScore");
StatWeightScore.OptionRepository = {};

function StatWeightScore.RegisterOption(option, type, label, tooltip)
    table.insert(StatWeightScore.OptionRepository, {
        option = option,
        type = type,
        label = label,
        tooltip = tooltip
    });
end

function StatWeightScore.InitializeRegisteredOptions()
    for _, o in pairs(StatWeightScore.OptionRepository) do
        local textName;
        if(o.type == "checkbox") then
            textName = "Text";
        elseif(o.type == "dropdown") then
            textName = "Label";
        end

        local frame = getglobal("StatWeightScore_Options_General_"..o.option);
        local text = getglobal(frame:GetName()..textName);

        frame.tooltipText = o.tooltip;
        text:SetText(o.label);
    end
end

function StatWeightScore.FillRegisteredOptions()
    for _, o in pairs(StatWeightScore.OptionRepository) do
        local value = StatWeightScore.Options[o.option];
        local frame = getglobal("StatWeightScore_Options_General_"..o.option);

        if(o.type == "checkbox") then
            frame:SetChecked(value);
        elseif(o.type == "dropdown") then
            local gem = StatWeightScore.Gem[value];
            UIDropDownMenu_SetSelectedValue(frame, value);
            UIDropDownMenu_SetText(frame, gem.Name);
        end
    end
end

function StatWeightScore.SaveRegisteredOptions()
    for _, o in pairs(StatWeightScore.OptionRepository) do
        local frame = getglobal("StatWeightScore_Options_General_"..o.option);
        local value;

        if(o.type == "checkbox") then
            value = frame:GetChecked();
        elseif(o.type == "dropdown") then
            value = UIDropDownMenu_GetSelectedValue(frame);
        end

        StatWeightScore.Options[o.option] = value;
    end
end

function StatWeightScore_Options_OnLoad(panel)
    panel.name = "Stat Weight Score";
    panel.okay = StatWeightScore.SaveOptions;
    panel.cancel = StatWeightScore.InitializeOptions;

    StatWeightScore_Options_General_Title:SetText("Stat Weight Score v"..StatWeightScore.Version);
    StatWeightScore_Options_Weights_Title:SetText(L["Options_StatWeightsSetup"]);
    StatWeightScore_Options_Weights_SpecLabel:SetText(L["Options_Specialization_Label"]);
    StatWeightScore_Options_Weights_ForceGemStatLabel:SetText(L["Options_ForceGemStat_Label"]);
    StatWeightScore_Options_Weights_CreateNewSpecText:SetText(L["Options_CreateNewSpec"]);
    StatWeightScore_Options_Weights_DuplicateSpecText:SetText(L["Options_DuplicateSpec"]);
    StatWeightScore_Options_Weights_RenameSpecText:SetText(L["Options_RenameSpec"]);
    StatWeightScore_Options_Weights_DeleteSpecText:SetText(L["Options_DeleteSpec"]);
    StatWeightScore_Options_Weights_EnabledText:SetText(L["Options_Enabled"]);
    UIDropDownMenu_SetText(StatWeightScore_Options_Weights_Stats, L["Options_AddOrRemoveStat"]);

    StatWeightScore.RegisterOption("EnableTooltip", "checkbox", L["Options_Enabled"], L["Options_EnabledGlobal_Tooltip"]);
    StatWeightScore.RegisterOption("BlankLineMainAbove", "checkbox", L["Options_BlankLineMainAbove_Label"], L["Options_BlankLineMainAbove_Tooltip"]);
    StatWeightScore.RegisterOption("BlankLineMainBelow", "checkbox", L["Options_BlankLineMainBelow_Label"], L["Options_BlankLineMainBelow_Tooltip"]);
    StatWeightScore.RegisterOption("BlankLineRefAbove", "checkbox", L["Options_BlankLineRefAbove_Label"], L["Options_BlankLineRefAbove_Tooltip"]);
    StatWeightScore.RegisterOption("BlankLineRefBelow", "checkbox", L["Options_BlankLineRefBelow_Label"], L["Options_BlankLineRefBelow_Tooltip"]);
    StatWeightScore.RegisterOption("EnchantLevel", "dropdown", L["Options_EnchantLevel_Label"], L["Options_EnchantLevel_Tooltip"]);

    StatWeightScore.InitializeRegisteredOptions();

    UIDropDownMenu_SetWidth(StatWeightScore_Options_General_EnchantLevel, 80);
    UIDropDownMenu_Initialize(StatWeightScore_Options_General_EnchantLevel, function(frame)
        for i, gem in ipairs(StatWeightScore.Gem) do
            local info = UIDropDownMenu_CreateInfo();

            info.text = gem.Name;
            info.value = i;
            info.func = StatWeightScore.OnEnchantLevelSelected;
            info.owner = frame;

            UIDropDownMenu_AddButton(info);
        end
    end);

    InterfaceOptions_AddCategory(panel);
end

function StatWeightScore.OnEnchantLevelSelected(self)
    UIDropDownMenu_SetSelectedValue(self.owner, self.value);
end

function StatWeightScore.InitializeOptions()
    StatWeightScore.FillRegisteredOptions();
    StatWeightScore_Options_Weights_Enabled:SetChecked(false);

    local specEditingCache = {};

    for i, spec in ipairs(StatWeightScore.Weights) do
        local specCache = {};
        specCache.Name = spec.Name;
        specCache.Enabled = spec.Enabled;
        specCache.GemStat = spec.GemStat;
        specCache.Weights = {};

        for stat, weight in pairs(spec.Weights) do
            specCache.Weights[stat] = weight;
        end

        specEditingCache[i] = specCache;
    end

    StatWeightScore.Cache["SpecEditing"] = specEditingCache;

    StatWeightScore.BuildSpecDropDownFromCache(nil);
end

function StatWeightScore.SortedKeys(t, sortFunction)
    local keys, len = {}, 0;
    for k,_ in pairs(t) do
        len = len + 1;
        keys[len] = k;
    end

    table.sort(keys, sortFunction);
    return keys;
end

function StatWeightScore.HideStatFrames(i)
    while(true) do
        i = i + 1;
        local frameName = "StatWeightScore_Options_Weights_StatWeights_"..i;
        local frame = getglobal(frameName);
        if(frame) then
            frame:Hide();
        else
            break;
        end
    end
end

function StatWeightScore.SetupSpecWeightOptions(index, spec, statChange)
    if(not spec) then
        StatWeightScore.Cache["CurrentSpecEditingIndex"] = nil;
        StatWeightScore_Options_Weights_RenameSpecName:SetText("");
        UIDropDownMenu_SetText(StatWeightScore_Options_Weights_Spec, L["Options_SelectSpec"]);
        UIDropDownMenu_DisableDropDown(StatWeightScore_Options_Weights_Stats);
        UIDropDownMenu_DisableDropDown(StatWeightScore_Options_Weights_ForceGemStat);
        UIDropDownMenu_SetText(StatWeightScore_Options_Weights_ForceGemStat, "");
        StatWeightScore_Options_Weights_RenameSpec:Disable();
        StatWeightScore_Options_Weights_RenameSpecName:Disable();
        StatWeightScore_Options_Weights_DeleteSpec:Disable();
        StatWeightScore_Options_Weights_Enabled:Disable();
        StatWeightScore.HideStatFrames(0);

        return;
    end

    StatWeightScore.Cache["CurrentSpecEditingIndex"] = index;

    StatWeightScore_Options_Weights_RenameSpecName:SetText(spec.Name);
    StatWeightScore_Options_Weights_Enabled:SetChecked(spec.Enabled);

    UIDropDownMenu_EnableDropDown(StatWeightScore_Options_Weights_Stats);
    UIDropDownMenu_EnableDropDown(StatWeightScore_Options_Weights_ForceGemStat);
    StatWeightScore_Options_Weights_RenameSpec:Enable();
    StatWeightScore_Options_Weights_RenameSpecName:Enable();
    StatWeightScore_Options_Weights_DeleteSpec:Enable();
    StatWeightScore_Options_Weights_Enabled:Enable();

    local idx = 0;
    for i, stat in pairs(StatWeightScore.SortedKeys(spec.Weights)) do
        idx = i;
        local weight = spec.Weights[stat];
        local frameName = "StatWeightScore_Options_Weights_StatWeights_"..i;
        local frame = getglobal(frameName);
        if(not frame) then
            frame = CreateFrame("Frame", frameName, StatWeightScore_Options_Weights_StatWeights, "StatWeightScore_Options_WeightRowTemplate");
        end

        frame.stat = stat;

        local y = (i-1)* 30;

        frame:SetPoint("TOPLEFT", math.floor(y / 210) * 240, (y % 210) * -1);
        frame:Show();

        getglobal(frameName.."_Stat"):SetText(StatWeightScore.GetStatInfo(stat).DisplayName);
        getglobal(frameName.."_Weight"):SetText(weight);
    end

    StatWeightScore.HideStatFrames(idx);

    if(not spec.Weights[spec.GemStat]) then
        spec.GemStat = "best";
    end

    UIDropDownMenu_Initialize(StatWeightScore_Options_Weights_ForceGemStat, function(frame)
        local info = UIDropDownMenu_CreateInfo();
        info.text = L["Options_ForceGemStat_Best"];
        info.value = "best";
        info.func = StatWeightScore.OnForceGemStatSelected;
        info.owner = frame;
        info.checked = spec.GemStat == "best";

        UIDropDownMenu_AddButton(info);

        for i, stat in ipairs(StatWeightScore.SortedKeys(StatWeightScore.StatRepository, function(v1, v2)
            return StatWeightScore.StatRepository[v1].DisplayName < StatWeightScore.StatRepository[v2].DisplayName;
        end)) do
            local statInfo = StatWeightScore.StatRepository[stat];
            local alias = StatWeightScore.StatAliasMap[stat];

            if(spec.Weights[alias] and statInfo.Gem) then
                info = UIDropDownMenu_CreateInfo();

                info.text = statInfo.DisplayName;
                info.value = alias;
                info.func = StatWeightScore.OnForceGemStatSelected;
                info.owner = frame;
                info.checked = spec.GemStat == alias;

                UIDropDownMenu_AddButton(info);
            end
        end
    end);

    UIDropDownMenu_SetSelectedValue(StatWeightScore_Options_Weights_ForceGemStat, spec.GemStat);

    if(not statChange) then
        UIDropDownMenu_Initialize(StatWeightScore_Options_Weights_Stats, function(frame)
            for i, stat in ipairs(StatWeightScore.SortedKeys(StatWeightScore.StatRepository, function(v1, v2)
                return StatWeightScore.StatRepository[v1].DisplayName < StatWeightScore.StatRepository[v2].DisplayName;
            end)) do
                local info = UIDropDownMenu_CreateInfo();
                local statInfo = StatWeightScore.StatRepository[stat];
                local alias = StatWeightScore.StatAliasMap[stat];

                info.text = statInfo.DisplayName;
                info.value = alias;
                info.func = StatWeightScore.OnStatSelected;
                info.owner = frame;
                info.notCheckable = false;
                info.checked = spec.Weights[StatWeightScore.StatAliasMap[stat]] ~= nil;

                UIDropDownMenu_AddButton(info);
            end
        end);
    end
end

function StatWeightScore.OnForceGemStatSelected(self)
    local weights = StatWeightScore.Cache["SpecEditing"];
    local index = StatWeightScore.Cache["CurrentSpecEditingIndex"];
    local spec = weights[index];

    spec.GemStat = self.value;

    UIDropDownMenu_SetSelectedValue(self.owner, self.value);
end

function StatWeightScore.OnStatSelected(self, _, _, checked)
    local weights = StatWeightScore.Cache["SpecEditing"];
    local index = StatWeightScore.Cache["CurrentSpecEditingIndex"];
    local spec = weights[index];

    if(checked) then
        spec.Weights[self.value] = nil;
    else
        spec.Weights[self.value] = 0;
    end

    self.checked = not checked;

    StatWeightScore.SetupSpecWeightOptions(index, spec, false);
end

function StatWeightScore.UpdateStatWeight(stat, weight)
    local index = StatWeightScore.Cache["CurrentSpecEditingIndex"];

    if(not index) then
        return;
    end

    local weights = StatWeightScore.Cache["SpecEditing"];
    local spec = weights[index];

    spec.Weights[stat] = tonumber(weight);
end

function StatWeightScore.BuildSpecDropDownFromCache(selected)
    local weights = StatWeightScore.Cache["SpecEditing"];

    UIDropDownMenu_Initialize(StatWeightScore_Options_Weights_Spec, function(frame)
        for i, spec in ipairs(weights) do
            local info = UIDropDownMenu_CreateInfo();

            info.text = spec.Name;
            info.value = i;
            info.func = StatWeightScore.OnWeightSpecSelected;
            info.owner = frame;

            UIDropDownMenu_AddButton(info);
        end
    end);

    UIDropDownMenu_SetSelectedValue(StatWeightScore_Options_Weights_Spec, selected);

    local currentSpec = weights[selected];
    StatWeightScore.SetupSpecWeightOptions(selected, currentSpec);
end

function StatWeightScore.OnWeightSpecSelected(self)
    local weights = StatWeightScore.Cache["SpecEditing"];
    StatWeightScore.ClearInputsFocus()
    UIDropDownMenu_SetSelectedValue(self.owner, self.value);

    StatWeightScore.SetupSpecWeightOptions(self.value, weights[self.value]);
end

function StatWeightScore.CreateNewSpec()
    local name = StatWeightScore_Options_Weights_NewSpecName:GetText();
    if(not name or string.len(name) == 0) then
        return;
    end

    local weights = StatWeightScore.Cache["SpecEditing"];

    table.insert(weights, {
        Name = name,
        Enabled = true,
        Weights = {},
        GemStat = "best"
    });

    StatWeightScore.BuildSpecDropDownFromCache(#weights);

    StatWeightScore_Options_Weights_NewSpecName:SetText("");
    StatWeightScore_Options_Weights_NewSpecName:ClearFocus();
end

function StatWeightScore.DuplicateSpec()
    local name = StatWeightScore_Options_Weights_NewSpecName:GetText();
    local index = StatWeightScore.Cache["CurrentSpecEditingIndex"];
    if(not name or not index or string.len(name) == 0) then
        return;
    end

    local weights = StatWeightScore.Cache["SpecEditing"];

    local spec = {
        Name = name,
        Enabled = true,
        Weights = {},
        GemStat = "best"
    };

    local duplicateFromSpec = weights[index];

    for stat, weight in pairs(duplicateFromSpec.Weights) do
        spec.Weights[stat] = weight;
    end

    table.insert(weights, spec);

    StatWeightScore.BuildSpecDropDownFromCache(#weights);

    StatWeightScore_Options_Weights_NewSpecName:SetText("");
    StatWeightScore_Options_Weights_NewSpecName:ClearFocus();
end

function StatWeightScore.RenameSpec()
    local name = StatWeightScore_Options_Weights_RenameSpecName:GetText();
    if(not name or string.len(name) == 0) then
        return;
    end

    local weights = StatWeightScore.Cache["SpecEditing"];

    weights[StatWeightScore.Cache["CurrentSpecEditingIndex"]].Name = name;

    StatWeightScore.BuildSpecDropDownFromCache(StatWeightScore.Cache["CurrentSpecEditingIndex"]);

    StatWeightScore_Options_Weights_RenameSpecName:ClearFocus();
end

function StatWeightScore.DeleteSpec()
    local weights = StatWeightScore.Cache["SpecEditing"];
    table.remove(weights, StatWeightScore.Cache["CurrentSpecEditingIndex"]);

    StatWeightScore.BuildSpecDropDownFromCache(1);
end

function StatWeightScore.SetSpecEnabled()
    local weights = StatWeightScore.Cache["SpecEditing"];

    weights[StatWeightScore.Cache["CurrentSpecEditingIndex"]].Enabled = StatWeightScore_Options_Weights_Enabled:GetChecked();
end

function StatWeightScore.ClearInputsFocus()
    local i = 0;
    while(true) do
        i = i + 1;
        local frameName = "StatWeightScore_Options_Weights_StatWeights_"..i.."_Weight";
        local frame = getglobal(frameName);
        if(frame) then
            frame:ClearFocus();
        else
            break;
        end
    end
end

function StatWeightScore.SaveOptions()
    StatWeightScore.SaveRegisteredOptions();
    StatWeightScore.ClearInputsFocus();

    StatWeightScore.Weights = StatWeightScore.Cache["SpecEditing"];

    StatWeightScore.SaveProfile();
    StatWeightScore.Cache = {};
    StatWeightScore.InitializeOptions();
end