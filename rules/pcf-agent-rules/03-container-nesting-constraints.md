# Container Nesting Constraints

These are structural legality rules, not stylistic preferences — violating them produces invalid PCF. Full conceptual background in `/context/02-element-hierarchy-and-containers.md`.

## Containment Rules

- **Atomic widgets** (inputs, buttons, cells) can only be **directly** contained by **primary containers** (Detail View, List View) — never placed directly on a Screen or a secondary container (Card, List Detail Panel).
- **Detail View can contain List View. List View cannot contain Detail View.** This direction is fixed.
- **Secondary views can contain other secondary views**, in addition to primary containers.
- **Screens** can directly contain primary views and secondary views, but not atomic widgets directly.

## Input Set Exception

- An **Input Set** must always be embedded inside a **Detail View Panel**, or nested inside another Input Set.
- An Input Set can **never** be referenced directly by a Screen or a secondary container (Card / List Detail Panel) — even though it otherwise behaves like a primary container.
- An Input Set can **never** have a toolbar directly attached to it.
- **Unlike a Detail View Panel, an Input Set cannot contain columns** (no `InputColumn` inside an Input Set).

## List View Inside a Detail View — the `ListViewInput` Exception

Detail View and List View are both **primary containers**, and primary containers can normally only hold atomic widgets — not other containers. This means `PanelRef` **cannot** be used to place a List View inside a Detail View.

**Workaround:** use the **`ListViewInput`** widget. It forces the List View to behave *as if it were* an atomic widget, which means:
- It can be placed anywhere inside a Detail View's `InputColumn`.
- It can take a **label**, just like a normal atomic widget.

Exact attribute syntax for `ListViewInput` is not yet confirmed from real code — treat the placement rule as confirmed, but verify syntax before generating it. See `/context/08-list-view-architecture.md` and `/unresolved/01-open-questions.md`.

## Popup Structural Requirement

A Popup is not a literal modal window — it is a single Screen with a **"Return to `<previous Location>`"** link, and it returns the user to the previous Location on close. Any generated Popup must include this return-link element; omitting it produces a Popup that doesn't behave correctly, even if it looks visually correct.

## Mode Hygiene (for shared/reusable sections)

- Use descriptive mode names (`"submission"`, `"policychange"`, `"viewonly"`) — never generic placeholders (`"mode1"`, `"variant"`).
- If a shared section needs more than ~3–4 distinct modes, split it into separate purpose-built sections instead of over-loading one file.
- Document mode usage in comments: which modes exist, when each is used, which screens/popups include them.
