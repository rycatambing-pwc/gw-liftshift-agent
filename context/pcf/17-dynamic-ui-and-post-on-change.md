# Dynamic UI Basics

Source: Guidewire Education module. This is the "later lesson" on dynamic updates flagged as a follow-up in `/context/12-input-sets.md`.

## Static vs. Dynamic Widget Properties

- **Static property** (e.g. `id`) — a fixed value (String, Integer, etc.). No expression is evaluated; it never changes based on application state or business data.
- **Dynamic property** — evaluates an expression, so its effective value can change based on state/data:
  - `editable` — evaluates a boolean expression
  - `label` — evaluates a string expression
  - `value` — evaluates an object expression, binding to an object property
  - `visible` — evaluates a boolean expression; **default value is `true`**. In practice, `visible` is typically either left as `true` or set to an expression — it's not commonly set to a literal `false`.

Not all widgets have all properties — the **PCF Format Reference** defines, per widget, which properties (called **"attributes"** in that reference) exist and what value type each takes.

> ⚠️ FILENAME DISCREPANCY: this module states the PCF Format Reference is opened via `<ApplicationRootDirectory>\modules\pcf.htm`. Every earlier mention (several times, across different sources) said `pcf.html`. Likely an imprecise transcription somewhere, but flagging rather than silently resolving — confirm the real filename before telling anyone where to look. See `/unresolved/01-open-questions.md`.

## Dynamic Properties vs. Dynamic Behavior — Key Distinction

| | Dynamic Properties | Dynamic Behavior |
|---|---|---|
| When it takes effect | After navigating to a page, or after clicking **Update** | While the user is actively editing a field, **before** committing |
| Is it saved to the DB? | Yes — represents data already committed | No — not yet committed; purely a live UI reflection |
| Resource cost | Higher — involves DB commit / page navigation | Lower — local only, no DB round-trip |
| Example mechanism | `visible`/`editable`/`label`/`value` expressions evaluated on load/update | **Post-on-Change** |

## Post-on-Change

A configured dynamic behavior: a specific field (the **trigger widget**) is marked with Post-on-Change enabled. When its value changes, that change is posted to the server *without* a full commit, and the server evaluates other fields on the screen to see if anything should now become visible/change based on the new trigger value.

**Real example:** a "Was there a collision?" field in a ClaimCenter vehicle incident. It starts with no value. When the user sets it, the change posts to the server, which checks other fields whose `visible` property tests this collision indicator for `true`. If satisfied, those additional fields appear on screen — all without a page reload or DB commit.

**Configuration facts:**
- Post-on-Change is defined **on the triggering widget**, and has exactly **one** trigger widget.
- **If no properties are set on the PostOnChange tab:** the server just determines whether other values should change based on the new trigger value, and tells the browser to redraw — this is the default, no-extra-config behavior.
- The **`onChange`** property can additionally execute a **Gosu expression** to take a specific action when the trigger value changes, for cases needing more than a simple redraw.

## Why This Matters (performance framing)

Both dynamic properties and dynamic behavior give users immediate feedback as they edit — but **dynamic behavior (Post-on-Change) uses fewer system resources**, since it's local and doesn't commit to the database. When a reactive UI update doesn't actually need to be persisted yet, prefer Post-on-Change over forcing a full Update/commit cycle just to get related fields to refresh.
