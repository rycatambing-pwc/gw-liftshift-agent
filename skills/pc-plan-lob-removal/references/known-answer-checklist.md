# Known-answer checklist

Yes/no questions built from the failures users found by hand after earlier removals (`lob-removal-lessons.md`: the catalog of user-caught remnants and lessons 14–15). **Every answer must be YES.** A NO is a finding: report it with the file and the evidence, then fix it and ask again.

Run it in Phase 15 and again in Phase 19. Passing it does not prove the removal is complete. It proves that none of the mistakes already seen once has come back.

`<pat>` means the start-boundary patterns for the LOB code and every confirmed alternate (`\b<code>`, never `\b<code>\b`). `<cfg>` means `<config_root>`. Match on key names, not whole lines. The "Seen as" column names the file where the mistake first happened; yours may use another name, so look for the same shape.

## A. Would the build break?

| # | Question (must be YES) | How to check | Seen as |
|---|---|---|---|
| A1 | Does every typecode left in each file that lists typecodes for all LOBs in one block exist in its typelist? | Read the file fresh; check each remaining code against `RuleContextDefinitionKey.ttx` | `UnderwriterEvaluatorTriggeringPoint_Ext.gs` broke three times |
| A2 | Does a grep for each deleted constant, across the whole codebase, return zero? | `git grep -nE '\b<CONSTANT>' -- <cfg>` for every constant removed | `EntityMetadataUtil.gs`, `AccountHelper_Ext.gs`, `CovTermEnhancementDgc.gsx`, a PCF using a deleted constant |
| A3 | Is every edited Gosu file free of orphaned `{` `}`, dangling `else` and empty blocks? | Read each edited file after the edit | `SpecialCasesClauseLoadGenerator.gs` |
| A4 | Were dead display-key references removed rather than renamed to another key? | Review the diff for edits that change a key instead of deleting the reference | a PCF and a validation class that pointed at keys that did not exist |

## B. Would the server fail to start?

| # | Question (must be YES) | How to check | Seen as |
|---|---|---|---|
| B1 | Does every REST API schema file (`integration/**/*.schema.json`) have zero removed types and properties? | `git grep -nE '<pat>' -- '*.schema.json'` | a removed typelist still named in a schema |
| B2 | Does every entry in `systables.xml`, `systables.CUST.xml` and every other `systables.*.xml` point to a file that exists? | List each registered file name and test that it exists | two startup `FileNotFoundException`s |
| B3 | Does every entry in each rules `order.txt` have its `.gr` file? | Compare each `order.txt` with its folder | a startup `ClassNotFoundException` |
| B4 | Are there zero removed-LOB references in `config/bizrules/` and `config/gwrules/`? | `git grep -nE '<pat>' -- <cfg>/config/bizrules <cfg>/config/gwrules` | a BizRules import failure |
| B5 | Did the Rule 11 checks pass for every bulk edit (count dropped by exactly N, control unchanged)? | The work log entry for each bulk edit | a deleted "Night Club" question choice (a `bp7` inside a hash ID) |
| B6 | Is every XML file that had blocks removed still well-formed, with no tag missing its `<`? | `grep -nP '^\s+[A-Z][a-zA-Z]+/>' <file>` and an XML parse | `<ExpirationDate/>` that lost its `<` |
| B7 | Does `git diff --stat` show only expected files, and no file of size 0? | `git diff --stat`, and a size check on every changed file | two form-pattern files emptied |

## C. Is anything left behind?

| # | Question (must be YES) | How to check | Seen as |
|---|---|---|---|
| C1 | Zero removed-LOB keys in `display.properties`? | `git grep -nE '^[^=]*<pat>' -- <cfg>/config/locale/display.properties` (key side only) | 58 keys |
| C2 | Zero in `productmodel.display.properties`? | same, this file | 1,310 and 839 keys for two LOBs |
| C3 | Zero in `display_en_US.properties` and `display_yy.properties`? | same, both files | data-flow mask keys |
| C4 | Zero in all five typelist locale files (`typelist.properties`, `_en_US`, `_yy`, `_es`, `_es_ES`)? | same, all five | 10, 2, 2, 1 and 1 keys |
| C5 | Zero in all three schema display files (`schema.display.properties`, `_en_US_EDG`, `_en_US_EDG_PH`)? | same, all three | keys in each |
| C6 | Zero removed typecodes in every `.tti` and `.ttx`, including typelists unrelated to the LOB? | `git grep -nE '<pat>' -- '<cfg>/config/extensions/typelist/*'` | a "Commercial Property" typecode; a "Guidewire WC" typecode in `ResourceContext.ttx` |
| C7 | Zero `InstalledPolicyLine` and `APDCloudProduct` display entries for the LOB? | `git grep -nE 'InstalledPolicyLine\|APDCloudProduct' -- <cfg>/config/locale \| grep -E '<pat>'` | `typelist.properties` |
| C8 | Zero LOB-specific parameters in `config/xml/config.xml`? | `git grep -nE '<pat>' -- <cfg>/config/xml/config.xml` | a parallel-rating parameter |
| C9 | Zero entries in `StateSets.xml` and `ResourceContextMap.xml`? | same, both files | entries for one LOB |
| C10 | Zero in `config/smoketests/`? | `git grep -nE '<pat>' -- <cfg>/config/smoketests` | missed in every earlier removal |
| C11 | Zero in every `.gst` template? | `git grep -nE '<pat>' -- '<cfg>/gsrc/**/*.gst'` | a 147-line section for a removed LOB |
| C12 | Zero LOB test files in `gtest/`, and zero mock and sample data for the LOB? | `git ls-files <cfg>/gtest` and `git grep -nE '<pat>' -- '**/mock/**' '**/sample*/**'` | a whole rating test file; sample data naming a LOB |
| C13 | Are there zero LOB entity files (`.eti`, `.etx`, `.eix`) anywhere on disk, not just in the standard folder? | `git ls-files \| grep -E '<pat>' \| grep -E '\.(eti\|etx\|eix)$'` | a whole entity file left in place |
| C14 | Zero LOB display-name files (`.en`, `.es`, and other locales), and zero entries inside shared ones? | `git ls-files \| grep -E 'displayname' \| grep -E '<pat>'`, then `git grep` inside the shared files | an entry in a territory display-name file |

## D. Was the process followed?

| # | Question (must be YES) | How to check |
|---|---|---|
| D1 | Was the verification sweep run twice, once to find remnants and once to confirm the cleanup? | The work log |
| D2 | Was every zero reported together with a non-zero control count? | The work log (SKILL.md, Step 2) |
| D3 | Was the sweep run again after the last fix (Phase 19)? | The work log |
| D4 | Is every action in the work log, with its category and outcome, and is every fallout row `RESOLVED` or explained under Accepted leftovers? | The work log |
