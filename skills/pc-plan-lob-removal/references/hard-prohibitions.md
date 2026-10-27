# Hard prohibitions (Iron Rules)

> Canonical text for the `pc-plan-lob-removal` skill. `SKILL.md` and every agent keep only a short list and point here. Each rule exists because a real LOB removal broke on it.

These rules are NON-NEGOTIABLE. Past LOB removals violated every one of them, causing 50+ errors the user had to find and fix manually.

### Rule 1: Consumer-First Deletion
NEVER delete a definition (constant, typecode, entity, display key, typelist, enhancement) without FIRST grepping the ENTIRE codebase for all consumers. Sequence:
1. Grep for the symbol across ALL directories (gsrc, config, gtest, integration)
2. List every consumer found
3. Remove every consumer first
4. THEN delete the definition
5. Grep again to verify zero references remain

**Why this exists:** This rule was violated on EVERY LOB removal. The same file (`UnderwriterEvaluatorTriggeringPoint_Ext.gs`) broke 3 times across 3 different LOBs. Constants were deleted while Gosu files still referenced them. Typecodes were removed while PCFs still used them.

### Rule 2: Start-Boundary Grep Only
Use `\bWCM` NOT `\bWCM\b`. The end boundary misses compound identifiers like `WCMLocation`, `WCMLargeDeductible`.

### Rule 3: Match Key Names, Not Entire Lines
When grepping display/properties files, match on the key name (before the `=`) ONLY. Auto-generated hash IDs can contain LOB abbreviations by coincidence. A false positive on a hash containing `bp7` deleted a valid Restaurant QuestionChoice ("Night Club") and crashed server startup.

### Rule 4: Sequential Agent Execution — No Parallel Edits to Shared Files
NEVER run definition-deleting agents in parallel with reference-updating agents. Agent A (update/remove references) completes fully BEFORE Agent B (delete definitions) starts. Parallel execution orphaned references on every LOB removal.

**Additionally:** NEVER let two agents edit the SAME file simultaneously. During CP7/CA7/GL7/WCM removal, a `display.properties` agent bulk-deleted all lines matching the LOB pattern while a separate Gosu agent renamed key references — each assuming the other hadn't touched the file. Similarly, `UnderwriterEvaluatorTriggeringPoint_Ext.gs` was edited by multiple LOB passes and the WCM agent missed 4 typecodes because earlier passes had already changed the file without the agent knowing.

**When a file has been edited by ANY prior agent or prior LOB pass, the next agent MUST re-read the file fresh before editing.** Do not assume a file is in a known state.

### Rule 5: Never Modify Platform-Owned Files
Platform files include: `gw/webservice/*` API Javadoc, `config/metadata/*`, base `.eti`/`.tti`/`.tix` files, `display_*.properties` translations (except main `display.properties` for customer keys), `typelist_*.properties` translations for base typecodes. 45 files were wrongly modified during past removals and had to be restored from git.

### Rule 6: Trace Subsystems, Not Individual Files
Individual file deletion missed 20+ files in WCM alone. Entire subsystems were missed: WC Dividends (20+ files), NCCI Integration (7+ files), Crime Models/Verisk (8 files + 1 template), EPLI Events & Systables. For each LOB, trace the full dependency chain (see Phase 2).

### Rule 7: Remove Dead References, Never Rename Them
When a display key reference points to a removed LOB, REMOVE the reference entirely. Never rename it to another key. Renaming to nonexistent keys caused compile errors in CA7 (`PolicyContactRolePanelSet.PolicyAddlInsured.pcf`) and GL7 (`PolicyPeriodValidation_Ext.gs`).

### Rule 8: Verify Syntax After Every Edit
When removing an if-guard, case branch, or constant, verify the surrounding syntax is still valid. Check for orphaned braces `{` `}`, dangling else, or empty switch blocks. Read the file after editing. Orphaned braces in `SpecialCasesClauseLoadGenerator.gs` caused a parse error during WCM removal.

### Rule 9: Validate XML After Bulk Block Removal
When removing XML blocks (systable entries, FormPattern blocks, CancelRefund entries), the agent can accidentally mangle adjacent entries — stripping `<` from tags, orphaning text content. During CR7 removal from AAIS, the agent stripped `<` from `<ExpirationDate/>` on an adjacent CA7 entry in `cancel_refund.xml`, turning it into bare text that crashed server startup with "SCHEMA ERRORS IN PLUGIN FILES — Cannot have any text content."
**After every bulk XML removal:** grep the file for orphaned text content (lines containing tag-like text without a `<` bracket). Validate the file is well-formed XML before declaring done.

### Rule 10: Run git diff --stat After All Agents Complete
Agents can accidentally empty or modify files they weren't supposed to touch. During CR7 removal from AAIS, the SurePath cleanup agent accidentally zeroed out two CA7 files (`CA7FormPatterns.1.NE.xml`, `CA7FormPatterns.2.SD.xml`), causing server startup failure.
**After all execution phases complete and BEFORE the verification sweep:** run `git diff --stat` and verify:
1. Only expected files were modified (no unexpected files in the diff)
2. No files have size 0 (zeroed out accidentally)
3. No non-LOB files were changed (e.g., CA7 files shouldn't change during CR7 removal)
If unexpected files appear, restore them with `git checkout -- <file>`.

### Rule 11: Bulk Edits Only Under the Guarded Procedure
A bulk edit is one command or script that changes many lines or files at once. It is allowed ONLY when every one of these holds:
1. **Line-oriented files only** (`.properties`, `order.txt`). Never regex-rewrite XML, Gosu, PCF or JSON: they are structured, and every past breakage from a bulk edit happened there (a stripped `<` in `cancel_refund.xml`, two zeroed `CA7FormPatterns.*.xml` files). Edit those file by file.
2. **Dry run first.** List the matching keys with a count and look at the top matches. Match on the key (before `=`), never on the value (Rule 3). Write the count down as N.
3. **Control count.** Record how many keys of a kept LOB are in the same file. It must be unchanged afterwards.
4. **Checks right after the edit, before anything else is touched:** `git diff --stat` lists only the target file; no changed file is empty; the file's count of matching keys dropped by exactly N; the control count is unchanged.
5. **If any check fails,** restore that file from git (run git in the repository that tracks it), fix the match rule, and start again from step 2.

**Why this exists:** tests at the end catch a bad bulk edit only at server start, after more edits have piled on top and with no way to tell which edit did it. These checks take seconds and run at the edit.
