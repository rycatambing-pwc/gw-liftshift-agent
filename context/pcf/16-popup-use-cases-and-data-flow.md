# Popups: Use Cases and Data Flow

Source: Guidewire Education module. Extends `/context/03-locations-reference.md` (structural definition: single screen + "Return to `<previous location>`" link).

## Why Popups Work This Way (the design rationale)

A true browser-level popup (a genuinely separate window) is architecturally difficult: there's no easy way to avoid synchronization errors when the system tries to update the same object from two separate windows at once. Guidewire's Popup Location design — a screen that *mimics* a popup rather than literally being one — gets virtually the same UX benefit (interim action without losing the original task's context) while avoiding that synchronization/usability problem.

## Three Use Cases

### 1. View / Edit an Existing Object

Used when a location (often a List View) doesn't conveniently support viewing/editing all of an object's fields inline. A List View typically shows only a limited set of fields; some cells can be configured as **navigation cell widgets** that navigate to a Popup, letting the user view/edit the fuller set of fields there.

**Real example:** `FlagEntryPopup` — views existing flag entry objects, and edits them if the user has sufficient permission. It does **not** support creating flag entries — those are created only by application business logic, never manually by a user.

**Data flow for edit-existing:** the popup does **not** return the object to the parent List View. The parent already knows about the object (it's already in the array the List View displays) — so the popup simply **commits changes directly to the database**, and the parent List View **refreshes its data from the database** afterward. No object hand-off is needed.

### 2. Create a New Object

A popup can also be configured to create new objects — often the same popup handles both create and edit-existing.

**Data flow for create-new — different from edit-existing:** the source container (often a List View Panel) does **not** already know about the new object. So the popup **must return the new object to the source container**, and the source container is then responsible for **committing that object into the appropriate array** associated with its parent object.

> This is the conceptual contract behind the "creation popup" pattern flagged as out-of-scope in `/context/09-list-view-editability.md` (Add-button Pattern B). We now know the *shape* of what needs to happen (object must be returned to the caller, caller commits it into its array) even though the exact PCF syntax for "returning" a value from a popup hasn't been seen yet. See `/unresolved/01-open-questions.md`.

### 3. Search for an Existing Record

A popup can implement search functionality ("a popped search") for situations where it wouldn't be convenient to include inline search directly in the surrounding UI.

## Summary Table

| Use case | Does popup return a value to caller? | What happens on commit |
|---|---|---|
| View/edit existing object | No | Popup commits directly to DB; parent refreshes from DB |
| Create new object | **Yes** — must return the new object | Source container commits the returned object into its own array |
| Search for a record | (Likely yes — the found record needs to get back to the caller, though this isn't explicitly confirmed) | N/A |
