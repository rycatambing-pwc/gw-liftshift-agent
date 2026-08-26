# Modes: Dispatch Mechanics and Defaults

Source: Guidewire Education module. Extends and significantly deepens `/context/05-shared-sections-and-modes.md`.

## Why Modes Exist

When a UI needs to display different data/structure depending on an object's subtype (e.g. different licensing info fields depending on contact subtype), you could put every variant's logic into one PCF file — but this adds complexity, eliminates the reusability benefit of containers, and produces repetitive conditional logic. Guidewire's convention is the opposite: prefer many small, purpose-specific PCFs over one large conditional one, since small components are easier to create, debug, modify, and maintain.

**Modes are the mechanism for "use case versioning"** — a set of PCFs sharing a name, each identified by a mode value, dispatched to based on the calling context.

## Modal PCFs "Always Come in Sets" (in practice)

A single PCF with one mode and no counterparts behaves identically to a non-modal PCF — no benefit gained. So in real practice, modal PCFs always exist as a **set**, each member handling one or more mode values.

**A single PCF can be assigned multiple modes** — e.g. one `SubtypeInfoInputSet` file might serve both `ABPerson` and `ABPolicyPerson` subtypes at once, rather than needing a separate file per subtype.

## Default Mode and Fallback Behavior

If a modal PCF is referenced with a mode value that has **no matching PCF** in the set, the **default** PCF is used as a fallback. (Example: referencing `SubtypeInfoInputSet` with mode `ABPropertyInspector`, where no PCF was defined for that specific mode — the default PCF, which might be blank, is used instead.)

**A PCF can be both the default AND explicitly assigned other named modes at the same time.** Example: a PCF could be assigned modes `ABPerson`, `ABPolicyPerson`, **and** `default` simultaneously — serving those two subtypes explicitly, while also catching anything else that doesn't match another PCF in the set.

## Critical Rule: Mode Dispatch Is Exact-Type, Not Hierarchy-Cascading

This is a genuinely non-obvious behavior worth stating precisely, since it's easy to assume the opposite.

**Real example (contact subtypes):**
- PCF #1 — default mode — used for any contact type that isn't `ABAttorney`, `ABPerson`, or `ABPolicyPerson`.
- PCF #2 — mode `ABAttorney` — used only for `ABAttorney` contacts.
- PCF #3 — modes `ABPerson` and `ABPolicyPerson` — used for those two subtypes.

**The type hierarchy is:** `ABPerson` → `ABPersonVendor` → (`ABAttorney`, `ABDoctor`).

Despite `ABPersonVendor` being a subtype of `ABPerson`, and `ABDoctor` being a sibling of `ABAttorney` under `ABPersonVendor`:
- **`ABPersonVendor` contacts use the default PCF** — not the `ABPerson`-mode PCF, even though it's a descendant of `ABPerson`.
- **`ABDoctor` contacts also use the default PCF** — not the `ABAttorney`-mode PCF, even though `ABDoctor` and `ABAttorney` are siblings under the same parent.

**Rule:** mode matching only picks up a PCF if the object's type is **explicitly listed** as one of that PCF's modes. It does **not** walk up the type hierarchy to find an ancestor's matching mode, and it does **not** apply a sibling type's mode. Anything not explicitly listed falls straight to default, regardless of how "close" it is in the type hierarchy to a type that *is* explicitly listed.

## PolicyCenter: Modes for Transaction Type

In PolicyCenter, modes are also used to handle variations by **policy transaction type** — submission, change, renewal, cancellation, etc. This confirms and validates the `submission`/`policychange`-style mode name examples previously noted (with lower confidence) in `/context/05-shared-sections-and-modes.md` — same underlying pattern, now backed by a higher-confidence source.

## Naming Conventions for Modes (three distinct cases)

See `/rules/01-naming-and-organization.md` for the consolidated rule. Summary:

1. **Adding a new mode to an existing BASE product PCF** → suffix the **mode name** with `_Ext`. Example: base file `ABCompanyVendorSpecialtyInputSet.pcf` gets a new mode for Auto Rental Agencies named `ABAutoRentalAgcy_Ext`.
2. **Creating an entirely new modal PCF (new file)** → suffix the **PCF name** with `_Ext`, inserted before the type suffix. Example: `ABGenericVendor_ExtInputSet` (name `ABGenericVendor` + `_Ext` + type suffix `InputSet`). Note: for Input Sets, the appended type suffix is the full word `InputSet`, not an abbreviation like `LV`/`DV`.
3. **Modes defined on a PCF that is already fully custom** (per case 2) do **not** need `_Ext` on the mode name itself — the file is already custom, so there's no collision risk with a base-product mode name. Example: mode `ABGenericType` (no `_Ext`) on the custom `ABGenericVendor_ExtInputSet` file.
