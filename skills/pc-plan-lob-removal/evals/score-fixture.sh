#!/usr/bin/env bash
# score-fixture.sh: score a LOB removal run, or a single agent's task, against the fixture's answer key.
#
# Usage: score-fixture.sh <fixture_dir> [-v] [--only REGEX]
#   -v            also list every passing row
#   --only REGEX  score only the key rows whose path matches REGEX (an extended regex, e.g. 'PolicyMenu|LineWizardStepSet').
#                 Use it for single-agent tests. Any change to a file outside REGEX is reported as out of scope, and the
#                 whole-project residue check is skipped, because the rest of the project is expected to be untouched.
#
# The expected end state is rebuilt from make-fixture.sh (the single source of truth), compared with the
# fixture's working tree, and measured against the fixture's baseline tag. Checks:
#   Recall     every DELETE file is gone; every EDIT file equals its golden content (only the LOB's parts removed)
#   Precision  nothing else changed: no KEEP file touched, no file outside the key changed, no file emptied
#   Residue    no start-boundary hit for the removed LOB remains in any tracked file or file name
#   Control    the kept LOB (KP7) has exactly as many matching lines as at the start
# Exit code 0 only if every check passes. Needs bash 4+ and git. File comparisons use shell built-ins, because
# process start-up is slow on some Windows machines.

set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIX="${1:-}"; [ $# -gt 0 ] && shift
VERBOSE=0; ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    -v) VERBOSE=1; shift ;;
    --only) ONLY="${2:-}"; [ -n "$ONLY" ] || { echo "--only needs a regex" >&2; exit 1; }; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done
TAG=fixture-baseline
PAT='\b(zq7|zephyrquest)'; CONTROL='\bkp7'
if [ -z "$FIX" ] || [ ! -d "$FIX/.git" ]; then sed -n 2,18p "$0"; exit 1; fi
git -C "$FIX" rev-parse -q --verify "$TAG" >/dev/null || { echo "No $TAG tag in $FIX: not a fixture made by make-fixture.sh" >&2; exit 1; }

T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
bash "$HERE/make-fixture.sh" --emit-golden "$T" || { echo "Could not rebuild the answer key" >&2; exit 1; }
KEY="$T/key.tsv"; GOLD="$T/golden"

# normalise a file into $NORM: trailing whitespace and blank lines ignored
norm() { local line out=""; while IFS= read -r line || [ -n "$line" ]; do line="${line%"${line##*[![:space:]]}"}"; [ -n "$line" ] && out+="$line"$'\n'; done < "$1"; NORM="$out"; }

fails=0; shown=0; scored=0
bad()  { fails=$((fails+1)); echo "FAIL  $*"; }
good() { [ "$VERBOSE" = 1 ] && echo "pass  $*"; return 0; }
declare -A tot ok allowed keepset changed
for a in DELETE EDIT KEEP; do tot[$a]=0; ok[$a]=0; done

# what changed since the baseline: tracked files modified or deleted, plus new files (one git call each)
while IFS= read -r -d '' p; do changed["$p"]=1; done < <(git -C "$FIX" diff --name-only -z "$TAG")
while IFS= read -r -d '' p; do changed["$p"]=1; done < <(git -C "$FIX" ls-files -o --exclude-standard -z)

# ---- Recall and per-file survival ----
while IFS=$'\t' read -r action rel; do
  case "$action" in DELETE|EDIT) allowed["$rel"]=1 ;; KEEP) keepset["$rel"]=1 ;; esac
  if [ -n "$ONLY" ] && ! [[ $rel =~ $ONLY ]]; then continue; fi
  tot[$action]=$((tot[$action]+1)); scored=$((scored+1))
  case "$action" in
    DELETE)
      if [ -e "$FIX/$rel" ]; then bad "DELETE   still exists: $rel"; else ok[DELETE]=$((ok[DELETE]+1)); good "DELETE   $rel"; fi ;;
    EDIT)
      if [ ! -f "$FIX/$rel" ]; then bad "EDIT     file is gone (it should only lose its LOB parts): $rel"
      elif [ ! -s "$FIX/$rel" ]; then bad "EDIT     file is now empty: $rel"
      else
        norm "$FIX/$rel"; a="$NORM"; norm "$GOLD/$rel"; b="$NORM"
        if [ "$a" = "$b" ]; then ok[EDIT]=$((ok[EDIT]+1)); good "EDIT     $rel"
        else
          bad "EDIT     differs from the expected result: $rel"
          shown=$((shown+1))
          if [ "$shown" -le 5 ]; then diff <(printf '%s' "$a") <(printf '%s' "$b") | head -6 | sed 's/^/          /'
          elif [ "$shown" -eq 6 ]; then echo "          (diffs are shown for the first 5 files only)"; fi
        fi
      fi ;;
    KEEP)
      if [ ! -f "$FIX/$rel" ]; then bad "KEEP     was deleted: $rel"
      elif [ -n "${changed[$rel]:-}" ]; then bad "KEEP     was modified: $rel"
      else ok[KEEP]=$((ok[KEEP]+1)); good "KEEP     $rel"; fi ;;
  esac
