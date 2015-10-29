local L = LibStub("AceLocale-3.0"):NewLocale("StatWeightScore", "enUS", true);

L["Culture"] = "enUS";

L["ThousandSeparator"] = ",";
L["DecimalSeparator"] = "%.";

L["StatPaneCategoryTitle"] = "Stat Weight Score";

L["WelcomeMessage"] = "loaded. v%s by Necroskillz";
L["GemsDisplayFormat"] = "%s gems";
L["Offhand_DPS"] = "Offhand DPS";
L["Offhand_Score"] = "Offhand score";
L["TooltipMessage_StatScore"] = "Stat score";
L["TooltipMessage_WithGem"] = "with gem";
L["TooltipMessage_WithProcAverage"] = "with proc average";
L["TooltipMessage_WithUseAverage"] = "with use on cd avg";
L["TooltipMessage_Offhand"] = "%s (offhand)";
L["Crafting_Upgrade_Label"] = "Stage %d of %d";
L["Empowered_Upgrade_Label"] = "Empowered";
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
L["Options_ForceSelectedGemStat_Label"] = "Force selected gem stat/value";
L["Options_ForceSelectedGemStat_Tooltip"] = "If an item has a gem inserted in a socket, do not use that gem for calculation, but instead use the best gem available based on Gem level and Gem stat in spec config";
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
L["Options_NormalizeWeights_Label"] = "Normalize values";
L["Options_NormalizeWeights_Tooltip"] = "Adjust values for calculation so that primary stat is 1.0 and other stats are scaled to it";
L["Error_MultiplePrimaryStatsSelected"] = "You can only select one primary stat (agi, str or int)";
L["Options_Compare_Label"] = "Compare percentage gain to";
L["Options_Compare_Tooltip"] = "Whether to display the percent value in tooltips relative to equipped item or total character score.";
L["Options_Compare_Item"] = "Equipped item score";
L["Options_Compare_Character"] = "Total character score";
L["Options_Percentage_Label"] = "Calculate percentage as";
L["Options_Percentage_Tooltip"] = "Whether to display the percent value in tooltips as percentage change or percentage difference. ";
L["Options_Percentage_Change"] = "Change";
L["Options_Percentage_Difference"] = "Difference";
L["Options_ShowStatsPane_Label"] = "Show total score";
L["Options_ShowStatsPane_Tooltip"] = "Whether to show total score on character tab";
L["Options_ShowUpgrades_Label"] = "Show upgrades";
L["Options_ShowUpgrades_Tooltip"] = "Whether to show score for upgrades of upgradable items (crafted, baleful)";
L["Options_GetStats_Label"] = "Get stats from";
L["Options_GetStats_Tooltip"] = "Whether to get stats from wow api call (GetItemStats()) or parse them from tooltip. Parsing from tooltip has some advantages (for example allows you to have greyed out stats calculated for offspec), but requires support for culture you are using.";
L["Options_GetStats_WoWAPI"] = "WoW API";
L["Options_GetStats_ParseTooltip"] = "Item Tooltip";
L["Warning"] = "Warning";
L["CharacterPane_CM_Tooltip"] = "Total score doesn't factor in reduced item level in CM mode dungeons";
L["CharacterPane_Tooltip_Title"] = "Weighted stat score";
L["CharacterPane_Tooltip_Title_Text"] = "Total weighted stat score for all currently equipped items for %s spec";

-- +<value> <stat>; <value> Armor; (<value> damage per second)
L["Matcher_StatTooltipParser_Stat"] = "^%+([%d,%. ]+) ([%a ]+)$";
L["Matcher_StatTooltipParser_Stat_ArgOrder"] = "value stat";
L["Matcher_StatTooltipParser_Armor"] = "^(%d+) (RESISTANCE0_NAME)$";
L["Matcher_StatTooltipParser_Armor_ArgOrder"] = "value stat";
L["Matcher_StatTooltipParser_DPS"] = "^%(([%d,%. ]+) ([%a ]+)%)$";
L["Matcher_StatTooltipParser_DPS_ArgOrder"] = "value stat";

L["Matcher_Precheck_Equip"] = "^Equip:";
L["Matcher_Precheck_Use"] = "^Use:";
L["Matcher_Precheck_BonusArmor"] = "BONUS_ARMOR$";

L["Matcher_Partial_CdMin"] = "(%d+) Min";
L["Matcher_Partial_CdSec"] = "(%d+) Sec";

-- Use: Increases your <stat> by <value> for <dur> sec. (<cd> Min Cooldown)
-- Use: Increases <stat> by <value> for <dur> sec. (<cdm> Min <cds> Sec Cooldown)
-- Use: Grants <value> <stat> for <dur> sec. (<cdm> Min <cds> Sec Cooldown)
-- Equip: Your attacks have a chance to grant <value> <stat> for <dur> sec.  (Approximately <procs> procs per minute)
-- Equip: Each time your attacks hit, you have a chance to gain <value> <stat> for <dur> sec. (<chance>% chance, <cd> sec cooldown)
-- Equip: Your attacks have a chance to grant you <value> <stat> for <dur> sec. (<chance>% chance, <cd> sec cooldown)
-- Insignia of Conquest - Equip: When you deal damage you have a chance to gain <value> <stat> for <dur> sec.
-- Solium Band - Equip: Your attacks have a chance to grant Archmage's Incandescence for <duration> sec.  (Approximately <procs> procs per minute)
-- +<value> Bonus Armor
-- Equip: Your (attacks/melee attacks/spells) have a chance to trigger <effect> for <dur> sec. While <effect> is active, you gain <value> <stat> every <tick> sec, stacking up to <maxstack> times.  (Approximately <procs> procs per minute)
-- Equip: When you heal or deal damage you have a chance to increase your Strength, Agility, or Intellect by <value> for <duration> sec.  Your highest stat is always chosen.

