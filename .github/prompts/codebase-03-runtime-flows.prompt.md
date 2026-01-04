---
agent: agent
description: Document key runtime flows with diagrams
---

**Mandatory preparation:** read [codebase overview](../instructions/include/codebase-overview.md) in full and follow strictly its rules before executing any step below.

Goal: create [runtime flows](../../../docs/codebase-overview/runtime-flow-*.md)

Discovery (run before writing):

1. Review repository map and component documents to see existing entry points, APIs, jobs, and background workers.
2. Search for orchestrators: HTTP routers, message consumers, schedulers, or pipeline definitions.
3. Note any domain events or workflow engines and include them as candidate flows.

Steps:

1. Identify 5-8 critical user/system flows (for example login, create/update entity, scheduled/background job, ingestion pipeline). Each flow must map to real code or be marked **Unknown from code** with a follow-up note.
2. For each flow, create `docs/codebase-overview/runtime-flow-[XXX]-[name].md` covering:
   - A short narrative covering the trigger, main steps, and outcome.
   - A Mermaid sequence diagram of the collaborating components.
   - Error handling, retries, and idempotency notes where the code documents them.
   - Evidence section, file paths (only URL must be prefixed with `/` for the link to resolve correctly) + symbols/config keys.
3. Mark anything unclear as **Unknown from code - {action}** so it can be verified later.
4. Write the file and keep it concise while preserving the evidence-first rule.
5. Iterate, create a first draft, search for more evidence, then refine links and unknowns while keeping the document readable and practical.
6. Update [codebase overview](../../../docs/codebase-overview/README.md) with a **Runtime Flows** section linking to every flow document.

Template snippet per flow:

```md
# Runtime Flow {name}

## Narrative

...

## Sequence

{mermaid sequence diagram}

...

## Error Handling

...

## Evidence

- Evidence: [path/to/file](path/to/file#L75-L140) - {handler/function}
- Evidence: Unknown from code - {action}
```

---

> **Version**: 1.1.0
> **Last Amended**: 2026-01-04
