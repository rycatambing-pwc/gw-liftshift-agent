---
document: archiving-and-domain-graph
purpose: Optional module for archive/domain graph scans
scope: Extractable, archivingOwner, overlap entities, domain graph
---

# Archiving and Domain Graph

## Mental model

Archiving manages database size and performance while preserving required data. It serializes, persists to archive storage, and removes archivable data from the main database.

## Key concepts

- Archive graph/domain graph — set of related entities included in archiving.
- `Extractable` delegate — marks entities participating in the domain graph.
- `archivingOwner` on FK — identifies the owning entity for archive inclusion.
- Non-graph/reference entities — admin/system/cross-parent data.
- Overlap entity/table — rows may be inside and outside the archive graph.
- Reference entities should often be retireable rather than deleted.

## Agent triggers

Load this module when scanning:

- `Extractable`
- `archivingOwner`
- overlap table/delegate
- archive graph/domain graph code
- archive batch process logic

## Warning

Archiving is complex and version/project-specific. Treat this module as orientation only and verify with project data model and Guidewire docs.