L["AlternativeStatDisplayNames_Crit"] = "";
L["AlternativeStatDisplayNames_Spellpower"] = "spellpower";

L["Matcher_RPPM_Pattern"] = "^Equip: Your [%a ]- have a chance to grant ([%d,%. ]+) ([%a ]-) for (%d+) sec%.  %(Approximately ([%d%.]+) procs per minute%)$";
L["Matcher_RPPM_ArgOrder"] = "value stat duration ppm";

L["Matcher_RPPM2_Pattern"] = "";
L["Matcher_RPPM2_ArgOrder"] = "";

L["Matcher_RPPM3_Pattern"] = "";
L["Matcher_RPPM3_ArgOrder"] = "";

L["Matcher_RPPM4_Pattern"] = "";
L["Matcher_RPPM4_ArgOrder"] = "";

L["Matcher_SoliumBand_Pattern"] = "^Equip: Your attacks have a chance to grant Archmage's ?(%a-) Incandescence for (%d+) sec%.  %(Approximately ([%d%.]+) procs per minute%)$";
L["Matcher_SoliumBand_ArgOrder"] = "type duration ppm";
L["Matcher_SoliumBand_BuffType_Greater"] = "Greater";

L["Matcher_ICD_Pattern"] = "^Equip: Each time your attacks hit, you have a chance to gain ([%d,%. ]+) ([%a ]-) for (%d+) sec%.  %((%d+)%% chance, (%d+) sec cooldown%)$";
L["Matcher_ICD_ArgOrder"] = "value stat duration chance cd";

L["Matcher_ICD2_Pattern"] = "^Equip: Your attacks have a chance to grant you ([%d,%. ]+) ([%a ]-) for (%d+) sec%.  %((%d+)%% chance, (%d+) sec cooldown%)$";
L["Matcher_ICD2_ArgOrder"] = "value stat duration chance cd";

L["Matcher_ICD3_ArgOrder"] = "";
L["Matcher_ICD3_Pattern"] = "";

L["Matcher_InsigniaOfConquest_Pattern"] = "^Equip: When you deal damage you have a chance to gain ([%d,%. ]+) ([%a ]-) for (%d+) sec%.";
L["Matcher_InsigniaOfConquest_ArgOrder"] = "value stat duration";

L["Matcher_InsigniaOfConquest2_ArgOrder"] = "";
L["Matcher_InsigniaOfConquest2_Pattern"] = "";

L["Matcher_Use_Pattern"] = "^Use: Increases y?o?u?r? ?([%a ]-) by ([%d,%. ]+) for (%d+) sec%. %(([%d%a ]-) Cooldown%)$";
L["Matcher_Use_ArgOrder"] = "stat value duration cd";

L["Matcher_Use2_Pattern"] = "^Use: Grants ([%d,%. ]+) ([%a ]-) for (%d+) sec%. %(([%d%a ]-) Cooldown%)$";
L["Matcher_Use2_ArgOrder"] = "value stat duration cd";

L["Matcher_Use3_ArgOrder"] = "";
L["Matcher_Use3_Pattern"] = "";

L["Matcher_Use4_ArgOrder"] = "";
L["Matcher_Use4_Pattern"] = "";

L["Matcher_BonusArmor_Pattern"] = "^%+(%d+) ?BONUS_ARMOR$";
L["Matcher_BonusArmor_ArgOrder"] = "value";

L["Matcher_BlackhandTrinket_Pattern"] = "^Equip: Your [%a ]- have a chance to trigger [%a' ]- for (%d+) sec.  While [%a' ]- is active, you gain ([%d,%. ]+) ([%a ]-) every ([%d,%. ]+) sec, stacking up to ([%d,%. ]+) times%.  %(Approximately ([%d%.]+) procs per minute%)$";
L["Matcher_BlackhandTrinket_ArgOrder"] = "duration value stat tick maxstack ppm";

L["Matcher_BlackhandTrinket2_ArgOrder"] = "";
L["Matcher_BlackhandTrinket2_Pattern"] = "";

L["Matcher_BlackhandTrinket3_ArgOrder"] = "";
L["Matcher_BlackhandTrinket3_Pattern"] = "";

L["Matcher_StoneOfFire_Pattern"] = "^Equip: When you heal or deal damage you have a chance to increase your Strength, Agility, or Intellect by ([%d,%. ]+) for (%d+) sec%.  Your highest stat is always chosen%.$";
L["Matcher_StoneOfFire_ArgOrder"] = "value duration";