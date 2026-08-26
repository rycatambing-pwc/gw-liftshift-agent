# Location Groups

Source: Guidewire Education module (highest confidence). Extends `/context/03-locations-reference.md` and `/context/13-navigating-to-locations.md`.

## What a Location Group Is

A collection of Locations, providing structure and navigation for a group of related pages. Recap of UI elements (consistent with `/context/03-locations-reference.md`):

- **Tab bar** — tabs across the top of the application
- **Info bar** — widgets below the tabs, above the screen area (some Location Groups have none — the strip is simply absent)
- **Menu actions** — collapsed inside the Actions menu
- **Menu links** — clickable labels in the sidebar (e.g. "Summary," "Invoices")

As a user navigates between Locations *within* a Location Group, the menu links, Actions menu, Tab bar, and Info bar **stay the same** — only the screen area content changes.

## Location Group Properties (file references)

A Location Group can specify three optional properties, each pointing to a file:
- `tabBar` — file supplying Tab Bar content
- `infoBar` — file supplying Info Bar content
- `menuActions` — file supplying Actions menu content

(In Guidewire Studio, Ctrl+click on any of these property values to open the referenced file directly.)

## Contents and Nesting

A Location Group's contents are **pages, child location groups, or both.** Pages are the most common; ultimately, the "groups" inside a Location Group are groups of pages. A **child location group** is simply a sub-group of pages.

A **location ref** (menu link) points to either a Page or another Location Group:
- Points to a **Page** → clicking renders that page's screen alone.
- Points to a **Location Group** → clicking renders that group as a new set of menu links, and the first location ref's page inside it is rendered by default.

### First-Level vs. Second-Level Navigation Groups

| | First-Level ("parent-level") | Second-Level ("child-level") |
|---|---|---|
| How it's reached | A Tab points to it (directly or via a Forward) | Nested inside another Location Group |
| Info Bar / menu actions | Displayed if defined | Typically absent |
| Can contain | Pages **and** other Location Groups | Typically only Pages or child Location Groups |

**BillingCenter supports multiple levels of nested Location Groups — but this is explicitly NOT recommended.** (Rule candidate.)

## Entry Points

A Location Group has one or more named **Entry Points**, each defining what argument(s) it expects.

- Example: `AccountGroup`'s entry point (also named `AccountGroup`) expects a single `Account` object, referred to inside the page as `"account"`.
- A Location Group **can have multiple entry points** — useful when the same Location Group is reached from different places with different known context.
- A Location Group **may require no arguments at all** — e.g. the `Admin` Location Group's entry point is `Admin()`, taking nothing.

## Navigation Action Syntax (General — this is the unifying rule behind everything we'd seen piecemeal)

Most navigation-triggering widgets have an `action` attribute with this syntax:

```
LocationEntryPoint.method(objectList)
```

- **`LocationEntryPoint`** — an entry point name defined on the destination Location's Entry Points tab.
- **`method`** — `"push"` or `"go"`. **For Location Groups specifically, this is always `"go"`.**
- **`objectList`** — a comma-delimited list of zero-to-many objects, matching the count and types the entry point expects.

**Example:** in `TabBar.pcf`, the Desktop tab's action is `DesktopGroup.go()` — invoking the `DesktopGroup` entry point defined in `DesktopGroup.pcf`, with zero arguments.

### How this unifies earlier findings

| Target Location type | Method seen/documented | Source |
|---|---|---|
| Popup | `.push(arg)` | Confirmed real code: `APDNewExposurePopup.push(riskCoverable)` |
| Location Group | `.go()` — **always**, per this module | This module: `DesktopGroup.go()` |
| Wizard | `.go()` typically in ClaimCenter/PolicyCenter; `.push()` typically in BillingCenter | Earlier module — product-dependent |

So the underlying syntax (`EntryPoint.method(args)`) is constant; **which method applies depends on the target Location type, and for Wizards specifically, also on which product.** Location Groups are the one case confirmed to be method-fixed regardless of product.

## Naming Convention

No file-extension/suffix is strictly required for a Location Group's filename, but it's **good practice to add the suffix `Group`** (e.g. `AccountGroup`, `DesktopGroup` — matches both examples given).

> Open question: how this `Group` suffix convention interacts with the `_Ext` custom-file convention (`/rules/01-naming-and-organization.md`) for a *custom* Location Group isn't confirmed — e.g. is it `MyCustom_ExtGroup` or `MyCustomGroup_Ext`? Flagged in `/unresolved/01-open-questions.md`.
