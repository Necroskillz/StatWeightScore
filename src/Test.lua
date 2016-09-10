local SWS_ADDON_NAME, StatWeightScore = ...;
local TestSuite = StatWeightScore:NewModule(SWS_ADDON_NAME.."Test");

local ScoreModule;
local ScanningTooltipModule;
local StatsModule;
local Utils;
local L;

function TestSuite:OnInitialize()
    ScoreModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Score");
    ScanningTooltipModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ScanningTooltip");
    StatsModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Stats");
    Utils = StatWeightScore.Utils;
    L = StatWeightScore.L;
end

TestSuite.Tests = {};

function TestSuite:CreateTests()
    wipe(self.Tests);

    self.Tests["Stat match Crit"] = {
        type = "matcher",
        itemId = 113877,
        line = 8,
        statMatcherName = "Stat",
        expectedArgs = {
            ["value"] = "92",
            ["stat"] = ITEM_MOD_CRIT_RATING_SHORT
        }
    };

    self.Tests["Stat match Agility"] = {
        type = "matcher",
        itemId = 113877,
        line = 6,
        statMatcherName = "Stat",
        expectedArgs = {
            ["value"] = "136",
            ["stat"] = ITEM_MOD_AGILITY_SHORT
        }
    };

    self.Tests["Stat match Stamina"] = {
        type = "matcher",
        itemId = 113877,
        line = 7,
        statMatcherName = "Stat",
        expectedArgs = {
            ["value"] = "204",
            ["stat"] = ITEM_MOD_STAMINA_SHORT
        }
    };

    self.Tests["Stat match Mastery"] = {
        type = "matcher",
        itemId = 113966,
        line = 10,
        statMatcherName = "Stat",
        expectedArgs = {
            ["value"] = "176",
            ["stat"] = ITEM_MOD_MASTERY_RATING_SHORT
        }
    };

    self.Tests["Stat match Haste"] = {
        type = "matcher",
        itemId = 113930,
        line = 8,
        statMatcherName = "Stat",
        expectedArgs = {
            ["value"] = "112",
            ["stat"] = ITEM_MOD_HASTE_RATING_SHORT
        }
    };

    self.Tests["Stat match Versatility"] = {
        type = "matcher",
        itemId = 113930,
        line = 9,
        statMatcherName = "Stat",
        expectedArgs = {
            ["value"] = "127",
            ["stat"] = ITEM_MOD_VERSATILITY
        }
    };

    self.Tests["Stat match Intellect"] = {
        type = "matcher",
        itemId = 113988,
        line = 7,
        statMatcherName = "Stat",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1565),
            ["stat"] = ITEM_MOD_INTELLECT_SHORT
        }
    };

    self.Tests["Stat match Strength"] = {
        type = "matcher",
        itemId = 113886,
        line = 7,
        statMatcherName = "Stat",
        expectedArgs = {
            ["value"] = "242",
            ["stat"] = ITEM_MOD_STRENGTH_SHORT
        }
    };

    self.Tests["Stat match Armor"] = {
        type = "matcher",
        itemId = 113930,
        line = 5,
        statMatcherName = "Armor",
        expectedArgs = {
            ["value"] = "123",
            ["stat"] = RESISTANCE0_NAME
        }
    };

    self.Tests["Stat match Dps"] = {
        type = "matcher",
        itemId = 113966,
        line = 6,
        statMatcherName = "DPS",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(435.5, 2),
            ["stat"] = ITEM_MOD_DAMAGE_PER_SECOND_SHORT
        }
    };

    self.Tests["RPPM haste proc match"] = {
        type = "matcher",
        itemId = 118114,
        line = 8,
        matcherName = "RPPM",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1603),
            ["stat"] = ITEM_MOD_HASTE_RATING_SHORT,
            ["duration"] = "10",
            ["ppm"] = Utils.FormatNumber(0.92, 2)
        }
    };

    self.Tests["[frFR] RPPM crit proc match"] = {
        type = "matcher",
        itemId = 113645,
        line = 8,
        locale = "frFR";
        matcherName = "RPPM2",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1395),
            ["stat"] = ITEM_MOD_CRIT_RATING_SHORT,
            ["duration"] = "10",
            ["ppm"] = Utils.FormatNumber(0.92, 2)
        }
    };

    self.Tests["RPPM beneficial proc match"] = {
        type = "matcher",
        itemId = 119192,
        line = 8,
        matcherName = "RPPM",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1603),
            ["stat"] = ITEM_MOD_VERSATILITY,
            ["duration"] = "10",
            ["ppm"] = Utils.FormatNumber(0.92, 2)
        }
    };

    self.Tests["ICD proc match"] = {
        type = "matcher",
        itemId = 112318,
        line = 9,
        matcherName = "ICD",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1396),
            ["stat"] = ITEM_MOD_CRIT_RATING_SHORT,
            ["duration"] = "20",
            ["chance"] = "15",
            ["cd"] = "115"
        }
    };

    self.Tests["ICD2 proc match"] = {
        type = "matcher",
        itemId = 116824,
        line = 7,
        matcherName = "ICD2",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(472),
            ["stat"] = ITEM_MOD_AGILITY_SHORT,
            ["duration"] = "20",
            ["chance"] = "15",
            ["cd"] = "55"
        }
    };

    self.Tests["[frFR] ICD3 proc match"] = {
        type = "matcher",
        itemId = 112317,
        locale = "frFR";
        line = 8,
        matcherName = "ICD3",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1396),
            ["stat"] = ITEM_MOD_SPIRIT_SHORT,
            ["duration"] = "20",
            ["chance"] = "15",
            ["cd"] = "115"
        }
    };

    self.Tests["InsigniaOfConquest proc match"] = {
        type = "matcher",
        itemId = 111223,
        line = 8,
        matcherName = "InsigniaOfConquest",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(789),
            ["stat"] = ITEM_MOD_AGILITY_SHORT,
            ["duration"] = "20"
        }
    };

    self.Tests["StoneOfFire proc match"] = {
        type = "matcher",
        itemId = 122604,
        line = 9,
        matcherName = "StoneOfFire",
        expectedArgs = {
            ["duration"] = "15",
            ["value"] = Utils.FormatNumber(1414)
        }
    };

    self.Tests["Use match agi"] = {
        type = "matcher",
        itemId = 118876,
        line = 8,
        matcherName = "Use",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1048),
            ["stat"] = ITEM_MOD_AGILITY_SHORT,
            ["duration"] = "20",
            ["cd"] = function(value)
                local pattern = ScoreModule.Matcher.Partial["cdmin"];
                return value:match(pattern) == "2", pattern.." with capture = 2";
            end
        }
    };

    self.Tests["Use2 match"] = {
        type = "matcher",
        itemId = 113931,
        line = 8,
        locale = "!koKR";
        matcherName = "Use2",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1229),
            ["stat"] = ITEM_MOD_CRIT_RATING_SHORT,
            ["duration"] = "20",
            ["cd"] = function(value)
                local pattern = ScoreModule.Matcher.Partial["cdmin"];
                return value:match(pattern) == "2", pattern.." with capture = 2";
            end
        }
    };

    self.Tests["Use2 match mastery"] = {
        type = "matcher",
        itemId = 113834,
        line = 8,
        matcherName = "Use2",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1069),
            ["stat"] = ITEM_MOD_MASTERY_RATING_SHORT,
            ["duration"] = "20",
            ["cd"] = function(value)
                local pattern = ScoreModule.Matcher.Partial["cdmin"];
                return value:match(pattern) == "2", pattern.." with capture = 2";
            end
        }
    };

    self.Tests["[koKR] Use 1 min 30 sec match"] = {
        type = "matcher",
        itemId = 110013,
        line = 8,
        locale = "koKR";
        matcherName = "Use3",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1060),
            ["stat"] = ITEM_MOD_VERSATILITY,
            ["duration"] = "15",
            ["cd"] = function(value)
                local pattern = ScoreModule.Matcher.Partial["cdmin"];
                local pattern2 = ScoreModule.Matcher.Partial["cdsec"];
                return value:match(pattern) == "1" and  value:match(pattern2) == "30", pattern.." with capture = 1 and "..pattern2.." with capture = 30";
            end
        }
    };

    self.Tests["Use2 1 min 30 sec match"] = {
        type = "matcher",
        itemId = 110013,
        line = 8,
        locale = "!koKR";
        matcherName = "Use2",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1060),
            ["stat"] = ITEM_MOD_VERSATILITY,
            ["duration"] = "15",
            ["cd"] = function(value)
                local pattern = ScoreModule.Matcher.Partial["cdmin"];
                local pattern2 = ScoreModule.Matcher.Partial["cdsec"];
                return value:match(pattern) == "1" and  value:match(pattern2) == "30", pattern.." with capture = 1 and "..pattern2.." with capture = 30";
            end
        }
    };
