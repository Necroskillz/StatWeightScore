# Change log

## 7.6.2 - 9 Jul 2017
* Fixed another issue with equipments sets that were renamed or removed
* Fixed obliterum upgrade paths
* Fixed an issue for russian language where check if a class can use plate/mail/leather/cloth item always failed (the scores of such items were always grey even if the class could use the item)

## 7.6.1 - 20 May 2017
* Fixed an issue where old stat weights were still used after import
* Added checks that should prevent an equipment manager related error from happening

## 7.6.0 - 30 Apr 2017
* Added compact mode and color/icon of spec ([submitted by elaundar](https://wow.curseforge.com/projects/stat-weight-score/issues/75))
* Added command for generating SimulationCraft input for trinket pairs you own. ([documentation](https://wow.curseforge.com/projects/stat-weight-score/pages/main/simulation-craft-import))
* Removed SimulationCraft xml import

## 7.5.3 - 1 Apr 2017
* Updated to 7.2

## 7.5.2 - 12 Feb 2017
* Added support for additional Class and Spec parameters in pawn string
* Renamed Ask Mr. Robot share to Text import and export, so it's not confusing since Ask Mr. Robot doesn't use that format any more

## 7.5.1 - 22 Jan 2017
* Added 9th and 10th stage of Obliterum upgrade
* Added support for multiple sockets

## 7.5.0 - 1 Nov 2016
* Added 8th stage of Obliterum upgrade
* Artifact weapon offhand score is now 0, and offhand score is added to mainhand score
* Added movement speed

## 7.4.0 - 31 Oct 2016
* Updated to 7.1

## 7.3.3 - 24 Sep 2016
* Attempted to fix the Warglaives crash again

## 7.3.2 - 23 Sep 2016
* Release to update translated Warglaives string from LibBabble-Inventory
* Won't crash if Warglaives are not translated

## 7.3.1 - 18 Sep 2016
* Fixed a bug where a equipped ring or trinket would compare to the other equipped ring or trinket

## 7.3.0 - 17 Sep 2016
* Added upgrade paths for Order Hall Items
* Made import from Pawn string default (since there is a Pawn string directly on simulation craft result page)
* Fixed equipment set display and issue that cause an error when assigned equipment set was removed or deleted

## 7.2.3 - 11 Sep 2016
* Fixed legion gem stat values

## 7.2.2 - 10 Sep 2016
* Fixed and issue that cause error when mousing over bags

## 7.2.1 - 10 Sep 2016
* Fixed some issues introduced in 7.2.0

## 7.2.0 - 10 Sep 2016
* Removed all WoD stuff (CM mode, all WoD upgrades, tier 17, spellpower, bonus armor, some trinket/ring matchers...)
* Added legion gems (+ option to suggest Saber's Eye if you don't have it equipped or comparing to the same slot that has it if both items have sockets)
* Added stat weight score to World Quest tooltip
* Added Obliterum upgrades

## 7.1.1 - 13 Aug 2016
* Fix missing localization strings

## 7.1.0 - 13 Aug 2016
* Added option to associate equipment set with a spec (items are then compared to items in that equipment set instead of currently equipped items)
* Added support for Demon Hunters
* Added upgrade path invasion weapons
* Fixed upgrade path comparison tooltip on equipped items

## 7.0.2 - 24 Jul 2016
* Remove old stats (multistrike, bonus armor) from specs on startup to prevent errors
* Added polearm as a valid Hunter weapon

## 7.0.1 - 23 Jul 2016
* Fixed an error that occurs for some items

## 7.0.0 - 22 Jul 2016
* Updated for Legion
* Because of character screen changes total score was moved to /sws character_score instead of character pane.
* Fixed upgrades so they display difference also when equipped

## 1.14.0 - 19 Dec 2015
* Crafted/baleful items now show scores for valor upgrades for their last stage (Stage 6/Empowered)
* Fixed crafting upgrade paths (turns out they are different for weapons and armor). This caused some stages of crafted items to not show scores for future stages.

## 1.13.1 - 9 Dec 2015
* Hotfix for 1.13.0 bug

## 1.13.0 - 8 Dec 2015
* Added support for dreanor valor upgrades

## 1.12.2 - 31 Oct 2015
* Improved baleful gear upgrade detection

## 1.12.1 - 30 Oct 2015
* Fixed an issue with uppercase/lowercase libs directory on file system on case sensitive OS

## v1.12.0 - 29 Oct 2015
* Added scores for all future stages of upgradable items (crafted and baleful)
* Added legendary ring to always compare to past stages of the ring if equipped (rather than the weaker ring)

## v1.11.1 - 22 Aug 2015
* Fixed formatting of ask mr robot export (round to 2 decimal places)

## v1.11.0 - 2 Aug 2015
* Some Korean patterns should be optimized and fixed
* (_Curse is now used as a distribution repository_)

## v1.10.0 - 24 Jul 2015
* Added leech stat
* (_AddOn will use valid [semver](http://semver.org/) version from now on_)
* (_Added some developer tooling_)

## v1.9.2 - 11 Jul 2015
* Updated Ask Mr. Robot import

## v1.9.1 - 6 Jul 2015
* Bug fixes

## v1.9 - 5 Jul 2015
* Added +75 gems

## v1.8 - 25 Jun 2015
* Updated to 6.2
* Adjusted for 6.2 item link change

## v1.7 - 1 May 2015
* koKR is now supported
* Added support for warriors with two-handed dual wield
* Added import from Pawn string

## v1.6 - 7 Apr 2015
* frFR is now fully supported, including proc/use calculation - french users can now switch to getting item stats from the tooltip instead of WoW Api in /sws config
* Fixed a bug where want was compared to the offhand instead of main hand
* New feature for developers and translators to test matching of use/proc/stat patterns. Test suite is ran by **/sws test**

## v1.5.3 - 28 Mar 2015
* Fixed parsing of stats above 1000

## v1.5.2 - 27 Mar 2015
* Fixed an onload error

## v1.5.1 - 27 Mar 2015
* Fixed bonus armor correction calculation for WoW API

## v1.5 - 27 Mar 2015
* Support for ilvl 715 legendary ring, and crafted trinket Stone of Fire
* Option to select which way to get item stats (WoW API - GetItemStats or parse from tooltip). Parsing from tooltip allows you to have "greyed out" stats calculated for you offspec (by default enabled for enUS culture users, because it has a dependency on localization). Others still use WoW API call.

## v1.4.1 - 15 Mar 2015
* Added Avoidance stat
* Bugfixes

## v1.4 - 28 Feb 2015
* Total weighted stat score of all equipped items is now calculated and displayed on character stats pane (this can be disabled in options by unchecking **Show total score**)
* By default, the percentage difference in score is now calculated against total score, rather than equipped item. This better shows you how big of an upgrade an item is. _(For example an item that is (+50 +20%) better than current item adds less score than an item that is (+100 +10%), even though the percentage is bigger and that can be misleading. Comparison against total score would show something like (+50 +1%) and (+100 +2%))_. If you preferred the way it was before, you can change it in options by selecting **Compare percentage gain to** - Equipped item score.
* You can now select whether to display percentage as change or difference (http://en.wikipedia.org/wiki/Relative_change_and_difference). See **Calculate percentage as** in options.
* Two handed weapons are now compared to Main hand + Offhand score
