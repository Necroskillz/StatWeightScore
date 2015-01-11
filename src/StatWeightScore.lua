local SWS_ADDON_NAME, StatWeightScore = ...;
StatWeightScore = LibStub("AceAddon-3.0"):NewAddon(StatWeightScore, SWS_ADDON_NAME);

StatWeightScore.Version = "0.5";

StatWeightScore_Settings = nil; -- legacy

local L = LibStub("AceLocale-3.0"):GetLocale(SWS_ADDON_NAME);

StatWeightScore.L = L;

function StatWeightScore:OnInitialize()
    self.Utils.Print(string.format(L["WelcomeMessage"], self.Version));
end