end

local function GetTooltipLine(link, lineNumber)
    local tooltip = ScanningTooltipModule:ScanTooltip(link);

    local tooltipText = getglobal(tooltip:GetName().."TextLeft"..lineNumber);
    if(tooltipText) then
        return tooltipText:GetText();
    end
end

local function TryRegexMatch(line, pattern)
    local match = Utils.Pack(line:match(pattern));
    if(match) then
        return true, match
    else
        local len = pattern:len();
        for i = 1, len do
            local partialMatchStart, partialMatchEnd, partialMatch;

            Utils.Try(function()
                local subpattern = pattern:sub(1, len - i);
                match = Utils.Pack(line:match(subpattern));
                if(match) then
                    partialMatch = match;
                    partialMatchStart, partialMatchEnd = line:find(subpattern);
                end
            end);

            if(partialMatch) then
                return false, partialMatch, partialMatchStart, partialMatchEnd;
            end
        end

        return false, nil, 1;
    end
end

local function AssertMatchedArgs(match, argOrder, expectedArgs)
    local result = "Args: | ";
    local argsMatch = true;

    for i = 1, match.n do
        local name;

        if(argOrder and argOrder[i]) then
            name = argOrder[i];
        else
            name = tostring(i);
        end

        local color;
        local nomatch = "";

        local expected = expectedArgs[name];
        local valueMatch;
        local expectedError;
        local value = match[i];

        if(expected) then
            if(type(expected) == "function") then
                valueMatch, expectedError = expected(value);
            else
                if(name == "stat") then
                    local statInfo = StatsModule:GetStatInfoByDisplayName(value);
                    valueMatch = statInfo and statInfo.DisplayName:lower() == expected:lower();
                    expectedError = expected;
                else
                    valueMatch = expected:lower() == value:lower();
                    expectedError = expected;
                end
            end
        end

        if(expected and valueMatch) then
            color = GREEN_FONT_COLOR_CODE;
        else
            color = RED_FONT_COLOR_CODE;
            nomatch = " (expected: "..(expectedError or "N/A")..")";
            argsMatch = false;
        end

        result = result..name..": "..color..value.."|r"..nomatch.." | ";
    end

    return argsMatch, result;
