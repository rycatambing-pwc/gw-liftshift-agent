# PCF Folder and Package Structure

Source: Guidewire public documentation, uncontradicted across batches.

## Canonical Root Path

```
{InsuranceSuiteApplication}/modules/configuration/config/web/pcf
```

In Guidewire Studio: **configuration > config > Page Configuration**.

ClaimCenter has additional integration-specific subdirectories alongside `config/web`:
```
config/iso/      (ClaimCenter only — Insurance Services Office files)
config/metro/    (ClaimCenter only — Metropolitan police report/inquiry files)
config/web/      (PCF files, all products)
```

## PolicyCenter — Line of Business Structure

```
pcf/line/<LineName>/
├── job/
│   └── LineWizardStepSet.<LineName>.pcf     (single file — wizard steps for all job types on this line)
├── policy/
│   └── <Screen/PanelSet/Popup files for the line, shared by jobs and policy file>
└── policyfile/
    └── PolicyMenuItemSet.<LineName>.pcf     (anchors navigation within the policy file view)
```

Multi-line products (e.g. commercial package) use a modified version of this structure.

### Advanced Product Designer (APD) generated file naming, by scope

**Product:**
| Subdir | File |
|---|---|
| `policyfile` | `PolicyMenuItemSet.ProdId.pcf` |

**Product line:**
| Subdir | File |
|---|---|
| `job` | `LineWizardStepSet.ProdId.pcf` |
| `policy` | `YYYLineIdPanelSet.pcf`, `YYYLineIdScreen.pcf` |
| `policyfile` | `PolicyFile_YYYLineId.pcf`, `LineIdLinks.pcf` |

**Risk object:**
| Subdir | File |
|---|---|
| `policy` | `YYYRiskListPanelSet.pcf`, `YYYRiskPanelSet.pcf`, `YYYRiskPopup.pcf`, `YYYRiskScreen.pcf` |
| `policyfile` | `PolicyFile_YYYRisk.pcf`, `PolicyFile_YYYRiskScreen.pcf` |

**Exposure:**
| Subdir | File |
|---|---|
| `policy` | `YYYExposureListPanelSet.pcf` |

## Package Placement (from Education material)

All custom PCFs should live in the appropriate existing or custom **PCF package**, and related PCFs should be grouped in the same package. It has not been confirmed whether "package" is simply Studio's term for these same `job`/`policy`/`policyfile` folders, or a distinct organizational concept layered on top — treat as probably-the-same-thing but unconfirmed. See `/unresolved/01-open-questions.md`.
