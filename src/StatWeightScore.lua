local SWS_ADDON_NAME, StatWeightScore = ...;
StatWeightScore = LibStub("AceAddon-3.0"):NewAddon(StatWeightScore, SWS_ADDON_NAME, "AceEvent-3.0", "AceConsole-3.0");

local OptionsModule;

local version = GetAddOnMetadata(SWS_ADDON_NAME, "Version");
local versionReplacement = "@".."project-version".."@";
if(version == versionReplacement) then
    version = "DEV"
end

StatWeightScore.Version = version;

local L = LibStub("AceLocale-3.0"):GetLocale(SWS_ADDON_NAME);

StatWeightScore.L = L;

function StatWeightScore:OnInitialize()
    OptionsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Options");

    self:Print(string.format(L["WelcomeMessage"], self.Version));

    OptionsModule:InitializeDatabase();
end

StatWeightScore:SetDefaultModuleLibraries("AceEvent-3.0");