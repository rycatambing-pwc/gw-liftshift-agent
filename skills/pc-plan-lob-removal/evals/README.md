# Testing the kit on the fixture project: step by step

A fake PolicyCenter project you can test the agents and skills on in minutes, with no PolicyCenter install and no build. It has a made-up line of business to remove (**ZQ7**, long name **ZephyrQuest**), a kept one beside it (**KP7**), and traps taken from the kit's own lessons.

**You do not have to invent anything.** Every prompt to paste and every answer to give is written below. Your job is to paste the prompt, answer the agent's questions with the answers given, and compare what you see with "You should see".

**What it cannot test:** codegen, compile, server start and GUnit, because there is no PolicyCenter install. The fixture's `gwb.bat` is a stub that prints a message and exits with code 9; it never fakes a build.

## The shortest useful path

Do these three, in this order. Everything else on this page is optional.

1. **Part A**: set up (once).
2. **Test 1**: a skill answers a question about the fixture. Tells you the kit loads and a skill works.
3. **Test 14**: the full removal, then the score. This is the real test.

If you only have time for one thing, do Part A and Test 14.

---

## Part A: Set up (once)

You will use **two windows**: your normal VS Code window for terminal commands, and a second window opened on the fixture for Claude Code.

**A1. Create the fixture.** In a terminal in your normal window (Git Bash):

```bash
cd skills/pc-plan-lob-removal/evals
bash make-fixture.sh --install-kit
```

You should see `Fixture ready: ...` after about 15 seconds. It creates `evals/fixtures/pc-fixture` (gitignored), with a copy of the kit inside its `.claude/` folder. The copy leaves out this `evals/` folder, so the agent cannot read the answer key.

If it says `Refusing to overwrite a non-empty folder`, a fixture from an earlier run is still there: delete `evals/fixtures` and run it again.

**A2. Open Claude Code on the fixture.** In VS Code: *File > New Window*, then *File > Open Folder*, and choose `skills/pc-plan-lob-removal/evals/fixtures/pc-fixture`. Open the Claude Code panel in that window as you normally do. It must be opened on this folder, not on the kit: Claude Code loads agents and skills from the `.claude/` of the folder it starts in.

**A3. Check the kit loaded.** In that new Claude Code session, paste:

```
List the agents and skills available in this project, one line each.
```

*You should see* six agents (`gw-pcf-agent`, `gw-gosu-agent`, `gw-entity-agent`, `gw-typelist-agent`, `gw-build-agent`, `gw-planner`) and nine skills (`pc-plan-lob-removal`, `pc-current-state`, `pcf-find-usages`, `entity-find-usages`, `gosu-find-usages`, `typelist-find-usages`, `typelist-removal-skill`, `pcf-agent-skills`, `grill-me`). You can also type `/agents`. If any are missing, stop: nothing below means anything until this works.

**A4. Check the starting state.** In your normal window's terminal (still in `evals`):

```bash
git -C fixtures/pc-fixture status --short
```

*You should see* nothing at all.

**To go again from scratch** (safe only in the fixture, which has its own repo):

```bash
git -C fixtures/pc-fixture reset --hard fixture-baseline
git -C fixtures/pc-fixture clean -fd
```

Do not run `pc-current-state` on the fixture; it needs a real install.

---

## Part B: Test each skill (read-only, no reset needed)

Paste the prompt in the Claude Code window on the fixture. After each one, run `git -C fixtures/pc-fixture status --short` in your terminal: it must still print nothing, because these skills never change files.

### Test 1: `typelist-find-usages`

```
Use the typelist-find-usages skill on ZQ7CoverageType. If it asks whether to save the results to a file, say no.
```

*You should see:*
- the definition `ZQ7CoverageType.tti`, with its one typecode, `Hull`;
- four usages: `PolicyPeriod.etx` (the `ZQ7Type` typekey, line 3), `typelist.properties`, `typelist_es.properties` and `smoketests/typelists.properties`;
- no Gosu usages and no PCF usages, stated as such.