done < "$KEY"
[ -z "$ONLY" ] || [ "$scored" -gt 0 ] || bad "SCOPE    no key row matches --only '$ONLY'"

# ---- Precision: nothing changed outside the key (or, with --only, outside the task) ----
unexpected=0
for p in "${!changed[@]}"; do
  case "$p" in .pwc/*|.claude/*|tmp/*|env-description.md) continue ;; esac
  if [ -n "$ONLY" ]; then
    [[ $p =~ $ONLY ]] || { unexpected=$((unexpected+1)); bad "SCOPE    changed outside the task: $p"; }
  else
    [ -n "${allowed[$p]:-}" ] || [ -n "${keepset[$p]:-}" ] || { unexpected=$((unexpected+1)); bad "CHANGED  not in the key: $p"; }
  fi
done

# ---- Residue: the removed LOB must be gone from every tracked file and file name (whole-run scoring only) ----
content=0; paths=0
if [ -z "$ONLY" ]; then
  hits="$(git -C "$FIX" grep -niE "$PAT" -- . ':(exclude).pwc' ':(exclude).claude' 2>/dev/null || true)"
  [ -n "$hits" ] && content=$(printf '%s\n' "$hits" | wc -l | tr -d ' ')
  if [ "$content" -ne 0 ]; then bad "RESIDUE  $content line(s) still match the removed LOB:"; printf '%s\n' "$hits" | head -8 | sed 's/^/          /'; fi
  phits="$( (cd "$FIX" && find modules -type f 2>/dev/null) | grep -iE "$PAT" || true)"
  [ -n "$phits" ] && paths=$(printf '%s\n' "$phits" | wc -l | tr -d ' ')
  if [ "$paths" -ne 0 ]; then bad "RESIDUE  $paths file name(s) still match the removed LOB:"; printf '%s\n' "$phits" | head -8 | sed 's/^/          /'; fi
fi

# ---- Control: the kept LOB must be exactly as it was ----
count() { awk -F: '{s+=$NF} END{print s+0}'; }
before=$(git -C "$FIX" grep -ciE "$CONTROL" "$TAG" -- . 2>/dev/null | count)
after=$(git -C "$FIX" grep -ciE "$CONTROL" -- . 2>/dev/null | count)
[ "$before" -gt 0 ] || bad "CONTROL  the kept LOB reads zero at the baseline: the scan itself is broken"
[ "$before" -eq "$after" ] || bad "CONTROL  kept LOB changed: $before matching lines at the start, $after now"

echo
[ -z "$ONLY" ] || echo "Scope      only rows matching: $ONLY ($scored rows)"
printf 'Recall     deleted %s/%s files    edited correctly %s/%s files\n' "${ok[DELETE]}" "${tot[DELETE]}" "${ok[EDIT]}" "${tot[EDIT]}"
if [ -n "$ONLY" ]; then printf 'Precision  kept files intact %s/%s    changes outside the task: %s\n' "${ok[KEEP]}" "${tot[KEEP]}" "$unexpected"
else printf 'Precision  kept files intact %s/%s    changes outside the key: %s\n' "${ok[KEEP]}" "${tot[KEEP]}" "$unexpected"; fi
if [ -n "$ONLY" ]; then echo "Residue    not checked with --only"
else printf 'Residue    removed-LOB lines left: %s    file names left: %s\n' "$content" "$paths"; fi
printf 'Control    kept-LOB lines: %s at the start, %s now\n' "$before" "$after"
if [ "$fails" -eq 0 ]; then echo "RESULT: PASS"; else echo "RESULT: FAIL ($fails problem(s))"; fi
echo "Not covered here: build, codegen, server start, GUnit. The fixture has no PolicyCenter install."
[ "$fails" -eq 0 ]
