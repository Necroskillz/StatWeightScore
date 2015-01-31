local SWS_ADDON_NAME, StatWeightScore = ...;
StatWeightScore = LibStub("AceAddon-3.0"):NewAddon(StatWeightScore, SWS_ADDON_NAME, "AceEvent-3.0");

local AceDB = LibStub("AceDB-3.0");

local version = GetAddOnMetadata(SWS_ADDON_NAME, "Version");
local versionReplacement = "@".."project-version".."@";
if(version == versionReplacement) then
    version = "DEV"
end

StatWeightScore.Version = version;

local L = LibStub("AceLocale-3.0"):GetLocale(SWS_ADDON_NAME);

StatWeightScore.L = L;

function StatWeightScore:OnInitialize()
    local db = AceDB:New(SWS_ADDON_NAME.."DB", self.Defaults);
    StatWeightScore.db = db;

    self.Utils.Print(string.format(L["WelcomeMessage"], self.Version));
end