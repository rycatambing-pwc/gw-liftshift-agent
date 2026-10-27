# Class-relationship phases (Phases 3 and 4)

> Reference for the `gosu-find-usages` skill. Read it when the target is a Gosu class or entity type (Phase 3), or an interface or abstract base class (Phase 4).
> Moved out of SKILL.md without changes to the steps.

### Phase 3 — Enhancement Consumers of This Class

**Run: When target is a Gosu class or entity type**

Find `.gsx` files that enhance the target type. If the target is removed, these
enhancement headers fail to compile.

```
Search pattern: enhancement \w+ : (entity\.)?<ClassName>
Search scope:   modules/configuration/gsrc/**/*.gsx
```

**What to look for:**

- `enhancement MyEnhancement_Ext : entity.TargetEntity`
- `enhancement MyEnhancement : pkg.TargetClass`

**Example commands:**

```bash
grep -rn 'enhancement.*:\s*entity\.<TargetEntity>' modules/configuration/gsrc/
grep -rn 'enhancement.*:\s*<pkg>\.<TargetClass>' modules/configuration/gsrc/
```

---

### Phase 4 — Subclass / Interface / Delegate Consumers

**Run: When target is an interface or abstract base class**

Find classes that extend, implement, or delegate to the target.

```
Search pattern: extends <ClassName>
               implements <ClassName>
               delegate \w+ : <ClassName>
Search scope:   modules/configuration/gsrc/**/*.gs
```

**What to look for:**

- `class MyImpl extends TargetBase`
- `class MyImpl implements TargetInterface`
- `delegate _impl : TargetInterface = new TargetImpl()`

**Example commands:**

```bash
grep -rn 'extends\s\+<TargetBaseClass>' modules/configuration/gsrc/
grep -rn 'implements.*<TargetInterface>' modules/configuration/gsrc/
grep -rn 'delegate.*:\s*<TargetInterface>' modules/configuration/gsrc/
```
