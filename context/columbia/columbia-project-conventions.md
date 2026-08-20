# Project Conventions 


# rules of thumb eg, naming conventions per lob 

# Columbia Guidewire Project — LOB Naming Standards

## Purpose
This document defines the canonical Line of Business (LOB) codes, known aliases, and filename-matching conventions used across the Columbia Guidewire codebase (PolicyCenter, BillingCenter, ClaimCenter, ContactManager/AB). It is used to identify, scan, and reason about LOB-specific files during lift-and-shift LOB extraction work.

**Current project context:** the active extraction effort retains **Workers Compensation (WC)** as the sole LOB, removing all others listed below.

---

## 1. Canonical LOB Codes and Aliases

| LOB Code | Known Names / Aliases                          |
|----------|--------------------------------------------------|
| IM       | Inland Marine, InlandMar                          |
| CU       | CommercialUmbrella, CommercialUmb                 |
| BP       | BP7, BOP, BusinessOwnersPolicy                    |
| GL       | GL7, GeneralLiability                             |
| **WC**   | **WCM, WorkersCompensation, WorkersComp**         |
| CR       | CR7, CommercialCrime                              |
| CA       | CA7, CommercialAuto                               |
| CPP      | CommercialPackage                                 |
| CP       | CP7, CommercialProperty                           |

> **Workers Compensation (current retained LOB):**
> - Canonical code: `WC`
> - Alias: `WCM`
> - Both identifiers must be included in any filename matching, scanning, or extraction logic targeting WC.

---

## 2. Filename Matching Rules

LOB codes and aliases may appear in a filename in one of three structurally meaningful positions:

1. **Prefix** — e.g. `WCCoverage.xml`
2. **Suffix (immediately before the extension)** — e.g. `SomethingWC.xml`
3. **Delimited segment** — using `.`, `_`, or `-` as delimiters
   - e.g. `Something.WC.xml`, `Something_WC.xml`, `Something-WC.xml`

### Valid examples (WC)
- `WCSomething.xml`
- `SomethingWC.xml`
- `Something.WC.xml`
- `Something_WC.xml`
- `Something-WC.xml`
- `WCCommon.WC.yaml`

### Alias examples (WorkersComp / WorkersCompensation)
- `WorkersCompCoverage.xml`
- `SomeWorkersCompensation.xml`
- `Something.WorkersComp.yaml`
- `job_wcm_ext-1.0.swagger.yaml`

### Matching Constraints
- **Short codes** (`IM`, `CU`, `GL`, `CP`, `CA`, `WC`) must **never** be matched via unrestricted substring search — they must appear in a structurally valid position (prefix, suffix, or delimited segment) to avoid false positives from incidental letter sequences inside unrelated words.
- **Aliases** (longer names) should use the same prefix/suffix/delimited-segment logic where practical.
- LOB codes are **case-sensitive** and normally uppercase.
- Aliases are matched using their configured spelling exactly as listed above.
- File extension is ignored when evaluating suffix matches.
- Matching is **filename-only** — file contents are never inspected to determine LOB association.

---

## 3. Applicable File Types
Naming-standard matching applies only to the following extensions:
`.eti`, `.etx`, `.tti`, `.ttx`, `.xml`, `.yaml`, `.gs`, `.gsx`, `.pcf`, `.properties`, `.grs`, `.gwp`, `.en`

`.class` files and any other extension are always excluded from LOB matching.

---

## 4. Scope Exclusions
The following directories (and everything beneath them) are never in scope for LOB naming/matching activity:
- `modules/configuration/generated`
- `modules/configuration/generated_classes`

---

## 5. Usage Notes for This Project
- This standards doc is app-agnostic and applies consistently across PC, BC, CC, and AB codebases, since Columbia's proprietary naming conventions carry across all four applications.
- When extraction tooling targets a **different retained LOB** in future iterations, only Section 1's bolded "current retained LOB" callout needs to change — the underlying matching rules (Sections 2–4) remain constant.
- Dev teams building extraction/deletion utilities should treat this file as the single source of truth for LOB code/alias definitions, rather than hardcoding the table independently in each tool.

---

## 6. Typical LOB File Locations

The following directories under `modules/configuration/` are typical locations where LOB-specific files reside. Paths shown use WCM as the reference LOB.

### Product Model & Ratebooks
- `config/resources/productmodel/policylinepatterns/WCMLine/` (+ jurisdictions)
- `config/resources/productmodel/products/WCMBusinessOwners/` (+ jurisdictions)
- `config/resources/productmodel/questionsets/`

### Entity / Typelist Extensions
- `config/extensions/entity/`
- `config/extensions/typelist/`
- `config/metadata/entity/`

### Display Names, Lookup Tables, Systables
- `config/displaynames/`
- `config/lookuptables/`
- `config/resources/systables/`
- `config/resources/`
- `config/resources/diff/`

### PCF (UI Screens)
- `config/web/pcf/line/wcm/job/`
- `config/web/pcf/line/wcm/policy/`
- `config/web/pcf/line/wcm/policyfile/`
- `config/web/pcf/surepath/manuscriptendorsement/line/wcm/policy/`
- `config/web/pcf/surepath/manuscriptendorsement/line/common/`
- `config/web/pcf/admin/bulkproducerchange/`
- `config/web/pcf/contacts/`

### Gosu Source (gsrc/)
- `gsrc/gw/lob/wcm/` (+ sub-packages: blanket, building, classification, compatibility, displayable, existence, financials, forms, helper, iso/rating, jurisdiction, line, location, microclassification, microlocation, question, rating, schedules, synchronization, utils, validation)
- `gsrc/ext/lob/wcm/`
- `gsrc/cust/lob/wcm/` (+ forms, rating, ratingparam, validations)
- `gsrc/cust/job/audit/helpers/wcm/`
- `gsrc/cust/pc/preupdate/wcm/`
- `gsrc/cust/rating/preemption/`
- `gsrc/cust/bizrules/provisioning/contexts/`
- `gsrc/cust/pc/integration/common/predict/`
- `gsrc/gw/ext/sbt/bizrules/builder/wcm/`
- `gsrc/gw/ext/sbt/metadata/builder/wcm/`
- `gsrc/gw/rest/ext/pc/job/wcm/v1/`
- `gsrc/gw/rest/ext/pc/policy/wcm/v1/`
- `gsrc/gw/rest/ext/pc/policyperiod/wcm/v1/` (+ sub-resources)
- `gsrc/gw/surepath/pc/configuration/manuscriptendorsement/lob/wcm/` (+ rating)
- `gsrc/gw/webservice/pc/ccintegration/mapper/lob/`
- `gsrc/gw/webservice/pc/pc5000/ccintegration/lob/`

### Other
- `etc/surepath/pc/configuration/data/sbt/`

> **Note:** Directories like `displaynames/`, `lookuptables/`, and `extensions/entity/` contain files for multiple LOBs. Extraction tooling must filter at the file level within these shared directories, not remove them entirely.