### Test 2: `entity-find-usages`

```
Use the entity-find-usages skill on ZQ7Policy_Ext.
```

*You should see:* the definition `ZQ7Policy_Ext.eti` and **zero** consumers, with the places it searched. "None found" is the pass; an invented consumer is the fail.

### Test 3: `gosu-find-usages` on a class

```
Use the gosu-find-usages skill on cust.lob.zq7.ZQ7Rating.
```

*You should see:* the consumer `config/rules/ZQ7Rules/ZQ7Events.gr`, with Phase 6 (rule files) reported explicitly. The search term also matches `ZQ7RatingEnabled` (a parameter in `config.xml`) and `ZQ7RatingTest.gs`; a good answer classifies those and does not list them as consumers. `ZQ7Plugin.gwp` also names the class, but plugin registries are outside this skill's search scope, so finding it is a bonus.

### Test 4: `gosu-find-usages` on a constants class

```
Use the gosu-find-usages skill on CommonConstants_Ext.
```

*You should see:* one consumer file, `AccountHelper_Ext.gs`, lines 5 and 6 (`KP7_ELIGIBLE` and `ZQ7_ELIGIBLE`).

### Test 5: `pcf-find-usages`

```
Use the pcf-find-usages skill on ZQ7LineWizard.pcf.
```

*You should see:* one consumer, `LineWizardStepSet.pcf` line 4, `def="ZQ7LineWizard()"`.

### Test 6: `typelist-removal-skill` (dry run)

```
Use the typelist-removal-skill on ZQ7CoverageType. Dry run only: do not change any file.
```

*You should see:* a dry-run summary. DELETE: `ZQ7CoverageType.tti`. MODIFY: `PolicyPeriod.etx`, `typelist.properties`, `typelist_es.properties` and `smoketests/typelists.properties`. It then stops and waits for your confirmation. Do not confirm.

Not covered: `pcf-agent-skills` (it needs PCF work the fixture does not have) and `grill-me`.

---

## Part C: Test each agent (these edit files; reset between tests)

Ask for one agent by name, with a small task. Then score **only that agent's files** from your terminal. `--only` scores the files you name and flags any change to a file outside them as out of scope: that is the "stayed in its lane" check. Every agent reply should also **end with a status word** (`DONE`, `NEEDS-…`, `BLOCKED`, `NOT-FOUND` or `AMBIGUOUS`).

Reset first (see Part A) unless the test says to continue from the previous one.

### Test 7: `gw-gosu-agent`

```
Use the gw-gosu-agent to remove the ZQ7 case from LobCommonHelperFactory, and the ZQ7 constants in CommonConstants_Ext together with the code that uses them. Gosu files only.
```

Score it:

```bash
bash score-fixture.sh fixtures/pc-fixture --only 'LobCommonHelperFactory|CommonConstants_Ext|AccountHelper_Ext'
```

*You should see* `RESULT: PASS` with 3 of 3 edited correctly. In the agent's transcript, `AccountHelper_Ext.gs` was edited **before** the constants were removed (consumer first). Its reply ends with `DONE`.

### Test 8: `gw-pcf-agent`

```
Use the gw-pcf-agent to remove the ZQ7 references from LineWizardStepSet.pcf and PolicyMenu.pcf. Do not rename anything.
```

```bash
bash score-fixture.sh fixtures/pc-fixture --only 'LineWizardStepSet|PolicyMenu'
```

*You should see* `RESULT: PASS`, 2 of 2: the references are removed, not renamed. The agent should also tell you that the display key `ZQ7.Dashboard.Title` still exists in `display.properties`, and should **not** edit that file (the scorer would flag it as out of scope).

### Test 9: `gw-entity-agent`

```
Use the gw-entity-agent to remove the ZQ7 typekey and column from PolicyPeriod.etx and delete ZQ7Policy_Ext.eti.
```

