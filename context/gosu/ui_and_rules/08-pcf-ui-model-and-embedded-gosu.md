---
document: pcf-ui-model-and-embedded-gosu
purpose: Gosu-specific behavior inside PCF — embedded expressions, variable scope, dynamic behavior, validation
scope: RowIterator elementName, validation expressions, PostOnChange, Client Reflection, performance, UI helper classes
note: PCF structure (widget hierarchy, location types, DetailView, PanelRef) is covered in /context/pcf/. This file covers only what the Gosu agent needs when reading or writing embedded Gosu expressions inside PCF files.
---

# Embedded Gosu in PCF Files

For PCF structure (widget/location hierarchy, DetailView inline vs. reusable, PanelRef/Require, modes), see `/context/pcf/`.

## Variable scope inside PCF

Embedded Gosu expressions resolve against these scopes (in lookup order):

1. Local PCF variables declared with `<Variable>`
2. The PCF file's root object (declared via `<Require>`)
3. Row iterator `elementName` — inside a ListView row, this is the current row object
4. PCF-level mode context

**Agent rule:** when an expression references a symbol that doesn't exist on any obvious class, check PCF variables and `elementName` before concluding it's unresolved.

## RowIterator / ListView scope

A ListView renders rows via a RowIterator. Inside any row cell expression, the current element is accessed by the iterator's `elementName` — NOT the parent root object.

```xml
<RowIterator elementName="activity" value="policy.Activities" valueType="Activity">
  <Cell value="activity.Subject"/>   <!-- activity = elementName, not policy -->
</RowIterator>
```

Agent rule: if a ListView row expression refers to a symbol without qualification, it is almost always `elementName`, not the parent root.

If a ListView is query-backed, all query performance rules apply — pushing predicates to `compare()` before `select()` rather than post-query in-memory filtering.

## View entities for ListView performance

View entities provide a logical view of entity data that reduces dot-path expansion in ListViews. When a ListView accesses multiple related entity fields (e.g. `activity.Policy.Account.Name`), check whether a view entity exists or should be created.

## Toolbar filters

Toolbar filters can filter query-backed ListViews at the database level. Hidden default filters may have:
- `visible = false`
- `selectOnEnter = true`

Agent rule: if a filter property calls a Gosu function, check whether it limits the result set at the query level (good) or triggers in-memory filtering (bad).

## Dynamic behavior: PostOnChange

`PostOnChange` causes a server roundtrip when a field value changes:
- Defined on the triggering widget
- `onChange` attribute executes a Gosu expression on the server
- **Avoid expensive logic in `onChange`** — it fires on every change, often mid-edit

```xml
<Input value="claim.LossCause">
  <PostOnChange onChange="recalculateReserve(claim)"/>
</Input>
```

## Dynamic behavior: Client Reflection

Client Reflection updates other widgets without a server roundtrip:
- Defined on the *listening* widget, not the trigger
- Uses `triggerIds` to name the triggering widget
- Uses the `VALUE` token to reference the current trigger value
- Better than PostOnChange for simple show/hide or label-update reactions

## Expensive PCF expression patterns

These patterns evaluated per-row or per-render are the most common Gosu performance issues in PCF:

| Expensive pattern | Preferred alternative |
|---|---|
| Multi-step dot path: `row.Policy.Account.Name` | PCF variable or view entity |
| Spread in cell: `activities*.Subject` | Query or precomputed collection |
| Collection method in attribute: `visible="policy.Lines.hasMatch(\l -> l.Active)"` | PCF variable computed once |
| Complex method call in `value=` or `visible=` | UI helper class method |

Prefer:
- PCF-level `<Variable>` elements for values computed once per render
- Row iterator variables for values computed once per row
- Query-backed filtering over post-select in-memory filtering
- UI helper classes (`MyScreenHelper.gs`) for logic too complex for inline PCF expressions

## UI validation expressions

`validationExpression` on a widget:
- Runs when the widget's value changes
- Return `null` to allow save; return a `String` message to block save and highlight the field
- Good for simple single-field checks

`requestValidationExpression` on a widget:
- Runs on every server request, not just on change
- Use sparingly — fires more frequently

**Do not confuse with Gosu validation rules** in `.gr` files, which run during commit/API validation and are defined in the rule engine, not inline in PCF.

## UI helper class pattern

When PCF Code tab logic grows beyond a few lines, extract it to a dedicated helper class:

```gosu
// PolicySummaryScreenHelper.gs
class PolicySummaryScreenHelper {
  static function isRenewalEligible(period : PolicyPeriod) : boolean {
    return period.Status == PolicyStatus.TC_BOUND
        and period.ExpirationDate > DateUtil.today()
  }
}
```

```xml
<!-- In PCF -->
<Cell value="PolicySummaryScreenHelper.isRenewalEligible(period)"/>
```

Avoid:
- Large `<Code>` blocks in PCF
- Entity enhancements used only for one screen's UI logic
