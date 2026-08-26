# View Entities and List View Performance

Source: Guidewire Education module (highest confidence). Extends `/context/08-list-view-architecture.md` and `/context/09-list-view-editability.md` — specifically the "root object is a query result set, not a parent entity" case.

## What a View Entity Is

A **View Entity** is a logical, **virtual** (not persisted in the database) view of entity data, used to improve performance when rendering tabular data in a List View — conceptually like a SQL view, treated as a virtual table.

- Can include **paths** from the primary entity to related entities. Queries against a View Entity automatically add the joins needed to retrieve columns defined via a bean path.
- Can be **subtyped** — e.g. a base `ActivityView` might have subtypes like `ActivityDesktopView`, `ActivitySearchView`, etc. (visible in the Data Dictionary).
- View Entities are **first-class types** — they can have extensions, interface definitions, delegates, and other configuration just like a normal entity.
- Custom View Entities are queried using the **Gosu Query API**, same as a normal entity, and can include **WHERE-clause conditions** (bean query filters).

## How a Query-Backed List View Is Wired

For a List View backed by a View Entity, the **RowIterator** is defined using the View Entity (or its subtype) as its type. The underlying type signature looks like:

```
gw.api.database.IQueryBeanResult<gw.pl.persistence.core.Bean>
```

This is the concrete mechanism behind the "root object is the set of elements itself, not a parent entity" case noted in `/context/08-list-view-architecture.md` — a query-backed List View has no natural parent object, so it's backed by a queried View Entity instead, and (per that earlier note) doesn't get `addTo`/`removeFrom` editability for free.

## The Performance Problem and Its Fix

**Problem:** a common performance issue in View-Entity-backed List Views comes from retrieving data **outside** the View Entity — i.e., a cell needs a value that requires fetching an entire related entity just to read one field off it.

**Fix:** extend the View Entity with a new `viewEntityColumn` that provides a **path** to the needed value through the related entity (e.g., adding a Check Number column with a path through the `Check` entity). The cell can then reference that value directly on the View Entity itself, without retrieving the whole related `Check` entity.

**Related optimization:** for a field that is **not editable**, use `DisplayName` rather than retrieving the entire record — if all you need is a name string, pulling the full record to get it is wasteful.

## Where to Look for More Detail

The source explicitly points to the **Guidewire Configuration Guide**, under **Data Model Configuration → Extending the Base Data Model**, sections:
- "View Entity Data Objects"
- "Extending an Existing View Entity"

These weren't retrieved directly — flagged as a good target if we get another documentation pass.
