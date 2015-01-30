local L = LibStub("AceLocale-3.0"):NewLocale("StatWeightScore", "enUS", true);

L["ThousandSeparator"] = ",";
L["DecimalSeparator"] = "%.";

L["WelcomeMessage"] = "loaded. v%s by Necroskillz";
L["GemsDisplayFormat"] = "%s gems";
L["Offhand_DPS"] = "Offhand DPS";
L["Offhand_Score"] = "Offhand score";
L["TooltipMessage_StatScore"] = "Stat score";
L["TooltipMessage_WithGem"] = "with gem";
L["TooltipMessage_WithProcAverage"] = "with proc average";
L["TooltipMessage_WithUseAverage"] = "with use on cd avg";
L["Options_Open"] = "Open configuration";
L["Options_Weights_Open"] = "Open stat weights configuration";
L["Options_Weights_Section"] = "Stat weights";
L["Options_StatWeightsSetup"] = "Stat weights setup";
L["Options_Specialization_Label"] = "Specialization";
L["Options_Specialization_Tooltip"] = "Label for this set of stat weights";
L["Options_CreateNewSpec"] = "Create new spec";
L["Options_DuplicateSpec"] = "Duplicate spec";
L["Options_DeleteSpec"] = "Delete spec";
L["Options_DeleteSpec_Confirm"] = "Are you sure that you want to delete spec '%s'?";
L["Options_Enabled"] = "Enabled";
L["Options_EnabledSpec_Tooltip"] = "Enables display of stat score in tooltips for a particular spec";
L["Options_EnabledGlobal_Tooltip"] = "Enables display of stat score in tooltips";
L["Options_SelectStats_Label"] = "Select stats";
L["Options_SelectStats_Tooltip"] = "Choose the relevant stats for this spec";
L["Options_BlankLineMainAbove_Label"] = "Blank line above (Main)";
L["Options_BlankLineMainAbove_Tooltip"] = "Displays blank line above stat score information in main tooltips";
L["Options_BlankLineMainBelow_Label"] = "Blank line below (Main)";
L["Options_BlankLineMainBelow_Tooltip"] = "Displays blank line below stat score information in main tooltips";
L["Options_BlankLineRefAbove_Label"] = "Blank line above (Reference)";
L["Options_BlankLineRefAbove_Tooltip"] = "Displays blank line above stat score information in reference tooltips (e.g. if you shift-hover on an item)";
L["Options_BlankLineRefBelow_Label"] = "Blank line below (Reference)";
L["Options_BlankLineRefBelow_Tooltip"] = "Displays blank line below stat score information in reference tooltips (e.g. if you shift-hover on an item)";
L["Options_EnableCmMode_Label"] = "Enable CM mode";
L["Options_EnableCmMode_Tooltip"] = "When in challenge mode dugeon, reads stats directly from tooltip - those are the correct stats for CM. Comparison only works when shift key is held down when this option is enabled and you are inside a challenge mode dungeon.";
L["Options_EnchantLevel_Label"] = "Gem level";
L["Options_EnchantLevel_Tooltip"] = "Which level of gems to use for empty sockets";
L["Options_GemStat_Label"] = "Gem stat";
L["Options_GemStat_Best"] = "Best stat";
L["Options_GemStat_Tooltip"] = "Which of the selected stats to assume for empty gem slots. Best stat automatically chooses the best rated stat.";
L["Options_Import_Title"] = "Import weights";
L["Options_ImportType_Label"] = "Import from";
L["Options_ImportType_Tooltip"] = "Choose import source type";
L["Options_Import_Label"] = "Import";
L["Options_Import_Tooltip"] = "Copy&paste import input";
L["Options_Order_Label"] = "Order";
L["Options_Export_Title"] = "Export weights";
L["Options_ExportType_Label"] = "Export to";
L["Options_ExportType_Tooltip"] = "Choose export format";
L["Options_Export"] = "Export";
L["Options_Export_Label"] = "Export output";
L["Error_MultiplePrimaryStatsSelected"] = "You can only select one primary stat (agi, str or int)";

-- Use: Increases your <stat> by <value> for <dur> sec. (<cd> Min Cooldown)
-- Use: Increases <stat> by <value> for <dur> sec. (<cdm> Min <cds> Sec Cooldown)
-- Use: Grants <value> <stat> for <dur> sec. (<cdm> Min <cds> Sec Cooldown)
-- Equip: Your attacks have a chance to grant <value> <stat> for <dur> sec.  (Approximately <procs> procs per minute)
-- Equip: Each time your attacks hit, you have a chance to gain <value> <stat> for <dur> sec. (<chance>% chance, <cd> sec cooldown)
-- Equip: Your attacks have a chance to grant you <value> <stat> for <dur> sec. (<chance>% chance, <cd> sec cooldown)
-- Insignia of Conquest - Equip: When you deal damage you have a chance to gain <value> <stat> for <dur> sec.
-- Solium Band - Equip: Your attacks have a chance to grant Archmage's Incandescence for <duration> sec.  (Approximately <procs> procs per minute)
-- +<value> Bonus Armor

L["Tooltip_Regex"] = {
    PreCheck = {
        "^Equip:",
        "^Use:",
        BONUS_ARMOR.."$"
    },
    Partial = {
        ["cdmin"] = "(%d+) Min",
        ["cdsec"] = "(%d+) Sec"
    },
    Matchers = {
        {
            Pattern = "^Equip: Your attacks have a chance to grant ([%d,%. ]+) ([%a ]-) for (%d+) sec%.  %(Approximately ([%d%.]+) procs per minute%)$",
            Fx = "rppm",
            ArgOrder = { "value", "stat", "duration", "ppm" }
        },
        {
            Pattern = "^Equip: Your attacks have a chance to grant Archmage's Incandescence for (%d+) sec%.  %(Approximately ([%d%.]+) procs per minute%)$",
            Fx = "soliumband",
            ArgOrder = { "duration", "ppm" }
        },
        {
            Pattern = "^Equip: Each time your attacks hit, you have a chance to gain ([%d,%. ]+) ([%a ]-) for (%d+) sec%.  %((%d+)%% chance, (%d+) sec cooldown%)$",
            Fx = "icd",
            ArgOrder = { "value", "stat", "duration", "chance", "cd" }
        },
        {
            Pattern = "^Equip: Your attacks have a chance to grant you ([%d,%. ]+) ([%a ]-) for (%d+) sec%.  %((%d+)%% chance, (%d+) sec cooldown%)$",
            Fx = "icd",
            ArgOrder = { "value", "stat", "duration", "chance", "cd" }
        },
        {
            Pattern = "^Equip: When you deal damage you have a chance to gain ([%d,%. ]+) ([%a ]-) for (%d+) sec%.",
            Fx = "insigniaofconquest",
            ArgOrder = { "value", "stat", "duration" }
        },
        {
            Pattern = "^Use: Increases y?o?u?r? ?([%a ]-) by ([%d,%. ]+) for (%d+) sec%. %(([%d%a ]-) Cooldown%)$",
            Fx = "use",
            ArgOrder = { "stat", "value", "duration", "cd" }
        },
        {
            Pattern = "^Use: Grants ([%d,%. ]+) ([%a ]-) for (%d+) sec%. %(([%d%a ]-) Cooldown%)$",
            Fx = "use",
            ArgOrder = { "value", "stat", "duration", "cd" }
        },
        {
            Pattern = "^%+(%d+) "..BONUS_ARMOR.."$",
            Fx = "bonusarmor",
            ArgOrder = { "value" }
        }
    }
};