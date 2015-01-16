local SWS_ADDON_NAME, StatWeightScore = ...;
StatWeightScore = LibStub("AceAddon-3.0"):NewAddon(StatWeightScore, SWS_ADDON_NAME);

local version = GetAddOnMetadata(SWS_ADDON_NAME, "Version");
local versionReplacement = "@".."project-version".."@";
if(version == versionReplacement) then
    version = "DEV"
end

StatWeightScore.Version = version;

local L = LibStub("AceLocale-3.0"):GetLocale(SWS_ADDON_NAME);

StatWeightScore.L = L;

function StatWeightScore:OnInitialize()
    self.Utils.Print(string.format(L["WelcomeMessage"], self.Version));
end