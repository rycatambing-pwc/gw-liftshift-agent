# Skill: Making a Field Navigate to an Existing Popup

Use this when the requirement is "clicking on [some field/value] should open [an already-existing Popup]" — the popup itself doesn't need to be built, only the navigation wiring.

## When to use this pattern

- A Popup PCF already exists (e.g. a detail popup for a related entity).
- Some field or link elsewhere in the UI should trigger it, typically passing along the relevant entity as an argument.
- Permission/visibility logic is already handled inside the target popup — don't duplicate it in the calling widget unless the requirement specifically calls for different, additional restriction at the call site.

## Steps

1. **Identify the target Popup's PCF name** and what root object/argument it requires (check its `<Require>` declaration — see `/context/05-shared-sections-and-modes.md`).
2. **Identify the calling widget** — typically a field, link, or button that should trigger navigation.
3. **Wire the `action` attribute** on that widget to call `.push()` on the popup's name, passing the required argument:

```xml
action="SomePopupName.push(theRequiredArgument)"
```

(Confirmed real-code pattern — see `/context/13-navigating-to-locations.md` for the sourced example, and `/skills/01-building-a-cardview-summary-panel.md` for a `.push()` call in context.)

4. **Do not re-implement permission checks** already handled inside the target popup, unless the specific requirement calls for an additional, different restriction at the calling site.

## Cross-references

- `.push()` vs `.go()` — `.push()` is the confirmed method for opening a Popup. `.go()`/`.push()` also relate to Wizard navigation, but that's a separate, product-specific fact — see `/context/13-navigating-to-locations.md` for why these aren't the same rule.
- Popup's underlying structure (single Screen + "Return to `<Location>`" link) — `/context/03-locations-reference.md`.
