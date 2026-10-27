# Evaluating a removal run: how to know it worked

This is not part of a run. It answers a separate question, *"did the run do what it claimed?"*, from outside, with tooling that is not the run.

A run already checks itself: the verification sweeps (Phases 15 and 19), the build gates, the server start. Those catch a run that fails *loudly*. They cannot catch a run that fails *confidently*: one that reports zero hits because its name list was too narrow, because a grep silently matched nothing, or because work was reverted between the last check and the final one. All of those end with green output.

So the evaluation has one rule, and everything else follows from it:

> **The evaluation must not share patterns, code or state with the run it grades.**
> A run that grades itself reports the same blind spot twice and calls the agreement confirmation.

`scripts/eval-census.sh` is built for this. It is deliberately dumber than the run's own greps: no classification, no judgment, no config. It only counts occurrences per file against a frozen pattern set, and it refuses to report unless a control reads non-zero.

Terms: **`<git_root>`** is the repository that tracks the config module (`git -C <config_root> rev-parse --show-toplevel`). It can differ from the project root. The census excludes `.pwc/` (plans, context files and work logs list every LOB name as data) and `.claude/` (the kit's own lessons name LOB codes).

---

## 1. The timeline: three points

| When | What | Can it be skipped? |
|---|---|---|
| **Before** the run | **Baseline census.** The answer key: what exists, per file, at the starting commit. | **No.** Without it, "the count is now zero" cannot be told apart from "the count was always zero". |
| the run happens | | |
| **After** the run | **Result census.** Same script, same frozen patterns, new commit. | No. |
| **After** that | **Comparison and report.** | No. |

Take the baseline in Phase 1, before any edit. If the run already happened without one, it is still recoverable: git holds the starting state. Check out the starting commit into a scratch worktree (`git -C <git_root> worktree add <dir> <commit>`) and run the census there. Record that the patterns were written after seeing the outcome, because patterns chosen afterwards are not blind.

## 2. Which session runs which part

**Baseline:** any session, including the one about to run the removal. Nothing is graded yet.

**Result and comparison: a fresh session, deliberately.**
1. **Bias.** The session that ran the removal remembers what it meant to do and will read an ambiguous number charitably. It is also the session most likely to reuse the name list it already built, which is exactly the shared state this document exists to prevent.
2. **Context.** A run is long and its early detail is compacted away. An evaluator reading only the files on disk has better information than the session that lived through it.

Hand the fresh session only:
- the two census output folders;
- `<git_root>` and the starting and ending commit SHAs;
- the work log (`.pwc/agent/work-logs/lob-removal-<LOB>-*.md`) for its Fallout Summary and Run Result.

Do **not** hand it the context file's name list as the census patterns. Reading the context file afterwards to explain a discrepancy is fine, and often the point. Using it as the census input is not.

## 3. Building the codes file

`codes.tsv` has one row per code, three tab-separated columns: `CODE`, `EXPECT`, `ALTERNATION`.

```
CR7	zero	\bCR7|\bCrime[A-Z]
CA7	nonzero	\bCA7
```

- `zero`: a removed LOB. It must reach 0 for the run to be complete.
- `nonzero`: a **kept** LOB. This is the positive control. It must read above zero in both censuses and must not drop sharply. At least one row is required; the script refuses to report without it.
- Write the patterns yourself from the LOB code and its full name, and from what the baseline shows (`git ls-files | grep -i <name>`). Freeze them. If a pattern must change, rerun the baseline too from the same commit and say so.

Run it: `bash scripts/eval-census.sh <git_root> <out_dir> <codes.tsv> <label>`. Outputs: `census.<CODE>.tsv` (per-file counts), `paths.<CODE>.txt` (tracked files whose *path* carries the name, a separate signal), `summary.tsv` and `MANIFEST.txt`.

### Two kinds of answer key

**Kind A, the pattern census** (above). Broad. Catches names, display strings, locale keys and config values. Cheap to repeat.

**Kind B, deleted-symbol exact terms.** Higher precision, and it catches what patterns cannot. If the removal is already in history, the names it deleted can be recovered:

```bash
git -C <git_root> diff --diff-filter=D --name-only <start> <end> \
  | awk -F/ '{print $NF}' | sed 's/\.[A-Za-z0-9]*$//' \
  | grep -E '^[A-Za-z][A-Za-z0-9_]{5,}$' | sort -u > symbols.txt

git -C <git_root> grep -I -l -F -f symbols.txt -- ':(exclude).pwc/' ':(exclude).claude/'
```

Every hit is a reference to a name whose defining file no longer exists: dangling by construction, with no pattern noise to argue about. Use both kinds. Kind A finds residue Kind B cannot name; Kind B finds unbranded and all-caps symbols that Kind A's anchoring drops.

### The short-code trap

A two- or three-letter code anchored as `\b<XY>[A-Z]` matches all-caps English words and returns many times the true residue. Re-anchoring to require the CamelCase shape of a real symbol (`\b<XY>[A-Z][a-z]`) can cut hundreds of files to a few dozen. **Before freezing a short code's pattern, print what it matched:**

```bash
git -C <git_root> grep -I -h -o -E '<pattern>' | sort | uniq -c | sort -rn | head -20
```

If the top entries are ordinary words, the pattern is wrong. Tightening it leaves a gap (a real all-caps symbol), which is what Kind B covers. State that trade-off in the report.

---

## 4. The four checks

Run in this order. Each is reported on its own, and a later pass does not excuse an earlier fail.

### Check 1: Recall. Did the run find everything that was there?
For every file in the baseline census that carries a removal code, ask whether the work log accounts for it: removed or modified in the Fallout Summary, or named in the Run Result as a leftover the user accepted.

```
comm -13 <(accounted-for paths, sorted) <(baseline census paths, sorted)
```

Anything printed is residue the run never saw. **One unexplained file is a real finding,** whatever its count: the count measures cleanup size, not risk.

### Check 2: Precision. Did it change only what it declared?
```
git -C <git_root> diff --diff-filter=D --name-only <start> <end>   # everything deleted
git -C <git_root> diff --diff-filter=M --name-only <start> <end>   # everything modified
```
Every path must appear in the work log's Fallout Summary. An unlogged deletion is as serious as an unexplained compile error. Look first at the **kept** LOBs' files: one appearing in either list without a log entry is the worst outcome an evaluation can find.

### Check 3: Completeness. Did the counts reach their targets?
Compare `summary.tsv` between the two runs.
- Every `zero` code ends at 0, or has an accepted leftover named in the Run Result. A non-zero code with neither is a fail even if the run reported success.
- Every `nonzero` control is still above zero and has not dropped sharply. A kept code whose count fell is collateral damage, and a run that only watches the removed codes cannot see it.

### Check 4: Survival. Does it still build and run?
The census cannot answer this and must not be read as if it could. Take it from the build gates: codegen, compile, server at MULTIUSER, GUnit, as recorded in the work log. For a kept LOB, only a UI smoke test (create an account, submit a policy) speaks to the runtime failures that a green compile hides.

---

## 5. What an evaluation cannot tell you

State these in every report. An evaluation that implies more coverage than it has is worse than none.

- **Runtime behaviour.** A green census and a green compile coexist with the failures a build never shows, such as a leftover per-LOB config file loaded by a filename pattern into a shared cache.
- **The database.** Rows that still carry a removed typecode are out of scope. Never score a run down for them, and never score it up by implying they were checked.
- **Whether the name list was complete.** The census proves the codes on the list reached their targets. A LOB referenced by a name nobody listed is invisible to the run and to its evaluation. Checking a list's completeness by running the same kind of search that built it is circular.
- **Anything outside `<git_root>`.** Sibling applications, integration services, batch jobs, CI configuration.

## 6. Reporting

One table of the four checks with an explicit verdict each, then the detail.
- A check that was not run is reported as **not run**, never omitted and never folded into a pass.
- Quote each number with what produced it: the census label and the commit.
- A non-zero that turned out to be noise is reported as a noise finding, with what it was. Dropping it silently loses the evidence that the pattern needed fixing.
- The verdict is about the *run*, not the repo. Residue the run declared and the user accepted is a pass. Residue nobody noticed is a fail even if it is one line.
