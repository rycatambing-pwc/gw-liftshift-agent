# Skill: PCF Find Usages

Find where a given PCF file or element is referenced across the Guidewire codebase. Use this when you need to understand the impact of a change, locate callers/includers, or trace navigation paths.

## When to Activate

- Before modifying or deleting a PCF file — find all consumers first
- When renaming a PCF file or element ID
- When tracing how a user navigates to a specific screen
- When investigating broken references or orphaned files
- When checking if a reusable panel is still in use

---

## Workflow

Execute the relevant search phases based on what you're looking for. Not all phases apply to every query — pick the ones that match.

### Phase 1 — PanelRef / InputSetRef Consumers

Find all PCF files that include the target file via `PanelRef` or `InputSetRef`:

```
Search pattern: def="<TargetFileName>( 
Search scope:   modules/configuration/config/web/pcf/**/*.pcf
```

**What to look for:**
- `<PanelRef def="TargetFileName(...)"/>` — standard inclusion
- `<PanelRef def="TargetFileName" mode="..."/>` — modal inclusion
- `<InputSetRef def="TargetFileName(...)"/>` — Input Set inclusion

**Example commands:**
```bash
grep -r 'def="PolicyInfoDV' modules/configuration/config/web/pcf/
grep -r 'def="AddressInputSet' modules/configuration/config/web/pcf/
```

### Phase 2 — Navigation References (Location Callers)

Find where a Page, Popup, Wizard, or Location Group is navigated to:

```
Search pattern: <TargetLocationName>.push(  OR  <TargetLocationName>.go(
Search scope:   modules/configuration/config/web/pcf/**/*.pcf
```

**What to look for:**
- `action="TargetPopup.push(arg)"` — popup invocation
- `action="TargetGroup.go(arg)"` — location group navigation
- `<LocationRef location="TargetLocation"/>` — location group membership
- `locationref` widgets with `location=` attribute pointing to target

**Example commands:**
```bash
grep -r 'MyPopup\.push(' modules/configuration/config/web/pcf/
grep -r 'PolicyFileGroup\.go(' modules/configuration/config/web/pcf/
grep -r 'location="MyPage"' modules/configuration/config/web/pcf/
```

### Phase 3 — Display Key Usages

Find where display keys used by a PCF file are defined and referenced elsewhere:

```
Search pattern: displaykey.<KeyPath>
Search scope:   modules/configuration/config/displaykeys/**/*.properties
                modules/configuration/config/web/pcf/**/*.pcf
```

**What to look for:**
- Definition in `.properties` files: `Web.Policy.MyField = My Label`
- Usage in PCF: `label="displaykey.Web.Policy.MyField"` or `DisplayKey.get("Web.Policy.MyField")`

**Example commands:**
```bash
grep -r 'Web.Policy.MyField' modules/configuration/config/displaykeys/
grep -r 'Web.Policy.MyField' modules/configuration/config/web/pcf/
```

### Phase 4 — Gosu References to PCF Elements

Find Gosu code that programmatically references PCF files or navigates to locations:

```
Search scope:   modules/configuration/config/gsrc/**/*.gs
                modules/configuration/config/gsrc/**/*.gsx
```

**What to look for:**
- `pcf.TargetLocation.push(...)` — Gosu navigation to a PCF location
- `pcf.TargetLocation.go(...)` — Gosu navigation
- References in enhancement methods that wire UI behavior

**Example commands:**
```bash
grep -r 'pcf\.PolicyFileForward' modules/configuration/config/gsrc/
grep -r 'pcf\.NewSubmission' modules/configuration/config/gsrc/
```

### Phase 5 — Mode File Discovery

Find all modal variants of a shared PCF file:

```
Search pattern: Files named <BaseName>_<ModeSuffix>.pcf in same directory
Search scope:   Same directory as the base PCF file
```

**What to look for:**
- Files sharing the same base name with mode suffixes (e.g., `CoveragesDV_Submission.pcf`, `CoveragesDV_PolicyChange.pcf`)
- The mode declaration inside the target file

**Example commands:**
```bash
ls modules/configuration/config/web/pcf/line/PersonalAutoLine/CoveragesDV*.pcf
grep -r 'mode="' modules/configuration/config/web/pcf/ | grep "CoveragesDV"
```

### Phase 6 — LocationGroup Membership

Find which LocationGroup contains a given Page:

```
Search pattern: <LocationRef  with location="TargetPage"
Search scope:   modules/configuration/config/web/pcf/**/*.pcf
```

Also check for `LocationGroup` files that list the target page in their contents.

**Example commands:**
```bash
grep -r 'location="PolicyFile"' modules/configuration/config/web/pcf/
grep -rl 'LocationGroup' modules/configuration/config/web/pcf/ | xargs grep -l 'PolicyFile'
```

---

## Output Format

After running the relevant phases, report findings as:

```
## Usages of: <TargetFileName>

### Direct Inclusions (PanelRef/InputSetRef)
- <CallerFile.pcf> line <N> — PanelRef def="<Target>(...)"
- <CallerFile.pcf> line <N> — InputSetRef def="<Target>(...)"

### Navigation References
- <CallerFile.pcf> line <N> — action="<Target>.push(...)"
- <GosuFile.gs> line <N> — pcf.<Target>.go(...)

### Location Membership
- <GroupFile.pcf> — LocationRef location="<Target>"

### Modal Variants
- <Target>_Submission.pcf
- <Target>_PolicyChange.pcf

### Display Key Cross-References
- <KeyPath> defined in <file.properties>, used in <N> other PCF files

### Impact Summary
- Total consumers: <count>
- Safe to modify: Yes/No (No if >0 consumers outside current change scope)
- Requires coordination: <list of files that would need companion changes>
```

---

## Behavioral Rules

1. **Always run Phase 1 and Phase 2** — these catch the most common references.
2. **Run Phase 4 (Gosu references) for locations** — Gosu code often navigates to PCF locations programmatically.
3. **Report zero results explicitly** — "No PanelRef consumers found" is useful information (means the file may be orphaned or is a top-level location).
4. **Check both `config/web/pcf/` and `gsrc/`** — references span both PCF XML and Gosu code.
5. **For rename operations, report all phases** — every reference needs updating.
6. **For delete operations, confirm zero consumers before proceeding** — if consumers exist, report them and ask the user how to handle.
7. **Use case-sensitive search** — PCF file names and IDs are case-sensitive.
