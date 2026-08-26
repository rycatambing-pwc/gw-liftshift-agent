# Pages: Visibility, Editability, and Location Refs

Source: Guidewire Education module. Extends `/context/03-locations-reference.md` and `/context/14-location-groups.md`.

## Recap

A Page is a Location with exactly one Screen. Most Locations defined in an InsuranceSuite application are Pages. A Page typically contains just a Screen with `PanelRef`s to the views embedded within it (Studio's rendering can look complex because all embedded elements are shown, even though the source is simple).

## Visibility: `canVisit`

A user can see a link to (and therefore navigate to) a Page **only if `canVisit` evaluates to true.** If false, the page isn't just read-only — it's not link-able/reachable at all.

## Editability: `canEdit` and `startInEditMode`

- `canEdit` controls whether a page can be in edit mode at all.
- **If `canEdit` evaluates to false, the page is read-only — even if `startInEditMode` is set to true.** `canEdit` wins.
- **`canEdit` exists on single-screen Locations and Wizards.**
- **Location Groups do NOT have a `canEdit` property** — editability for a Location Group is controlled at the **per-page** level, not at the group level.

## `locationref` Widget — the `location` Attribute

Each location ref (menu link) inside a Location Group has a **`location`** attribute specifying the destination (typically a child Location Group or a Page). If the destination requires one or more objects, the `location` attribute must specify which objects to pass.

> Open question: this declarative `location` attribute (used on menu-link location refs within a Location Group) may or may not use the same `EntryPoint.method(objectList)` syntax documented for `action` attributes in `/rules/06-navigation-syntax.md` — that syntax was described for navigation-triggering widgets like buttons, not specifically for a Location Group's internal menu-link definitions. Treat as a related-but-not-yet-confirmed-identical mechanism. See `/unresolved/01-open-questions.md`.