end

function TestSuite:RunTests()
    self:CreateTests();

    local results = {};

    for name, test in pairs(self.Tests) do
        local result = {
            status = "NOT_RAN",
            message = "",
            name = name
        };

        Utils.Try(function()
            if(test.type == "matcher") then
                local pattern;
                local argOrder;

                local matcher;
                if(test.statMatcherName) then
                    matcher = ScoreModule.Matcher.Stats[test.statMatcherName];
                elseif(test.matcherName) then
                    matcher = ScoreModule.Matcher.Matchers[test.matcherName];
                end

                if(matcher) then
                    pattern = matcher.Pattern;
                    argOrder = matcher.ArgOrder;
                end

                local _, link = GetItemInfo(test.itemId);

                local locale = GetLocale();
                local localeIgnore = false;

                if(test.locale) then
                    local testLocales = Utils.SplitString(test.locale, "[^,]+");

                    for _, testLocale in pairs(testLocales) do
                        local neg = false;
                        if(testLocale:sub(1, 1) == "!") then
                            neg = true
                            testLocale = testLocale:sub(2);
                        end

                        if((not neg and testLocale ~= locale) or (neg and testLocale == locale)) then
                            localeIgnore = true;
                        end
                    end
                end

                if(localeIgnore) then
                    result.message = string.format("- test is ignored for %s", locale);
                elseif(not link) then
                    result.message = string.format("- item with id %d is not cached. rerun tests.", test.itemId);
                elseif(not pattern) then
                    result.status = "FAIL";
                    result.message = string.format("- pattern %s is not defined for current locale.", test.matcherName or test.statMatcherName);
                else
                    local line = GetTooltipLine(link, test.line);
                    if(line) then
                        local success, match, partialStart, partialEnd = TryRegexMatch(line, pattern);

                        if(success) then
                            result.status = "OK";
                        else
                            local matchedText = "";
                            if(match) then
                                if(partialStart > 1) then
                                    matchedText = RED_FONT_COLOR_CODE..line:sub(1, partialStart - 1);
                                end

                                matchedText = matchedText..GREEN_FONT_COLOR_CODE..line:sub(partialStart, partialEnd);

                                if(partialEnd < line:len()) then
                                    matchedText = matchedText..RED_FONT_COLOR_CODE..line:sub(partialEnd + 1);
                                end

                                matchedText = matchedText.."|r";
                            end

                            result.status = "FAIL";
                            result.message = string.format("- failed pattern match on item %s tooltip line %d at position %d: '%s' ", link, test.line, partialEnd, matchedText);
                        end

                        if(match) then
                            local argsMatch, argsMsg = AssertMatchedArgs(match, argOrder, test.expectedArgs);
                            result.message = result.message.."- "..argsMsg;

                            if(not argsMatch) then
                                result.status = "FAIL";
                                result.message = result.message..string.format(" failed arg match on item %s tooltip line %d: '%s'", link, test.line, line);
                            else
                                result.message = result.message..string.format(" successful arg match on item %s tooltip line %d: '%s'", link, test.line, line);
                            end
                        end
                    else
                        result.status = "FAIL";
                        result.message = string.format("Line %d not found in tooltip for item %s", test.line, link);
                    end
                end
            end
        end, function(err)
            result.status = "FAIL";
            result.message = err;
        end)

        table.insert(results, result);
    end

    wipe(self.Tests);

    return results;
end