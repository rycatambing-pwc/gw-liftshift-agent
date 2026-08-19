# Skill: pc-current-state

## Purpose

Build a comprehensive snapshot of the Guidewire PolicyCenter development environment and persist it to `env-description.md`. This gives agents (especially `gw-build-agent`) an authoritative baseline to validate tooling, paths, and configuration before attempting builds or diagnostics.

## When to Activate

- At the start of a project build to establish the environment baseline.
- When trying to understand the current state of the project.
- When validating the current state versus the last documented state in `env-description.md`.

---

## Workflow

Execute the following three phases in order. Collect all findings, then write (or update) `env-description.md` in the project root (`C:\dev\policycenter\env-description.md`).

### Phase 1 — Environment Description

Gather the following using shell commands:

| Item | Command | Notes |
|------|---------|-------|
| OS version | `[System.Environment]::OSVersion` | Windows version and build |
| Hostname | `hostname` | Machine identifier |
| Current user | `whoami` | Running identity |
| Working directory | `Get-Location` | Should be `C:\dev\policycenter` |
| Available RAM | `(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory` | Total physical memory |
| Available disk | `Get-PSDrive C` | Free space on the project drive |
| Shell | `$PSVersionTable` | PowerShell edition and version |

### Phase 2 — Tool Verification

Check that each required tool is installed and accessible. For each tool, record: **found/missing**, **version**, and **path**.

| Tool | Version Check | Environment Variable | Notes |
|------|---------------|---------------------|-------|
| Java (JDK) | `java -version` | `JAVA_HOME`, `JAVA11_HOME`, `JAVA11_AMD64_HOME` | Must be JDK 11 or 17 |
| gwb (Gradle wrapper) | Locate `C:\dev\policycenter\gwb.bat` | — | This IS the Gradle wrapper (no separate `gradlew`) |
| Bundled Gradle | Check `gradle\wrapper\gradle-wrapper.jar` exists | — | Must be version 8.6 |
| Git | `git --version` | — | — |
| Node.js (if applicable) | `node --version` | — | Optional |

Also verify these environment variables are set:

| Variable | Purpose | Notes |
|----------|---------|-------|
| `JAVA_HOME` | JDK location | gwb.bat overrides with `JAVA_HOME` if set |
| `PATH` | Confirm Java/Git entries present | — |

Report each as **set** (with value or redacted for secrets) or **not set**.

### Phase 3 — Configuration Files

Read and summarize the key configuration files. Report whether each file exists and capture critical values:

| File | Key Values to Capture |
|------|-----------------------|
| `gradle.properties` | JVM args, heap sizes, parallelism, caching, incremental flags, app version |
| `build.gradle` | Plugin versions, buildscript dependencies |
| `settings.gradle` | Included modules |
| `modules/configuration/build.gradle` | Extension libs, custom tasks, compile dependencies |
| `modules/script/gw-build.gradle` | JDK enforcement, applied plugins, custom task definitions |
| `gradle/wrapper/gradle-wrapper.properties` | Gradle distribution URL (should be `./gradle.zip` for bundled) |

---

## gwb.bat Reference

`gwb.bat` is Guidewire's customized Gradle wrapper. There is **no separate `gradlew.bat`** in this project.

### How gwb.bat Works

