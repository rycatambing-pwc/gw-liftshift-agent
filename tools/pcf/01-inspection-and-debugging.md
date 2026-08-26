# PCF Inspection and Debugging Tools

## Keyboard Shortcuts (in a running application, for tracing UI back to source PCF)

| Shortcut | Effect |
|---|---|
| `Alt+Shift+W` | Opens the **widget inspector** in a new browser window — shows all PCF files and internal widget details involved in rendering what's on screen. |
| `Alt+Shift+I` | Opens a **focused file-structure view** in a new browser window — helps identify how the PCF file is put together at a higher level. |
| `Alt+Shift+E` | Opens the **main PCF for the current screen directly in Studio's PCF editor.** |

Use `W` for deep widget-level detail, `I` for a structural overview, `E` to jump straight into editing.

## Guidewire Studio's PCF Editor — Inclusion Tracing (for human reference; relevant conceptually even though Claude Code edits PCF as text)

The Studio PCF editor color-codes widgets by where they're actually defined:

| Color | Meaning |
|---|---|
| Gray | Defined directly in the file being viewed |
| Light blue | Defined in a PCF referenced by this PCF (one level of inclusion) |
| Darker blue | Referenced indirectly through another PCF (multiple levels deep) |

This is useful conceptually when reasoning about *why* a widget behaves a certain way — the "real" definition may live several files away from where it visually appears.

## The Authoritative Schema Reference (not yet obtained)

`modules/pcf.html`, inside an actual InsuranceSuite installation, is repeatedly cited as the complete, authoritative per-element/per-attribute PCF reference. It has not been successfully retrieved via public web documentation — it may only be accessible from a real installation or Guidewire Studio itself. If accessible to the team, pulling its content should be a high priority; it would resolve most of the open questions in `/unresolved/01-open-questions.md`.
