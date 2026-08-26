# UI Field-Level Validation

Source: Guidewire Education module.

## What Field-Level Validation Does

Prevents a user from saving a page's contents if a field's entered data doesn't match a **regular expression**. This saves an unnecessary network round trip to the application/database — the browser can reject invalid input before ever submitting it.

- **Validation** (general) — application behavior preventing invalid business data from being saved.
- **Field-level validation** (specific) — validation tied to a particular field via a regex pattern.
- **Input mask** — shows a watermark guiding the user toward the expected format (e.g. `###-##-####` for a US Social Security Number). An input mask **does not itself restrict what can be saved** — it's a visual guide only. However, if the input mask's pattern matches the field's regex, then attempting to save data that doesn't follow that pattern will still be blocked — by the regex, not by the mask itself.

## Two Tiers of Validation — Choosing Which to Use

| | Data Model Validation | UI (Field-Level) Validation |
|---|---|---|
| Scope | Applies statically, across the **entire application**, regardless of entry point | Tied to a specific field on a specific PCF (or mode) |
| Use when | The constraint should hold everywhere, including via API — e.g. a UK insurer requiring a National Health number to always be exactly 10 decimal digits, whether entered via UI or another application's API | The valid format legitimately **varies by context** — e.g. phone number format differing by country, shown via different modal PCFs (see `/context/20-modes-dispatch-and-defaults.md`) |

**Rule of thumb:** if the format constraint is a universal business rule independent of how data enters the system, use data model validation. If the constraint depends on UI context (which mode/PCF/locale is active), use UI-level regex validation.

## Real Pattern: Context-Dependent Regex via a Function

A `getPostalCodeRegex()` Gosu function returns a different regex depending on the address's country — one pattern for Canada, another for the US, and a null string if the country is neither (extendable to more countries as needed). A text input's **`regex`** property is set to call this function, so the effective validation pattern adapts to context automatically.

**Architectural best practice:** the example placed this function on the PCF's **Code tab** for illustration, but recommends putting it on an **enhancement or helper class** instead in real implementations. Benefits:
- Reusable across **multiple PCFs**, not locked to one file.
- **Single place to modify** if the logic needs to change, rather than updating it redundantly across every PCF that needs it.

(This is the same underlying principle as `/rules/02-code-and-content-practices.md`'s "minimize Gosu in `<Code>` blocks, extract to reusable Gosu classes" guidance — this module gives a concrete validation-specific example of exactly that principle in action.)

## Why UI-Level Validation Specifically Helps

- The browser can validate format **before** sending data to the server — cheaper than round-tripping to validate at the database.
- Enables **context-based flexibility** — the same logical field (e.g. "postal code") can have different valid formats depending on context, which a single database-level constraint couldn't express as easily.

## Learning Resources (for humans writing regex, not for the agent to fetch)

The source module points to: Codecademy's regex intro, freeCodeCamp's regex course, and RegexOne — general regex learning resources, not Guidewire-specific.