```bash
bash score-fixture.sh fixtures/pc-fixture --only 'PolicyPeriod.etx|ZQ7Policy_Ext'
```

*You should see* `RESULT: PASS`, 2 of 2. The agent should notice that the typelist `ZQ7CoverageType` is now unused and end with a Handoff to `gw-typelist-agent` and the status `NEEDS-TYPELIST`.

### Test 10: `gw-typelist-agent` (continue straight from Test 9, no reset)

```
Use the gw-typelist-agent to remove the ZQ7 typecodes from PolicyLine.ttx and RuleContextDefinitionKey.ttx, and delete InstalledPolicyLineZQ7.ttx and ZQ7CoverageType.tti.
```

```bash
bash score-fixture.sh fixtures/pc-fixture --only 'PolicyLine.ttx|RuleContextDefinitionKey|InstalledPolicyLineZQ7|ZQ7CoverageType.tti'
```

*You should see* `RESULT: PASS`, 4 of 4. The agent ran `typelist-find-usages` before deleting anything.

### Test 11: `gw-typelist-agent`, consumer-first variant (reset first; do NOT run Test 9)

Use the **same prompt as Test 10** and the same score command.

*You should see* one FAIL, and that is the correct result: `ZQ7CoverageType.tti` is **not** deleted, because `PolicyPeriod.etx` still uses it. The agent says so and ends with a Handoff to `gw-entity-agent` and the status `NEEDS-ENTITY`. If it deletes the typelist anyway, the consumer-first rule failed.

### Test 12: `gw-build-agent`

```
Use the gw-build-agent to run gwb compile and report the result.
```

*You should see:* it reports that the command failed (exit code 9, "FIXTURE … was NOT run"), does **not** claim the compile succeeded, edits nothing, and ends with the status `BLOCKED`. Then `git -C fixtures/pc-fixture status --short` prints nothing.

### Test 13: `gw-planner`

```
Use the gw-planner agent to draft the removal plan for ZQ7. Write the plan file only.
```

*You should see:* a plan file under `.pwc/agent/plans/` (inside the fixture) that states the approval mode and the config root `modules/configuration`. `git -C fixtures/pc-fixture status --short` prints nothing: a planner changes no project file.

---

## Part D: The full removal

This is the real test. Do **Run 1** first. Reset before each run.

### Test 14: Run 1, continuous mode

Paste exactly this and nothing more. Do not mention ZephyrQuest; finding it is part of the test.

```
Use the pc-plan-lob-removal skill to remove the ZQ7 line of business. This is a static test project with no PolicyCenter install, so there is no build: skip every gwb command (baseline, codegen, compile, runServer, tests) and mark Phases 1, 16, 17 and 18 as SKIPPED. Use the continuous approval mode.
```

**What the agent will ask, and what to answer.** I have not watched a live run, so treat this as the expected order. If it asks something not listed here, answer sensibly and write the question down: the question itself is a finding.

| When | It should ask | You answer |
|---|---|---|
| Name discovery | Which candidate names are real names for this LOB (a multi-select) | Tick **ZQ7** and **ZephyrQuest**. Leave **ZQ** unticked (it comes from the platform file `ZQ_AuditLog.eti`). It must not ask you to type alternate names from memory. |
| Approval mode | Which mode to use | **Continuous** (your prompt already says so) |
| After Phase 2 | To approve the plan and the inventory it found | `Approved, go ahead.` This is the only stop in continuous mode. |
| Any other stop | An unexpected error, an ambiguous hit, or a whole shared file about to be deleted | Read it. These are the "stops no mode can skip". Answer, and note it. |

**Watch for these while it runs:**

