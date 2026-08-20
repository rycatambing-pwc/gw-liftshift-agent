# Locations Reference

Source: Guidewire Education module 3 (highest confidence).

A **Location** is a PCF element a user can navigate to. Locations don't define visual content directly, but can contain Screens that do. They provide hierarchical organization, assist navigation, and can gate access via system permissions.

## Page
- A Location with **exactly one Screen**.
- Used **exclusively** within Location Groups.

## Location Group
- A collection of Pages, each with its own Screen.
- Groups screens that either display data about one primary object (contact, policy, account, claim) or serve one major function (e.g. search).
- All pages in a Location Group share a common info bar, actions menu, and side bar:

| Region | Purpose |
|---|---|
| Side bar | Navigate between pages within the Location Group |
| Tab bar | Navigate to different parts of the application |
| Info bar | High-level info/icons about the screen's data (some Location Groups have none) |
| Actions menu | Accessible via the Actions control |

## Wizard
- A collection of Screens executing a complex business process; only **one Screen displayed at a time**.
- Single info bar, actions menu, side bar, plus **Back/Next** controls.
- Screens have a defined order, though out-of-order traversal is sometimes allowed.
- **Implemented differently per Guidewire application** (PolicyCenter/ClaimCenter/BillingCenter wizards are not identical under the hood).

## Popup
- Lets the user perform an interim action without leaving the current task's context.
- **Mechanically**: a single Screen with a "Return to `<previous Location>`" link — **designed to mimic** a true modal, but not a literal separate browser window. Returns the user to the previous Location on close.
- Any Popup-building skill/template must include this return-link element, not just modal-style CSS.

## Worksheet
- A single, separate Screen rendered in the **workspace frame** — the one UI area that's not always visible (only visible when a screen is displayed in it).
- Multiple worksheets open at once are navigated via tabs across their top.
- Key advantage: can be viewed **at the same time as regular pages** — good fit for tasks like creating a new note.

## Forward
- Contains logic executed **before** navigating elsewhere — typically decides *which* Location to go to.
- Has no Screen, therefore no visual content.
- Used to modify data pre-navigation, or pick a destination based on data context or user permissions.

## Exit Point
- Points to a URL **outside** the Guidewire application (e.g. an external reporting tool).
- Does **not** contain a Screen widget, directly or indirectly.
