# LOB removal sweeps (Phases F to J)

> Reference for the `gosu-find-usages` skill. Read it when the target belongs to a LOB being removed: typelist orphans (F), display-name orphans (G), REST API schemas (H), locale properties (I), smoketests and config XML (J).
> Moved out of SKILL.md without changes to the steps.

### Phase F — Typelist Orphan Check

**Run: When the target LOB owns typelists**

Verify no consumers exist outside the LOB-owned directories. If consumers are found, the
typelist must be retained.

```
Pattern:       typekey\.<TypelistName>\.TC_\w+
               \b<TypelistName>\b
Search scope:  modules/configuration/gsrc/**  (outside lob-owned path)
               modules/configuration/gsrc/**/*.gst
               modules/configuration/config/rules/**/*.gr
               modules/configuration/config/web/pcf/**/*.pcf
```

**Example commands:**

```bash
grep -rn 'typekey\.<TargetTypelist>\.TC_' modules/configuration/gsrc/
grep -rn 'typekey\.<TargetTypelist>\.TC_' modules/configuration/config/rules/
grep -rn '\b<TargetTypelist>\b' modules/configuration/config/web/pcf/
grep -rn '\b<TargetTypelist>\b' modules/configuration/gsrc/
```

---

### Phase G — Display Name Orphan Check

**Run: When the target LOB owns entity types**

List `.en` files whose entity type no longer exists after LOB-owned `.eti` files are
removed.

```
Search scope:  modules/configuration/config/displaynames/*.en
               modules/configuration/config/extensions/displayname/*.en
Pattern:       filename starts with the target LOB prefix
```

**Example commands:**

```bash
ls modules/configuration/config/displaynames/<LOBPrefix>*.en
ls modules/configuration/config/extensions/displayname/<LOBPrefix>*.en
```

Also check individual `.en` files for LOB entries (e.g., `TerritoryCode.en` had BP7 entries).

---

### Phase H — REST API Schema References

**Run: When target is a LOB entity, typelist, or type used in REST APIs**

Find references in REST API schema JSON files. These produce no compile error when
stale — they fail at server startup.

```
Search pattern: <TargetClassName> or <TargetTypeName>
Search scope:   modules/configuration/integration/**/*.schema.json
               modules/configuration/config/integration/**
```

`CUPolicyType` and `coverageNameCU_Ext` were both missed in `policyperiod_ext-1.0.schema.json`
during CU removal, causing server startup failure.

**Example commands:**

```bash
grep -rn '<TargetClassName>' modules/configuration/integration/
grep -rn '<TargetClassName>' modules/configuration/config/integration/
```

---

### Phase I — Locale Properties Sweep

**Run: When target is a LOB entity, typelist, or class with display keys**

Search ALL locale variant properties files. During LOB removal, the user manually found
2,000+ orphaned keys in files that were never searched.

```
Search scope:
  modules/configuration/config/locale/display.properties
  modules/configuration/config/locale/display_en_US.properties
  modules/configuration/config/locale/display_yy.properties
  modules/configuration/config/locale/typelist.properties
  modules/configuration/config/locale/typelist_en_US.properties
  modules/configuration/config/locale/typelist_yy.properties
  modules/configuration/config/locale/typelist_es.properties
  modules/configuration/config/locale/typelist_es_ES.properties
  modules/configuration/config/locale/productmodel.display.properties
  modules/configuration/config/locale/schema.display.properties
  modules/configuration/config/locale/schema.display_en_US_EDG.properties
  modules/configuration/config/locale/schema.display_en_US_EDG_PH.properties
```

**Example commands:**

```bash
grep -n '<TargetClassName>\|<LOBPrefix>' modules/configuration/config/locale/*.properties
```

---

### Phase J — Smoketests and Config XML

**Run: When target is a LOB entity or typelist**

Search paths that are systematically missed:

```
Search scope:
  modules/configuration/config/smoketests/typelists.properties
  modules/configuration/config/smoketests/
  modules/configuration/config/xml/config.xml
  modules/configuration/config/statesets/StateSets.xml
  modules/configuration/config/resources/ResourceContextMap.xml
```

The `config/smoketests/` directory was missed in EVERY past LOB removal.

**Example commands:**

```bash
grep -n '<LOBPrefix>' modules/configuration/config/smoketests/typelists.properties
grep -n '<LOBPrefix>' modules/configuration/config/xml/config.xml
```