1. Sets Gradle version to `8.6` and cache dir to `%CD%\gradle\cache\`
2. Sets `IDEA_HOME=C:\dev\IntelliJ-Community-2022.3.3`
3. Validates cached Gradle version matches 8.6; purges `gradle\cache\wrapper` if mismatched
4. Overrides `JAVA_HOME` with `JAVA11_HOME` or `JAVA11_AMD64_HOME` if those exist
5. Invokes `org.gradle.wrapper.GradleWrapperMain` from `gradle\wrapper\gradle-wrapper.jar`

### Hardcoded Flags (always applied)

| Flag | Effect |
|------|--------|
| `--stacktrace` | Full stacktraces on all errors |
| `--offline` | No network dependency resolution (uses local `repository/` folder) |
| `--no-daemon` | No persistent Gradle daemon |
| `-Dgradle.user.home=%APP_HOME%\gradle\cache` | Keeps Gradle caches local to project |

### Default Task

If `gwb` is invoked with **no arguments**, it runs `gwTasks` — a custom task that prints the curated list of developer-facing tasks.

### Additional Gradle CLI Options

Since gwb wraps Gradle, all standard Gradle CLI options can be passed:

| Option | Purpose |
|--------|---------|
| `-q` | Quiet mode (minimal output) |
| `-x <task>` | Exclude a task (e.g., `-x compile`) |
| `-D<property>=<value>` | Set system property |
| `--info` | Info-level logging |
| `--debug` | Debug-level logging (very verbose) |
| `--scan` | Generate build scan |
| `--warning-mode all` | Show deprecation warnings |
| `help --task <name>` | Detailed help for a specific task |

### Guidewire-Specific System Properties

| Property | Task | Purpose |
|----------|------|---------|
| `-DincludeGtest=true` | compile | Include gtest sources |
| `-Dgw.port=<port>` | runServer | Override server port |
| `-Dgw.webapp.dir=<dir>` | runServer | Override webapp directory |
| `-Dinput_dir`, `-Doutput_dir`, `-Dmap_coverages`, `-Dcc_app_version` | ccTypelistGen | Typelist export params |
| `-Dexport.file`, `-Dexport.language` | exportLocalizations | Export params |
| `-Dimport.file`, `-Dimport.language` | importLocalizations | Import params |
| `-Dmerge.module` | mergeModule | Module to merge |
| `-DoutputFile`, `-Dexclude`, `-DappRootDirectory` | zipChangedConfig | Archive params |
| `-DoutputFormat=xml` | genDataDictionary | Output format |
| `-Ddeprecated=true` | genJavaApi | Include deprecated API |
| `-Dsplit=true` | genDataMapping | Split output |
| `-Dresource.types=<types>` | verifyResources | Resource types to check |

---

## Available Gradle Tasks

### Core Application Tasks

| Task | Description |
|------|-------------|
| `clean` | Delete the build directories |
| `cleanIdea` | Delete Studio project files (.iml, .idea) |
| `codegen` | Generate entities, PCFs, permissions, and other sources |
| `compile` | Compile Java + Gosu sources, re-generate sources, prepare webapp |
| `dropDb` | Drop all database tables (depends on compile) |
| `idea` | Generate Studio project files |
| `inspect` | Run Guidewire Studio Inspections (depends on idea) |
| `runServer` | Start the Guidewire application server (depends on compile) |
| `stopServer` | Stop a running application server |
| `studio` | Start Guidewire Studio (depends on idea + syncUpgradePlugins) |
| `version` | Print build/version information |

### Codegen Sub-Tasks (called individually or via `codegen`)

| Task | Description |
|------|-------------|
| `genEntitySources` | Generate entity source code |
| `genPcfSources` | Generate PCF source code |
| `genPermissionSources` | Generate permission source code |
| `genProductModelSources` | Generate product model source code |
| `genXmlSources` | Generate XML source code |
| `genSchemaSources` | Generate schema sources |
| `genWsdlSources` | Generate WSDL sources |
| `genLocalizationSources` | Generate localization sources |

### WAR/EAR Packaging Tasks

| Task | Description |
|------|-------------|
| `warTomcatDbcp` | WAR for Tomcat with JDBC drivers |
| `warTomcatJndi` | WAR for Tomcat without JDBC drivers |
| `warJbossDbcp` | WAR for JBoss with JDBC drivers |
| `warJbossJndi` | WAR for JBoss without JDBC drivers |
| `earWeblogicDbcp` | EAR for WebLogic with JDBC drivers |
| `earWeblogicJndi` | EAR for WebLogic without JDBC drivers |
| `earWebsphereDbcp` | EAR for WebSphere with JDBC drivers |
| `earWebsphereJndi` | EAR for WebSphere without JDBC drivers |

### Globalization Tasks

| Task | Description |
|------|-------------|
| `diffDisplayKeys` | Generate missing display keys |
| `exportLocalizations` | Export localizations |
| `importLocalizations` | Import localized resources |

### Integration Tasks

| Task | Description |
|------|-------------|
| `exportWsdl` | Export WSDL for WSI web services |
| `genExternalSchemas` | Generate external JSON/Swagger/XSD schemas |
| `genFromWsc` | Build WSC meta-information from .wsc files |
| `genWsiLocal` | Generate WSDL in gsrc/wsi/local |
| `jsonSchemaCodegen` | Generate code for JSON schemas (no compile dependency) |
| `restEndpointGenerator` | Bootstrap Cloud API Endpoints for custom entities |
| `updateReleasedSchemaVersions` | Update versioned schema versions |

### Documentation Tasks

| Task | Description |
|------|-------------|
| `genDataDictionary` | Build Data Dictionary and Security Dictionary |
| `genEntityModelXml` | Generate entity model in XML format |

### Configuration & Utility Tasks

| Task | Description |
|------|-------------|
| `ccTypelistGen` | Export PC product model as typelists to ClaimCenter |
| `genDataMapping` | Build data mapping files |
| `genImportAdminDataXsd` | Regenerate XSD files for admin data import |
| `genPcfMapping` | Build PCF mappings |
| `genPhoneMetadata` | Regenerate phone metadata |
| `mergeModule` | Merge configuration module on top of 'configuration' |
| `packageSolr` | Regenerate Solr zip file |
| `runSuite` | Run test suite |
| `verifyExtConfig` | Verify external property substitution |
| `verifyResources` | Check PCF, Annotation, GxModel, RestIView, Workflow, Types |
| `zipChangedConfig` | Archive changed configuration files |
| `flattenConfiguration` | Flatten configuration (no compile dependency) |
| `genExternalEntitySources` | Generate external entity sources (no compile dependency) |

### Configuration Upgrade Tasks

| Task | Description |
|------|-------------|
| `compareConfigs` | Compares two InsuranceSuite configs for upgrade |
| `genRuleReport` | Build the rule repository report |

### Plugin Development Tasks

| Task | Description |
|------|-------------|
| `genJavaApi` | Build the Java API toolkit |

### Cloud Rating Tasks

| Task | Description |
|------|-------------|
| `generateCloudRatingCustomRateFunctionZip` | Zip cloud rating custom functions |
| `deleteCloudRatingCustomRateFunctionZip` | Delete cloud rating custom function zip |
| `ratePlanStudioSetup` | Download Rateplan JARs from Artifactory |

---

## Applied Plugins

| Plugin | Purpose |
|--------|---------|
| `com.guidewire.application` | Core app configuration (appCode, port) |
| `com.guidewire.cust-dist-studio` | Guidewire Studio IDE integration |
| `com.guidewire.cust-dist-root-tasks` | Root-level task definitions (gwTasks, etc.) |
| `com.guidewire.cust-dist-dev-tasks` | Developer tasks (runServer, dropDb, etc.) |
| `com.guidewire.cust-dist-upgrade` | Configuration upgrade tools |
| `com.guidewire.cust-dist-webapp` | WAR/EAR packaging |
| `com.guidewire.cust-dist-java-api` | Java API generation |
| `com.guidewire.customer-dist-test` | Test suite support |
| `com.guidewire.cust-dist-gosu` | Gosu language compilation |
| `com.guidewire.cust-dist-deprecated-tasks` | Legacy task name aliases |
| `com.guidewire.codegen-entity` | Entity source code generation |
| `com.guidewire.codegen-pcf` | PCF source code generation |
| `com.guidewire.codegen-xml` | XML/Schema/WSDL code generation |
| `com.guidewire.codegen-product-model` | Product model code generation |
| `com.guidewire.codegen-localization` | Localization code generation |
| `com.guidewire.codegen-permission` | Permission code generation |
| `com.guidewire.solr-cust-dist-task` | Solr packaging |
| `com.guidewire.web.utilities` | Web resource (CSS/JS) processing |
| `com.guidewire.parallel-clean` | Parallel directory cleanup |
| `com.guidewire.jdbc-drivers` | JDBC driver management |
| `com.guidewire.dependencies` | Dependency management (BOM import) |
| `com.guidewire.idea` | IntelliJ IDEA project generation |
| `com.guidewire.restclient:codegen` | REST client code generation |
| `com.guidewire.restclient:plugin` | REST client Gradle plugin |

---

## Output Format

Write (or overwrite) the file `env-description.md` in the Guidewire PolicyCenter home folder (e.g., `C:\dev\policycenter\env-description.md`). Use the following structure:

```markdown
# PolicyCenter Environment Description

