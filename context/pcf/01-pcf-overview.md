# PCF Overview

## What is a PCF File?

A **PCF (Page Configuration Format/File)** is an **XSD-validated XML document** that defines the pages of the application user interface in Guidewire InsuranceSuite products (PolicyCenter, ClaimCenter, BillingCenter, and ContactManager). PCF elements are defined within a root `<PCF>` tag, and together define the structure, layout, and behavior of the web UI.

- File extension: `.pcf`
- Location: `modules/configuration/config/web/pcf`
- Must be edited exclusively in **Guidewire Studio** — editing outside Studio is not supported.

## Key Design Principles

- **PCFs are unmanaged configuration** — fully available for client/partner modification, unlike some other Guidewire extension point types.
- **Avoid Mutually Mutable Configuration (MMC)** — elements that both you and Guidewire can modify create merge complexity across upgrades. Prefer extracting customizations away from core configuration where possible.
- **Custom PCF files are preserved on regeneration** — new PCFs you add survive product regeneration (e.g., via Advanced Product Designer); modified base files may not be.

## PCF Elements — General Model

PCF elements follow a **hierarchical, container-based UI model**. At the top level, every PCF element is conceptually one of two things:

- **Widget** — a displayable element rendered into HTML
- **Location** — an element the user can navigate to (see `03-locations-reference.md`)

> Important: `Widget` and `Location` are **conceptual categories, not literal XML tags** — there is no `<Widget>` or `<Location>` element in actual PCF markup.

See `02-element-hierarchy-and-containers.md` for the full Widget breakdown (Atomic vs. Container, and the 4-tier containment hierarchy).

## Source confidence

This file merges Guidewire Education modules 1 (highest confidence — structured course material) with uncontradicted general facts from Guidewire's public documentation. No open conflicts remain in this file.
