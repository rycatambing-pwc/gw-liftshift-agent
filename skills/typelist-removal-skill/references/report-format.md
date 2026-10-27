# Typelist removal report format

> Reference for the `typelist-removal-skill` skill. Read it when the user chose to save the removal report (Step 7).
> Moved out of SKILL.md without changes to the steps.

```markdown
# Typelist Removal Report: <TypelistName>

> Generated: <YYYY-MM-DD HH:MM>
> Typelist File: <path to .tti file>
> Typecodes Removed: <count>
> Extensions Removed: <list of .ttx files>

## Summary

| Action | Count |
|--------|-------|
| Files deleted | <count> |
| Files modified | <count> |
| Files flagged for manual review | <count> |
| Blockers (not removed) | <count> |
| Residual references found | <count> |

## Typecodes That Were Defined

| Code | Name |
|------|------|
| <code> | <name> |

## Files Deleted

| # | File | Reason |
|---|------|--------|
| 1 | <relative_path> | <reason> |

## Files Modified

| # | File | Changes Made |
|---|------|-------------|
| 1 | <relative_path> | <description of changes> |

## Flagged for Manual Review

| # | File | Reason | Line(s) |
|---|------|--------|---------|
| 1 | <relative_path> | <reason> | <line numbers> |

## Blockers (Not Removed)

| # | File | Reason |
|---|------|--------|
| 1 | <relative_path> | <reason> |

## Residual References (Post-Removal Check)

| # | File | Line | Content |
|---|------|------|---------|
| 1 | <relative_path> | <line> | `<content>` |

---

*Removal completed: <YYYY-MM-DD HH:MM>*
*Recommend running `gwb compile` to verify no compilation errors.*
```
