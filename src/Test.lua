local SWS_ADDON_NAME, StatWeightScore = ...;
local TestSuite = StatWeightScore:NewModule(SWS_ADDON_NAME.."Test");

local ScoreModule;
local ScanningTooltipModule;
local Utils;
local L;

function TestSuite:OnInitialize()
    ScoreModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."Score");
    ScanningTooltipModule = StatWeightScore:GetModule(SWS_ADDON_NAME.."ScanningTooltip");
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
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = "92",
            ["2"] = ITEM_MOD_CRIT_RATING_SHORT
        }
    };

    self.Tests["Stat match Multistrike"] = {
        type = "matcher",
        itemId = 113877,
        line = 9,
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = "89",
            ["2"] = ITEM_MOD_CR_MULTISTRIKE_SHORT
        }
    };

    self.Tests["Stat match Agility"] = {
        type = "matcher",
        itemId = 113877,
        line = 6,
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = "136",
            ["2"] = ITEM_MOD_AGILITY_SHORT
        }
    };

    self.Tests["Stat match Stamina"] = {
        type = "matcher",
        itemId = 113877,
        line = 7,
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = "204",
            ["2"] = ITEM_MOD_STAMINA_SHORT
        }
    };

    self.Tests["Stat match Mastery"] = {
        type = "matcher",
        itemId = 113966,
        line = 9,
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = "176",
            ["2"] = ITEM_MOD_MASTERY_RATING_SHORT
        }
    };

    self.Tests["Stat match Haste"] = {
        type = "matcher",
        itemId = 113930,
        line = 8,
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = "112",
            ["2"] = ITEM_MOD_HASTE_RATING_SHORT
        }
    };

    self.Tests["Stat match Versatility"] = {
        type = "matcher",
        itemId = 113930,
        line = 9,
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = "127",
            ["2"] = ITEM_MOD_VERSATILITY
        }
    };

    self.Tests["Stat match Intellect"] = {
        type = "matcher",
        itemId = 113988,
        line = 7,
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = "242",
            ["2"] = ITEM_MOD_INTELLECT_SHORT
        }
    };

    self.Tests["Stat match Spell Power"] = {
        type = "matcher",
        itemId = 113988,
        line = 10,
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = Utils.FormatNumber(1389),
            ["2"] = ITEM_MOD_SPELL_POWER_SHORT
        }
    };

    self.Tests["Stat match Strength"] = {
        type = "matcher",
        itemId = 113886,
        line = 7,
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = "242",
            ["2"] = ITEM_MOD_STRENGTH_SHORT
        }
    };

    self.Tests["Stat match Bonus Armor"] = {
        type = "matcher",
        itemId = 113923,
        line = 8,
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = "91",
            ["2"] = BONUS_ARMOR
        }
    };

    self.Tests["Stat match Spirit"] = {
        type = "matcher",
        itemId = 113957,
        line = 9,
        matcherSelector = function (matcher)
            return matcher.Stats.Stat;
        end,
        expectedArgs = {
            ["1"] = "73",
            ["2"] = ITEM_MOD_SPIRIT_SHORT
        }
    };

    self.Tests["Stat match Armor"] = {
        type = "matcher",
        itemId = 113930,
        line = 5,
        matcherSelector = function (matcher)
            return matcher.Stats.Armor;
        end,
        expectedArgs = {
            ["1"] = "123",
            ["2"] = RESISTANCE0_NAME
        }
    };

    self.Tests["Stat match Dps"] = {
        type = "matcher",
        itemId = 113966,
        line = 6,
        matcherSelector = function (matcher)
            return matcher.Stats.Dps;
        end,
        expectedArgs = {
            ["1"] = Utils.FormatNumber(435.5, 2),
            ["2"] = ITEM_MOD_DAMAGE_PER_SECOND_SHORT
        }
    };

    self.Tests["RPPM proc match"] = {
        type = "matcher",
        itemId = 113612,
        line = 8,
        matcherName = "RPPM",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1743),
            ["stat"] = ITEM_MOD_CR_MULTISTRIKE_SHORT,
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
            ["value"] = Utils.FormatNumber(2004),
            ["stat"] = ITEM_MOD_SPIRIT_SHORT,
            ["duration"] = "10",
            ["ppm"] = Utils.FormatNumber(0.92, 2)
        }
    };

    self.Tests["Solium Band proc match"] = {
        type = "matcher",
        itemId = 118302,
        line = 11,
        matcherName = "SoliumBand",
        expectedArgs = {
            ["type"] = "",
            ["duration"] = "10",
            ["ppm"] = Utils.FormatNumber(0.92, 2)
        }
    };

    self.Tests["Solium Band greater proc match"] = {
        type = "matcher",
        itemId = 118307,
        line = 11,
        matcherName = "SoliumBand",
        expectedArgs = {
            ["type"] = L["Matcher_SoliumBand_BuffType_Greater"],
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

    self.Tests["InsigniaOfConquest proc match"] = {
        type = "matcher",
        itemId = 111223,
        line = 8,
        matcherName = "InsigniaOfConquest",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(867),
            ["stat"] = ITEM_MOD_AGILITY_SHORT,
            ["duration"] = "20"
        }
    };

    self.Tests["BlackhandTrinket agi proc match"] = {
        type = "matcher",
        itemId = 113985,
        line = 8,
        matcherName = "BlackhandTrinket",
        expectedArgs = {
            ["duration"] = "10",
            ["value"] = "137",
            ["stat"] = ITEM_MOD_CRIT_RATING_SHORT,
            ["tick"] = Utils.FormatNumber(0.5, 2),
            ["maxstack"] = "20",
            ["ppm"] = Utils.FormatNumber(0.92, 2)
        }
    };

    self.Tests["BlackhandTrinket str proc match"] = {
        type = "matcher",
        itemId = 113983,
        line = 8,
        matcherName = "BlackhandTrinket",
        expectedArgs = {
            ["duration"] = "10",
            ["value"] = "137",
            ["stat"] = ITEM_MOD_CR_MULTISTRIKE_SHORT,
            ["tick"] = Utils.FormatNumber(0.5, 2),
            ["maxstack"] = "20",
            ["ppm"] = Utils.FormatNumber(0.92, 2)
        }
    };

    self.Tests["BlackhandTrinket int proc match"] = {
        type = "matcher",
        itemId = 113984,
        line = 8,
        matcherName = "BlackhandTrinket",
        expectedArgs = {
            ["duration"] = "10",
            ["value"] = "137",
            ["stat"] = ITEM_MOD_CR_MULTISTRIKE_SHORT,
            ["tick"] = Utils.FormatNumber(0.5, 2),
            ["maxstack"] = "20",
            ["ppm"] = Utils.FormatNumber(0.92, 2)
        }
    };

    self.Tests["BlackhandTrinket sta proc match"] = {
        type = "matcher",
        itemId = 113987,
        line = 8,
        matcherName = "BlackhandTrinket",
        expectedArgs = {
            ["duration"] = "10",
            ["value"] = "137",
            ["stat"] = ITEM_MOD_HASTE_RATING_SHORT,
            ["tick"] = Utils.FormatNumber(0.5, 2),
            ["maxstack"] = "20",
            ["ppm"] = Utils.FormatNumber(0.92, 2)
        }
    };

    self.Tests["BlackhandTrinket spi proc match"] = {
        type = "matcher",
        itemId = 113986,
        line = 8,
        matcherName = "BlackhandTrinket",
        expectedArgs = {
            ["duration"] = "10",
            ["value"] = "137",
            ["stat"] = ITEM_MOD_HASTE_RATING_SHORT,
            ["tick"] = Utils.FormatNumber(0.5, 2),
            ["maxstack"] = "20",
            ["ppm"] = Utils.FormatNumber(0.92, 2)
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

    self.Tests["ApiCorrection match Bonus Armor"] = {
        type = "matcher",
        itemId = 113923,
        line = 8,
        matcherName = "BonusArmor",
        expectedArgs = {
            ["value"] = "91",
        }
    };

    self.Tests["Use match"] = {
        type = "matcher",
        itemId = 118876,
        line = 8,
        matcherName = "Use",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1467),
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
        matcherName = "Use2",
        expectedArgs = {
            ["value"] = Utils.FormatNumber(1537),
            ["stat"] = ITEM_MOD_CR_MULTISTRIKE_SHORT,
            ["duration"] = "20",
            ["cd"] = function(value)
                local pattern = ScoreModule.Matcher.Partial["cdmin"];
                return value:match(pattern) == "2", pattern.." with capture = 2";
            end
        }
    };

    self.Tests["Use2 1 min 30 sec match"] = {
        type = "matcher",
        itemId = 110013,
        line = 8,
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
        print(len);
        for i = 1, len do
            local partialMatch, partialLen;

            Utils.Try(function()
                local subpattern = pattern:sub(1, len - i);
                match = Utils.Pack(line:match(subpattern));
                if(match) then
                    partialMatch = match;
                    partialLen = len - i;
                end
            end);

            if(partialMatch) then
                return false, partialMatch, partialLen;
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

        if(expected) then
            if(type(expected) == "function") then
                valueMatch, expectedError = expected(match[i]);
            else
                valueMatch = expected:lower() == match[i]:lower();
                expectedError = expected;
            end
        end

        if(expected and valueMatch) then
            color = GREEN_FONT_COLOR_CODE;
        else
            color = RED_FONT_COLOR_CODE;
            nomatch = " (expected: "..(expectedError or "N/A")..")";
            argsMatch = false;
        end

        result = result..name..": "..color..match[i].."|r"..nomatch.." | ";
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

                if(test.matcherSelector) then
                    local matcher = test.matcherSelector(ScoreModule.Matcher);
                    pattern = matcher.Pattern;
                    argOrder = matcher.ArgOrder;
                elseif(test.matcherName) then
                    local matcher = ScoreModule.Matcher.Matchers[test.matcherName];
                    pattern = matcher.Pattern;
                    argOrder = matcher.ArgOrder;
                end

                local _, link = GetItemInfo(test.itemId);
                if(not link) then
                    result.message = string.format("item with id %d is not cached. rerun tests.", test.itemId);
                else
                    local line = GetTooltipLine(link, test.line);
                    if(line) then
                        local success, match, failLen = TryRegexMatch(line, pattern);

                        if(success) then
                            result.status = "OK";
                        else
                            result.status = "FAIL";
                            result.message = string.format("- failed pattern match on item %s tooltip line %d at position %d: '%s' ", link, test.line, failLen, GREEN_FONT_COLOR_CODE..(match == nil and "" or line:sub(1, failLen - 1))..RED_FONT_COLOR_CODE..line:sub(failLen).."|r");
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