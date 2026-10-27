# Config, string-literal and constant phases (Phases C, D, E)

> Reference for the `gosu-find-usages` skill. Read it when `config/resources/productmodel/` exists (C), the target is a LOB line entity or is being renamed or moved (D), or a shared constants class holds a constant for the target (E).
> Moved out of SKILL.md without changes to the steps.

### Phase C — Product Model XML Script References

**Run: When `config/resources/productmodel/` exists in the project**

Find coverage pattern XML files that call the target class in `<InitializeScript>` or
`<AvailabilityScript>` elements. These scripts are not build-validated — a missing class
only fails at runtime when the product model engine loads the coverage pattern.

```
Search pattern: <TargetClassName>  inside InitializeScript or AvailabilityScript
Search scope:   modules/configuration/config/resources/productmodel/**/*.xml
```

**What to look for:**

- `<InitializeScript>TargetClass.method(coverable)</InitializeScript>`
- `<AvailabilityScript>TargetClass.isAvailable(line)</AvailabilityScript>`

**Example commands:**

```bash
grep -rn 'TargetClass' modules/configuration/config/resources/productmodel/
grep -rn 'InitializeScript\|AvailabilityScript' \
  modules/configuration/config/resources/productmodel/policylinepatterns/
```

---

### Phase D — String Literal and Pattern Code References

**Run: When target is a LOB line entity, or when a class is being renamed or its package moved**

Find references to the target as a string literal. These produce no compile error when
stale.

```
Search pattern: "<LineName>"
               "<ProductCode>"
               PatternCode == "<CoveragePatternCode>"
               \.Code == "<TypecodeString>"
Search scope:   modules/configuration/gsrc/**/*.gs
               modules/configuration/gsrc/**/*.gsx
               modules/configuration/gsrc/**/*.gst
               modules/configuration/config/rules/**/*.gr
               modules/configuration/admin/bin/**/*.gsp
```

**What to look for:**

- `Set.of("<OtherLine>", "<TargetLineName>")` — set literal
- `"<TargetLineName>" -> "<lobCode>"` — map entry
- `.compare(Policy#ProductCode, Equals, "<TargetProductCode>")` — query filter
- `PolicyLinePattern.PublicID == "<TargetLineName>"` — string comparison
- `elt.PatternCode == "<TargetCoveragePatternCode>"` — coverage pattern code
- `term.PatternCode == "<TargetCostLayerPatternCode>"` — cost layer pattern code

**Example commands:**

```bash
grep -rn '"<TargetLineName>"' modules/configuration/gsrc/
grep -rn '"<TargetLineName>"' modules/configuration/config/rules/
grep -rn '"<TargetProductCode>"' modules/configuration/gsrc/
grep -rn 'PatternCode.*==.*"<TargetPatternPrefix>' modules/configuration/gsrc/
grep -rn '\.Code\s*==\s*"' modules/configuration/gsrc/
```

---

### Phase E — Shared Constant Ripple Scan

**Run: When a shared constants class holds a named constant for the target LOB code or class name**

Every caller of a named constant produces a compile error if that constant is removed.

```
Search pattern: <ConstantsClass>\.<CONSTANT_NAME>
Search scope:   modules/configuration/gsrc/**/*.gs
               modules/configuration/gsrc/**/*.gsx
```

**Steps:**

1. Find which constants class defines the target value — grep `gsrc/` for the target line
   name or product code as a string to locate the file that declares it as a named
   constant.
2. For each constant found, grep all callers by that constant's field name.
3. List every caller as a file requiring a companion edit.

**Example commands:**

```bash
# Step 1 — locate the constants class
grep -rn '"<TargetLineName>\|<TargetProductCode>"' modules/configuration/gsrc/

# Step 2 — find all callers of the named constant
grep -n '"<TargetLineName>\|<TargetProductCode>"' modules/configuration/gsrc/<path/to/SharedConstants>.gs
grep -rn '<SharedConstantsClass>\.<TARGET_CONSTANT_NAME>' modules/configuration/gsrc/
```
