# Skill: Creating a New Page

A step-by-step recipe for creating a new Page Location, from a Guidewire Education module. Use this as the default checklist whenever the task is "add a new page to [some Location Group]."

## Steps

1. **Create a new PCF file of type `Page`.**
2. **Set essential information:**
   - `title`
   - An **entry point**, with a matching variable (configured on the Entry Points tab)
   - A **variable for each object** the entry point expects (configured on the Variables tab)
3. **Add a Screen** to the page.
4. **Include panels** for viewable and/or editable content — typically via `PanelRef` (see `/context/05-shared-sections-and-modes.md`) referencing existing or new Detail View / List View / Input Set files.
5. **If the page should be editable:**
   - Set the `canEdit` property (see `/context/15-pages-visibility-and-editability.md` — remember `canEdit=false` overrides `startInEditMode=true`).
   - Add **EditButtons** to the page's Screen (standard Edit/Update/Cancel workflow — see `/rules/04-toolbar-placement-and-edit-workflow.md`).
6. **Wire up navigation:** in the Location Group that should contain this page, add a `locationref` widget pointing to the new page (via its `location` attribute — see the open question about this attribute's exact syntax in `/unresolved/01-open-questions.md`).

## Things to check before considering this done

- Does the page need visibility restrictions? Set `canVisit` appropriately — if false, the page won't even show a link (`/context/15-pages-visibility-and-editability.md`).
- Does the entry point's declared object list match what's actually being passed at every call site that navigates here (`/rules/06-navigation-syntax.md`)?
- If this page is meant to be read-only-by-default with edit as an exception, don't rely on `startInEditMode` alone — verify `canEdit` isn't inadvertently blocking it.
