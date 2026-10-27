#!/usr/bin/env bash
# eval-census.sh — independent occurrence census for evaluating a LOB-removal run.
#
# This is the EVALUATION tool, not part of the run. It is deliberately separate from the
# kit's own greps so that a run cannot be graded by the same code that produced it.
# <git_root> is the repository that tracks the config module. See references/evaluation.md.
# Run it once BEFORE a pass (baseline / answer key) and again AFTER (result), then diff.
#
# Usage:
#   eval-census.sh <git_root> <out_dir> <codes_tsv> [label]
#
# codes_tsv — one row per code, tab-separated, '#' comments allowed:
#   <CODE>\t<EXPECT>\t<ALTERNATION>
#     CODE        short label, used in filenames
#     EXPECT      zero    -> a removed code; must reach 0 for the pass to be complete
#                 nonzero -> a retained code; MUST read non-zero or the scan is broken
#     ALTERNATION an ERE, frozen once and never edited between baseline and result runs
#
# At least one 'nonzero' row is REQUIRED. It is the positive control: a census where every
# count is zero is indistinguishable from a census whose pattern or pathspec silently matched
# nothing. If a control reads zero, this script exits non-zero and writes no summary.
#
# Outputs, all under <out_dir>:
#   census.<CODE>.tsv   per-file counts, descending  (count \t path)
#   paths.<CODE>.txt    tracked files whose PATH carries the alias (a separate signal:
#                       a file can be wholly removal-owned while its content count is low)
#   summary.tsv         CODE, expect, files, occurrences, path_hits
#   MANIFEST.txt        git_root, HEAD, branch, dirty count, pattern set, timestamp
#
# Exit codes: 0 ok | 1 usage/environment | 2 positive control failed

set -uo pipefail

GIT_ROOT="${1:-}"; OUT_DIR="${2:-}"; CODES_TSV="${3:-}"; LABEL="${4:-census}"

if [ -z "$GIT_ROOT" ] || [ -z "$OUT_DIR" ] || [ -z "$CODES_TSV" ]; then
  sed -n '2,30p' "$0"; exit 1
fi
git -C "$GIT_ROOT" rev-parse --show-toplevel >/dev/null 2>&1 || {
  echo "FATAL: not a git repository: $GIT_ROOT" >&2; exit 1; }
[ -f "$CODES_TSV" ] || { echo "FATAL: codes file not found: $CODES_TSV" >&2; exit 1; }

mkdir -p "$OUT_DIR"

# Pathspecs excluded from the census. Keep this list identical between baseline and result
# runs, or the diff measures the exclusion change instead of the pass.
EXCLUDES=(
  ':(exclude)**/node_modules/'
  ':(exclude)generated/'
  ':(exclude)build/'
  ':(exclude)out/'
  ':(exclude).gradle/'
  ':(exclude).pwc/'           # plans, context files and work logs list every LOB name as data
  ':(exclude).claude/'        # the kit's own lessons and templates name LOB codes
)

TRACKED=$(git -C "$GIT_ROOT" ls-files -- "${EXCLUDES[@]}" | wc -l | tr -d ' ')
BINARIES=$(git -C "$GIT_ROOT" ls-files --eol -- "${EXCLUDES[@]}" 2>/dev/null | grep -Pc '^i/-text' || true)

{
  echo "label:      $LABEL"
  echo "git_root:   $GIT_ROOT"
  echo "head:       $(git -C "$GIT_ROOT" rev-parse HEAD)"
  echo "head_short: $(git -C "$GIT_ROOT" rev-parse --short HEAD)"
  echo "branch:     $(git -C "$GIT_ROOT" branch --show-current)"
  echo "head_date:  $(git -C "$GIT_ROOT" log -1 --format=%ad --date=iso)"
  echo "dirty:      $(git -C "$GIT_ROOT" status --porcelain | wc -l | tr -d ' ')"
  echo "tracked:    $TRACKED  (after exclusions)"
  echo "binaries:   $BINARIES  (content-sniffed, skipped via git grep -I)"
  echo "generated:  $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "excludes:   ${EXCLUDES[*]}"
  echo "patterns:"
} > "$OUT_DIR/MANIFEST.txt"

printf 'code\texpect\tfiles\toccurrences\tpath_hits\n' > "$OUT_DIR/summary.tsv"

control_seen=0
control_failed=0

while IFS=$'\t' read -r CODE EXPECT ALT; do
  [ -z "${CODE:-}" ] && continue
  case "$CODE" in \#*) continue ;; esac
  [ -z "${ALT:-}" ] && { echo "FATAL: no alternation for $CODE" >&2; exit 1; }

  printf '  %-8s %-8s %s\n' "$CODE" "$EXPECT" "$ALT" >> "$OUT_DIR/MANIFEST.txt"

  # Per-file occurrence counts. `git grep -c` emits path:count and splits on the LAST
  # colon, so paths containing ':' or '+' still parse correctly via $NF.
  git -C "$GIT_ROOT" grep -I -c -E "$ALT" -- "${EXCLUDES[@]}" 2>/dev/null \
    | awk -F: '{ n=$NF; sub(/:[^:]*$/, ""); print n "\t" $0 }' \
    | sort -rn -k1,1 > "$OUT_DIR/census.$CODE.tsv"

  # Path-name hits: a distinct signal from content. Counted, never summed into occurrences.
  git -C "$GIT_ROOT" ls-files -- "${EXCLUDES[@]}" \
    | grep -E "$ALT" > "$OUT_DIR/paths.$CODE.txt" 2>/dev/null || true

  FILES=$(wc -l < "$OUT_DIR/census.$CODE.tsv" | tr -d ' ')
  OCCS=$(awk -F'\t' '{s+=$1} END {print s+0}' "$OUT_DIR/census.$CODE.tsv")
  PATHHITS=$(wc -l < "$OUT_DIR/paths.$CODE.txt" | tr -d ' ')

  printf '%s\t%s\t%s\t%s\t%s\n' "$CODE" "$EXPECT" "$FILES" "$OCCS" "$PATHHITS" >> "$OUT_DIR/summary.tsv"

  if [ "$EXPECT" = "nonzero" ]; then
    control_seen=1
    [ "$OCCS" -eq 0 ] && { echo "CONTROL FAILED: $CODE expected non-zero, read 0" >&2; control_failed=1; }
  fi
done < "$CODES_TSV"

if [ "$control_seen" -eq 0 ]; then
  echo "FATAL: codes file declares no 'nonzero' control row. Refusing to report." >&2
  rm -f "$OUT_DIR/summary.tsv"; exit 2
fi
if [ "$control_failed" -eq 1 ]; then
  echo "FATAL: positive control read zero — the scan is broken, not the repo clean." >&2
  mv "$OUT_DIR/summary.tsv" "$OUT_DIR/summary.INVALID.tsv"; exit 2
fi

echo "census ok -> $OUT_DIR"
column -t -s$'\t' "$OUT_DIR/summary.tsv" 2>/dev/null || cat "$OUT_DIR/summary.tsv"
