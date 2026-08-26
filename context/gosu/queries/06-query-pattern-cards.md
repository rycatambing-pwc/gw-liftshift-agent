---
document: gosu-query-pattern-cards
purpose: Reusable Guidewire Query API analysis cards
scope: Entity queries, joins, subselects, row queries, result access, updates, advanced query features
---

# Query Pattern Cards

## Q1: Basic entity select

<triggers>`Query.make(Entity)`, `.compare(...)`, `.select()`</triggers>

```gosu
var query = Query.make(Address)
query.compare(Address#State, Equals, typekey.State.TC_IL)
var results = query.select()
```

Analysis:

- Primary entity: `Address`.
- Predicate: `Address#State == typekey.State.TC_IL`.
- `Address#State` is a property reference.
- If the field is a typekey, compare to a typekey, not a string.

Verification:

- Verify field exists in `.eti/.etx` or generated docs.
- Verify exact typekey constant in `.tti/.ttx/.tix`.

## Q2: Multiple predicates on one query

```gosu
var query = Query.make(Claim)
query.compare(Claim#LossCause, Equals, LossCause.TC_VEHCOLLISION)
query.compare(Claim#State, Equals, ClaimState.TC_OPEN)
var results = query.select()
```

Analysis:

- Multiple `compare` calls usually combine restrictions on the same query.
- Prefer this over building two queries and intersecting when possible.

## Q3: Case-insensitive compare

```gosu
var query = Query.make(ABPerson)
query.compareIgnoreCase(ABPerson#Nickname, Relop.Equals, nickname)
var results = query.select()
```

Analysis:

- Used for case-insensitive search.
- Check whether the search column supports linguistic/case-insensitive search in project metadata.

## Q4: `compareIn` / `compareNotIn`

Intent: filter an outer query by values produced by another query or set.

```gosu
var query = Query.make(Activity)
query.compareIn(Activity#Status, {ActivityStatus.TC_OPEN, ActivityStatus.TC_COMPLETE})
```

Analysis:

- Verify collection element type matches the field type.
- For typekey fields, the values must be typekeys.

## Q5: Join query

```gosu
var queryCompany = Query.make(Company)
var tableAddress = queryCompany.join(Company#PrimaryAddress)
queryCompany.compare(Company#Name, Equals, "Stewart Media")
tableAddress.compare(Address#City, Equals, "Chicago")
```

Analysis:

- Primary returned entity: `Company`.
- Join traverses `Company#PrimaryAddress`.
- Join conditions use the joined entity field, here `Address#City`.

Verify FK direction and field names.

## Q6: Subselect / exists-like child condition

```gosu
var parentQuery = Query.make(User)
var childQuery = Query.make(Note)
childQuery.compareIn(Note#Topic, {NoteTopicType.TC_GENERAL, NoteTopicType.TC_LITIGATION})
parentQuery.subselect(User#ID, InOperation.CompareIn, childQuery, Note#Author)
```

Analysis:

- Outer query returns `User`.
- Inner query returns `Note`.
- Subselect compares outer `User#ID` to inner `Note#Author`.
- Verify operation and property-reference types.

## Q7: Union query

```gosu
var claimStateQuery = Query.make(Claim)
claimStateQuery.compare(Claim#State, Equals, ClaimState.TC_OPEN)

var activityStatusQuery = Query.make(Activity)
activityStatusQuery.compare(Activity#Status, Equals, ActivityStatus.TC_OPEN)

var compareInQuery = Query.make(Claim)
compareInQuery.subselect(Claim#ID, InOperation.CompareIn, activityStatusQuery, Activity#Claim)

var unionQuery = claimStateQuery.union(compareInQuery)
var results = unionQuery.select()
```

Analysis:

- Use when separate query branches are clearer or more performant than an OR with subselect.
- Verify both branches return the same primary entity type.

## Q8: Result existence check

```gosu
var results = query.select()
var exists = not results.Empty
```

Analysis:

- `results.Empty` is faster than `results.Count == 0` — prefer it for existence checks.
- If actual entities are not needed, check existence rather than iterating or counting.
- Avoid `hasMatch`, `countWhere`, and `select().Count` when only existence is needed.

## Q9: First result

```gosu
var first = query.select().FirstResult
```

Analysis:

- Use when only one row/first row is needed.
- Avoid counting before accessing first result unless count itself is needed.

## Q10: Count result

```gosu
var count = Query.make(Claim).select().Count
```

Analysis:

- Prefer database/result count over converting to list and counting.
- If threshold logic is enough, use `getCountLimitedBy(n)`:

```gosu
var tooMany = query.select().getCountLimitedBy(11) > 10
```

## Q11: Row query / selected columns / database aggregate

Use when the code is selecting columns or aggregate values rather than entity instances.

Analysis:

- Entity query returns entities.
- Row query returns rows/columns/aggregate values.
- Do not call in-memory `.sum(...)` a database aggregate unless the API actually uses row-query aggregate syntax.

## Q12: In-memory post-processing after query

```gosu
var expensive = Query.make(PolicyPeriod)
  .select()
  .where(\ p -> p.TotalPremiumRPT > 1000bd)
```

Analysis:

- `.where` after `.select()` is not the same as a database predicate.
- Prefer `.compare(...)` before `.select()` when possible.

## Q13: Updating query result entities

```gosu
gw.transaction.Transaction.runWithNewBundle(\ bundle -> {
  var readOnlyPeriod = query.select().FirstResult
  var writablePeriod = bundle.add(readOnlyPeriod)
  writablePeriod.Status = typekey.SomeStatus.TC_BOUND
})
```

Analysis:

- Query-returned entities may be read-only.
- Modify the returned value from `bundle.add(...)`, not the original read-only reference.
- Verify exact typekey.

## Q14: Distinct results

```gosu
var query = Query.make(Entity)
query.withDistinct(true)
query.compare(...)
var results = query.select()
```

## Q15: Between / range filter

```gosu
var query = Query.make(Policy)
query.between(Policy#EffectiveDate, startDate, endDate)
var results = query.select()
```

## Q16: String contains / starts-with filters

```gosu
query.contains(Claim#Description, "collision", false)   // false = case-insensitive
query.startsWith(Policy#PolicyNumber, "PA-", false)
```

`contains` can be expensive — add indexed predicates first. See antipatterns file.

## Q17: Having clause (aggregate filter)

```gosu
query.having(...)   // applied after GROUP BY, filters aggregate results
```

## Q18: Chained ordering

```gosu
var results = query.select()
  .orderBy(\e -> e.LastName)
  .thenBy(\e -> e.FirstName)
```

`.orderBy()` + `.thenBy()` chains for multi-column sort after retrieval.

## Q19: Paging large result sets

```gosu
var results = query.select()
results.setPageSize(100)   // process 100 at a time
for (entity in results) {
  // processed in pages from DB
}
```

## Q20: INTERSECT is an antipattern

Do NOT use INTERSECT. Combine predicates on a single query instead:

```gosu
// WRONG — two queries intersected
var q1 = Query.make(Claim)
q1.compare(Claim#LossCause, Equals, LossCause.TC_VEHCOLLISION)
var q2 = Query.make(Claim)
q2.compare(Claim#State, Equals, ClaimState.TC_OPEN)
// intersect(q1, q2) — DO NOT USE

// CORRECT — single query with combined predicates
var q = Query.make(Claim)
q.compare(Claim#LossCause, Equals, LossCause.TC_VEHCOLLISION)
q.compare(Claim#State, Equals, ClaimState.TC_OPEN)
```
