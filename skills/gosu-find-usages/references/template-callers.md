# Template render callers (Phase 7)

> Reference for the `gosu-find-usages` skill. Read it when the target is a `.gst` template.
> Moved out of SKILL.md without changes to the steps.

### Phase 7 — Template Render Callers

**Run: When target is a `.gst` file**

Find callers of `renderToString()` or `render()` on the target template.

```
Search pattern: <TemplateName>\.renderToString(
               <TemplateName>\.render(
Search scope:   modules/configuration/gsrc/**/*.gs
               modules/configuration/gsrc/**/*.gsx
               modules/configuration/gsrc/**/*.gst
```

**Example commands:**

```bash
grep -rn '\b<TargetTemplateName>\.renderToString(' modules/configuration/gsrc/
grep -rn '\b<TargetTemplateName>\.render(' modules/configuration/gsrc/
```