> Generated: {{timestamp}}
> Machine: {{hostname}}

## System

| Property | Value |
|----------|-------|
| OS | {{os_version}} |
| User | {{user}} |
| RAM | {{ram}} |
| Disk Free (C:) | {{free_space}} |
| Shell | {{shell_version}} |
| Project Root | {{working_dir}} |

## Tools

| Tool | Status | Version | Path |
|------|--------|---------|------|
| JDK | {{found/missing}} | {{version}} | {{path}} |
| gwb.bat | {{found/missing}} | Gradle 8.6 (bundled) | {{path}} |
| gradle-wrapper.jar | {{found/missing}} | — | {{path}} |
| gradle.zip (bundled distribution) | {{found/missing}} | — | {{path}} |
| Git | {{found/missing}} | {{version}} | {{path}} |
| Node.js | {{found/missing}} | {{version}} | {{path}} |

## Environment Variables

| Variable | Status | Value |
|----------|--------|-------|
| JAVA_HOME | {{set/not set}} | {{value}} |

## gwb.bat Status

| Check | Result |
|-------|--------|
| gwb.bat exists | {{yes/no}} |
| Gradle cache dir valid | {{yes/no}} |
| Cached Gradle matches v8.6 | {{yes/no}} |
| gradle-wrapper.jar present | {{yes/no}} |
| Bundled gradle.zip present | {{yes/no}} |
| IDEA_HOME target exists  | {{yes/no}} |
| Effective JAVA_HOME (after gwb overrides) | {{path}} |
| Offline mode | Always (hardcoded) |
| Daemon | Disabled (hardcoded) |