| When | What you should see | Where to look |
|---|---|---|
| Before you approve | `git -C fixtures/pc-fixture status --short` stays **empty**: nothing is edited before the plan is approved | your terminal |
| After Phase 2 | A context file with the config root `modules/configuration`; the names `ZQ7` and `ZephyrQuest` confirmed and `ZQ` rejected; KP7 listed as kept; the inventory by subsystem. It should cover the 21 files to delete and 36 to edit (`bash make-fixture.sh --print-key` lists them for you). | `.pwc/agent/plans/lob-removal-ZQ7-context.md` in the fixture |
| Dispatching | Agents run one at a time, and each reply ends with a status word | the chat |
| Order of edits | `AccountHelper_Ext.gs` is edited before `CommonConstants_Ext.gs` | the work log in `.pwc/agent/work-logs/` |
| The 40 bulk keys | A dry run showing 40 matches, a kept-LOB control count, and checks after the edit | the work log |
| Phases 3 and 10 | Static checks, not codegen | the work log |
| Phases 15 and 19 | Every zero reported with a non-zero KP7 control count; the known-answer checklist answered question by question (some will be "not applicable here") | the work log |
| Run Result | `Accepted leftovers` filled in; `Errors Unresolved` equals the number of OPEN rows | the work log |

**Score it** (in your terminal, in `evals`):

```bash
bash score-fixture.sh fixtures/pc-fixture
```

Add `-v` to list every passing row. *You should see* `RESULT: PASS`. A pass means the static edits are exactly right and the kept LOB is untouched. It does not mean the removal would compile or start.

### Test 15: Run 2, checkpoints mode

Reset, then paste the same prompt with the last sentence changed:

```
Use the pc-plan-lob-removal skill to remove the ZQ7 line of business. This is a static test project with no PolicyCenter install, so there is no build: skip every gwb command (baseline, codegen, compile, runServer, tests) and mark Phases 1, 16, 17 and 18 as SKIPPED. Use the checkpoints approval mode.
```

*You should see* it stop after Phase 2, before Phase 11 (the first phase that deletes entity and typelist definitions), and at the final sign-off. It may also pause before Phase 16, the full compile, even though that phase is skipped here; that is fine. Answer `go` at each stop. Run the same score command at the end.

---

## Part E: Grade it from outside (optional)

The scorer knows the answer key. The census does not: it only counts, which is how `references/evaluation.md` says a run should be graded. Take a baseline census **before** a run and a result census after it, with the same patterns file:

```bash
bash ../scripts/eval-census.sh fixtures/pc-fixture /tmp/census-before fixture-codes.tsv before
# ...do the run...
bash ../scripts/eval-census.sh fixtures/pc-fixture /tmp/census-after  fixture-codes.tsv after
diff /tmp/census-before/summary.tsv /tmp/census-after/summary.tsv
```

ZQ7 must fall to zero and KP7 must be unchanged. Do not edit `fixture-codes.tsv` between the two.

---

## Part F: Reading a failure

Each trap is there because a past removal failed on it. A failing row points to the rule or phase that should have caught it.

| A failing row looks like | The mistake | What should have prevented it |
|---|---|---|
| `display.properties` is missing `QuestionChoice.qc_8zq7a1 = Night Club` | Matched a hash ID by substring | Iron Rules 2 and 3; the guarded bulk edit (Rule 11) |
| `messaging-config.xml` keeps `</destination>` | Removed matching lines and left a block half-deleted | Iron Rules 8 and 9 |
| `PolicyDocument_Ext.gst` keeps `<% } %>` | Same, in a template | Iron Rule 8; Phase 13 |
| `CommonConstants_Ext.gs` or `AccountHelper_Ext.gs` differs | Deleted a constant before its consumer | Iron Rule 1 (consumer first) |
| `ZQ_AuditLog.eti` was deleted or modified | Treated a short prefix as the LOB, or touched a platform file | Iron Rule 5; the false-positive handling |
| `typelist_es.properties` or `typelist_es_ES.properties` differs | Searched only for the English name | Phase 8 (all locale variants) |
| `systables.CUST.xml` differs | Fixed `systables.xml` only | Phase 7 |
| `productmodel.display.properties` differs | Bulk-edited without a dry run or control | Iron Rule 11 |
| `zq7-availability-config.xml` still exists | Found no reference to the file by name | **Not covered yet.** This is runtime-failure check D, plan task T21. Expect this row to fail until T21 is done. |
| `Control` says the kept LOB changed | Damaged KP7 | Iron Rules 1 to 5 |
| `SCOPE changed outside the task` | An agent edited files it was not asked to | The delegation boundaries in each agent |

