# gwb options, Gradle tasks and applied plugins

> Reference for the `pc-current-state` skill. Read it when asked what a `gwb` option, Guidewire `-D` property, Gradle task or applied plugin does. A normal environment snapshot does not need it.
> Moved out of SKILL.md without changes to the steps.

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