## Configuration Summary

### gradle.properties

| Property | Value |
|----------|-------|
| org.gradle.jvmargs | {{value}} |
| org.gradle.parallel | {{value}} |
| org.gradle.workers.max | {{value}} |
| org.gradle.daemon | {{value}} |
| org.gradle.caching | {{value}} |
| gosuCompileMinHeap / gosuCompileMaxHeap | {{value}} |
| javaCompileMinHeap / javaCompileMaxHeap | {{value}} |
| entityCodegenMaxHeap | {{value}} |
| pcfCodegenMaxHeap | {{value}} |
| entityCodegenIncremental | {{value}} |
| pcfCodegenIncremental | {{value}} |
| productModelCodegenIncremental | {{value}} |

### build.gradle — Buildscript Dependencies

| Dependency | Version |
|------------|---------|
| com.guidewire.restclient:codegen | {{version}} |
| com.guidewire.restclient:plugin | {{version}} |
| com.guidewire.btr.build:gradle-plugins | {{version}} |
| com.guidewire.btr.build:ci-gradle-plugins | {{version}} |
| com.guidewire.studio:ij-studio-gradle-plugins | {{version}} |
| com.guidewire.web:plweb-gradle-plugin | {{version}} |
| com.guidewire.btr.build:solr-gradle-plugins | {{version}} |

### settings.gradle — Active Modules

{{list of included modules and their status (active/commented-out)}}

### Local Repository

| Check | Result |
|-------|--------|
| `repository/` folder exists | {{yes/no}} |
| Contains `com/guidewire/` artifacts | {{yes/no}} |

## Issues Detected

{{List any problems found: missing tools, unset variables, version mismatches, missing config files, inaccessible paths}}
```

---

## Behavioral Rules

1. **Never expose secrets.** Redact user name and password values — show only `[REDACTED]` or `[NOT SET]`.
2. **If `env-description.md` already exists**, read it first and update in place rather than regenerating from scratch. Preserve any manual annotations the user may have added (sections with `<!-- manual -->` markers).
3. **Flag issues clearly.** If a required tool is missing or a variable is unset, list it in the "Issues Detected" section with a recommended fix.
4. **Timestamp every run.** Always update the `Generated:` timestamp so agents can tell how fresh the snapshot is.
5. **Do not modify any project files** other than `env-description.md`.
6. **Validate gwb.bat prerequisites.** Check for `gradle\wrapper\gradle-wrapper.jar` and the bundled `gradle.zip` — if missing, the build cannot run at all.
7. **Check JDK priority chain.** gwb.bat uses multiple home along with `JAVA_HOME`. Report which one will actually be used at runtime.
8. **Verify offline readiness.** Since gwb always runs `--offline`, confirm the local `repository/` folder exists and contains Guidewire artifacts. If missing, flag as critical.
