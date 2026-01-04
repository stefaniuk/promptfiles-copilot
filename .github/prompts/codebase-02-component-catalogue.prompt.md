---
agent: agent
description: Create component-level summaries
---

**Mandatory preparation:** read [codebase overview](../instructions/include/codebase-overview.md) in full and follow strictly its rules before executing any step below.

Goal: create [component catalogue](../../../docs/codebase-overview/component-*.md)

Discovery (run before writing):

1. Re-read [repository map](../../../docs/codebase-overview/repository-map.md) and note domains, entry points, and data stores already identified.
2. Search for module boundaries via package manifests, workspace references (`apps/`, `services/`, `api/`, `packages/`, `cmd/`, `cli/`, `src/` subfolders).
3. Read code for registries (router files, DI containers, plugin loaders) to uncover implicit components.

Steps:

1. From the refreshed repository knowledge, pick the 7-12 most important components or modules (services, bounded areas, packages). Document selection criteria if ambiguous.
2. For each component, create `docs/codebase-overview/component-[XXX]-[name].md` covering:
   - Purpose
   - Responsibilities
   - Key modules/symbols
   - Key inbound/outbound interfaces (HTTP routes, messaging topics, queues, events)
   - Data structures
   - Config and feature flags (if any)
   - Observability (logging/metrics/tracing)
   - Evidence section (file paths + symbols/config keys)
3. For any field without supporting code, add **Unknown from code — {action}** so gaps remain visible.
4. Write the file and keep it concise while preserving the evidence-first rule.
5. Iterate, create a first draft, search for more evidence, then refine links and unknowns while keeping the document readable and practical.
6. Update [codebase overview](../../../docs/codebase-overview/README.md) with a **Component Catalogue** section linking to every component document.

Template snippet per component:

```md
# Component {name}

{summary}

## Purpose

...

## Responsibilities

...

## Symbols

...

## Interfaces

- Inbound: ...
- Outbound: ...

## Data Structures

...

## Configuration

...

## Observability

...

## Evidence

- Evidence: [path/to/file](path/to/file#L20-L58) - {symbol}
- Evidence: Unknown from code - {action}
```

---

> **Version**: 1.1.0
> **Last Amended**: 2026-01-04