## Part G: Record the result

One line per run, so you can see whether a change to the kit made things better or worse. The kit commit is `git -C <kit folder> rev-parse --short HEAD`.

| Date | Kit commit | Test | Mode | Score | Notes |
|---|---|---|---|---|---|
| | | 14 full removal | continuous | | |
| | | 15 full removal | checkpoints | | |
| | | 9 gw-entity-agent | | | |

---

## The traps

| Trap | What a careless run does |
|---|---|
| `QuestionChoice.qc_8zq7a1 = Night Club` in `display.properties` | deletes a kept line whose hash ID happens to contain `zq7` |
| A multi-line `<destination>` block between two kept blocks (`messaging-config.xml`) | removes the lines that match and leaves an orphaned `</destination>` |
| The `.gst` template section | removes the matching lines and leaves an orphaned `<% } %>` |
| `AccountHelper_Ext.gs` uses `CommonConstants_Ext.ZQ7_ELIGIBLE` | deletes the constant first, leaving a dangling reference |
| `ZQ_AuditLog.eti` in `config/metadata/` | treats a short prefix as the LOB and deletes a platform file |
| `zq7-availability-config.xml` is loaded by `AvailabilityLoader.gs`, which builds the name at run time | finds no reference to the file by name and leaves it in place |
| Translated files `typelist_es*.properties` hold `Lanchas`, `Casco` | searches for the English name and never sees them |
| `systables.CUST.xml`, a second systable file | updates `systables.xml` only |
| `Mapping Script_ZQ7Line.kts` | mishandles the space in the file name |
| `UnderwriterEvaluatorTriggeringPoint_Ext.gs` and `RuleContextDefinitionKey.ttx` | edits a typecode list without checking the other |
| `productmodel.display.properties` has 40 ZQ7 keys among kept ones | bulk-deletes without a dry run or a kept-LOB control count |
| `tmp/pc.mv.db` at the project root next to the real one under `modules/configuration/tmp/` | deletes the wrong database |
| ZephyrQuest appears in a key, a value, a typecode name and sample data | finds only the code and misses the long name |

A naive "delete every line that contains zq7" run reports zero leftovers and still fails three of these.

## Keeping the fixture honest

- The answer key is the `@@ DELETE|EDIT|KEEP` list inside `make-fixture.sh`. `bash make-fixture.sh --print-key` prints it. It is never written into the fixture.
- The generator checks its own declarations before writing anything: a DELETE file must mention the LOB, an EDIT file must change, a KEEP file must not mention it. A mistake fails with a `SELFCHECK` message.
- To add a case, add a `@@ ACTION path` block to `make-fixture.sh`. In an EDIT file, start each line the removal must drop with `-|`. Use `@/` for `modules/configuration/`.
- Put the LOB code at the start of a word (`ZQ7Line`, not `EnableZQ7Rating`). A start-boundary search cannot see a code buried mid-word, and the kit's rules say not to rely on one.
- The fixture holds a copy of the kit as it was when you generated it. If you change the kit, delete `fixtures/` and generate it again.
- The scripts use shell built-ins for almost everything, because starting a process is slow on some Windows machines. A score takes about 15 to 30 seconds.
- This tests one LOB with one kept LOB. It does not show that the kit works on a real project, and it does not replace the evaluation in `references/evaluation.md`.
