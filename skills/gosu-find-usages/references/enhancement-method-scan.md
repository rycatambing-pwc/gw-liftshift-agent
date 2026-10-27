# Enhancement method-name scan (Phase B)

> Reference for the `gosu-find-usages` skill. Read it when the target includes a `.gsx` enhancement file.
> Moved out of SKILL.md without changes to the steps.

### Phase B — Enhancement Method-Name Scan

**Run: When target includes a `.gsx` enhancement file**

Enhancement methods and properties are called directly on entity variables. Callers never
import or reference the enhancement class by name — searching for the class name finds
nothing. Every `function` and `property get`/`set` in the `.gsx` must be grepped
individually.

```
Search pattern: \b<methodOrPropertyName>\b  (one grep per member)
Search scope:   modules/configuration/gsrc/**/*.gs
               modules/configuration/gsrc/**/*.gsx
               modules/configuration/gsrc/**/*.gst
               modules/configuration/config/web/pcf/**/*.pcf
               modules/configuration/config/rules/**/*.gr
```

**Steps:**

1. Open the target `.gsx` and list every `function` and `property get`/`set` name.
2. Grep each name individually across all scope directories above.
3. Exclude the `.gsx` file itself — its own declaration is not a caller.

**What to look for:**

- `entity.<enhancedPropertyName>` — PCF or Gosu accessing an enhancement property
- `variable.<enhancedMethodName>()` — Gosu calling an enhancement method
- Any hit outside the owning file's directory

**Note:** Enhancement dispatch is static — the declared type of the variable determines
which enhancement fires, not the runtime type. Flag any caller where the variable is
declared at a base type rather than the exact enhanced type.

**Example commands:**

```bash
grep -rn '\b<enhancedPropertyName>\b' modules/configuration/gsrc/
grep -rn '\b<enhancedPropertyName>\b' modules/configuration/config/web/pcf/
grep -rn '\b<enhancedPropertyName>\b' modules/configuration/config/rules/
grep -rn '\b<enhancedMethodName>\b' modules/configuration/gsrc/
```
