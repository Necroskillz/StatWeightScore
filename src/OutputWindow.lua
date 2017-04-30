local SWS_ADDON_NAME, StatWeightScore = ...;
local OutputWindowModule = StatWeightScore:NewModule(SWS_ADDON_NAME.."OutputWindow");

local AceGUI = LibStub("AceGUI-3.0");

function OutputWindowModule:OnInitialize()
    self.window = AceGUI:Create("Window");
    self.window:EnableResize(false);
    self.window:SetHeight(440);
    self.window:SetWidth(680);
    self.window:Hide();
    self.window:SetTitle("Output");
    self.content = AceGUI:Create("MultiLineEditBox");
    self.content:DisableButton();
    self.content:SetLabel("");
    self.content:SetHeight(400);
    self.content:SetWidth(650);
    self.window:AddChild(self.content);
end

function OutputWindowModule:Show(text)
    self.window:Show();
    self.content:SetText(text);
    self.content:SetFocus();
    self.content.editBox:HighlightText();
end
