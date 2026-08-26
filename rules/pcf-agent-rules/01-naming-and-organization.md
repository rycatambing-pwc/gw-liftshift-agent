# Naming and Organization Rules

These are firm conventions, not suggestions — violating them creates upgrade-merge risk or naming collisions with future Guidewire base updates.

## Custom File Naming: `_Ext` Suffix

- Every custom PCF file name must include the **`_Ext`** suffix.
- For container PCFs whose type carries a framework-determined suffix (e.g. ListViews, DetailViews), type the name with `_Ext` and let the **UI framework auto-append** its own suffix — do not manually add it.
  - Example: typing `ClaimContacts_Ext` for a new ListView produces `ClaimContacts_ExtLV`.
  - Framework suffixes seen so far: `LV` (ListView), `DV` (DetailView). There are likely others per element type not yet confirmed.
- The `_Ext` suffix also applies to the **`ID` property** of any custom variable or PCF element added inside a **base product (OOTB)** PCF — not just to new file names.

## Package/Folder Placement

- Place custom PCFs in the appropriate existing or custom PCF package/folder.
- Keep related PCFs together in the same package.
- Follow the established per-product folder structure (see `/context/06-folder-and-package-structure.md`) — don't invent new top-level folders.

## Prefer Modifying Base Files

- Modify existing base configuration files wherever possible.
- Create new PCF files only when a base file genuinely cannot accommodate the requirement.
- This minimizes upgrade-merge conflicts and keeps customization surface area small (see MMC principle in `/context/01-pcf-overview.md`).

## Mode Naming Conventions (three distinct cases)

Full mechanics: `/context/20-modes-dispatch-and-defaults.md`.

1. **Adding a new mode to an existing BASE product PCF** → suffix the **mode name itself** with `_Ext`. Example: `ABAutoRentalAgcy_Ext` as a new mode added to base file `ABCompanyVendorSpecialtyInputSet.pcf`.
2. **Creating an entirely new modal PCF (a new file)** → suffix the **PCF name** with `_Ext`, inserted before the type suffix — same pattern as the general `_Ext` + auto-appended-type-suffix rule above. Example: `ABGenericVendor_ExtInputSet` (for Input Sets, the appended type suffix is the full word `InputSet`, confirming/resolving the earlier open question about Input Set's auto-suffix — it is not abbreviated like `LV`/`DV`).
3. **Modes defined on a PCF that is already fully custom** (per case 2) do **not** need `_Ext` on the mode name — the file itself is already custom, so there's no base-product collision risk. Example: mode `ABGenericType` (no `_Ext`) on a custom Input Set file.

**Don't confuse cases 1 and 2** — case 1 puts `_Ext` on the *mode name* because the *file* is base product; case 2 puts `_Ext` on the *file name* because the whole file is new/custom.
