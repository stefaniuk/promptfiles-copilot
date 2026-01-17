---
agent: agent
description: Produce C4 model diagrams (Context, Container, Component) in Structurizr DSL (evidence-first, consistent naming)
---

**Mandatory preparation:** read [codebase overview](../instructions/includes/codebase-overview-baseline.include.md) instructions in full and follow strictly its rules before executing any step below.

## Goal

Create (or update) Structurizr DSL files under `docs/codebase-overview/c4/`:

- `docs/codebase-overview/c4/01-context.dsl`
- `docs/codebase-overview/c4/02-container.dsl`
- `docs/codebase-overview/c4/03-component-*.dsl` (one per container/context as needed)

Also ensure they are linked from: [codebase overview](../../docs/codebase-overview/README.md) output

---

## Discovery (run before writing)

### A. Refresh what is already known (use existing docs as inputs)

1. Review:
   - [repository map](../../docs/codebase-overview/repository-map.md)
   - Component catalogue: `docs/codebase-overview/component-*.md`
   - Runtime flows: `docs/codebase-overview/runtime-flow-*.md`
   - Domain analysis (DDD): `docs/codebase-overview/domain-*.md`
2. Extract into working notes:
   - System name(s) and purpose
   - Deployable units (services/apps/workers/CLIs) and their entry points
   - External systems (identity, messaging, email, payments, third-party APIs)
   - Datastores (DBs, caches, object stores) and which parts use them
   - Bounded contexts / major domain areas (if documented)
   - Primary protocols and interaction styles (HTTP, events, schedules) if evidenced

### B. Confirm diagram candidates in code/config (evidence-first)

Use workspace search and open relevant files to confirm:

1. Container boundaries:
   - Dockerfiles, Helm/K8s manifests, Terraform resources, compose files
   - Service start-up and deployment workflows
2. External systems and dependencies:
   - Client initialisation, env vars, config structs, IaC resources
3. Component boundaries (for at least one container, ideally more):
   - Router registrations / controllers
   - Consumer registrations
   - DI wiring / registries / module composition roots

Record any gaps as **Unknown from code – {suggested action}** and avoid guessing.

---

## Steps

### 1) Establish naming and scope (consistency rules)

1. Use the same component/container names as in:
   - `component-*.md`
   - `runtime-flow-*.md`
2. Prefer stable identifiers:
   - Containers: `{system}-{service}` style or existing service names
   - Components: short names that match code modules where possible
3. Keep the model small and readable:
   - Context: 1 system + people + external systems
   - Container: 5–20 containers (group similar ones if needed)
   - Component: per-container, focus on 10–30 key components (not every class)

---

### 2) Create Context diagram (Structurizr DSL)

Create/update: `docs/codebase-overview/c4/01-context.dsl`

Include:

- One **softwareSystem** representing the codebase/system
- Key **people** (user types) if evidenced by API/UI usage
- Key **external software systems** the system integrates with
- High-level relationships (who uses what)

Rules:

- Only include externals that have evidence in code/config/IaC.
- Use tags for: `Person`, `ExternalSystem`, `Database`, `Queue`, `Cache`, `Storage` as applicable.
- Add brief descriptions (one sentence max).
- Where meaningful and evidenced, annotate relationships with the interaction style (e.g. `HTTPS/443`, `Publishes events`, `Reads/writes`).

---

### 3) Create Container diagram (Structurizr DSL)

Create/update: `docs/codebase-overview/c4/02-container.dsl`

Include containers for each deployable unit:

- Web/API services
- Background workers/consumers
- Scheduled jobs (if separate deployables)
- CLI tools (only if operationally significant)

Also include key datastores and infrastructure dependencies as containers where helpful:

- Databases
- Message brokers / queues
- Caches
- Object storage

Rules:

- Each container must have evidence (Docker/K8s/IaC, entry point, or build pipeline).
- Capture main technology where evidenced (runtime/framework).
- Relationships must be meaningful (API calls, publishes/consumes, reads/writes).
- Prefer a small number of relationships; do not include every internal call.

---

### 4) Create Component diagrams (Structurizr DSL)

Create component diagrams for containers where it adds value:

- Prioritise the most business-critical containers and/or those appearing in many runtime flows.

For each chosen container, create/update:

- `docs/codebase-overview/c4/03-component-{container-name}.dsl`

Include:

- Key components (controllers/handlers, application services, domain services, repositories, message handlers)
- Key relationships between components
- Relationships from components to external dependencies (DB, broker, external API) where meaningful

Rules:

- Components must be grounded in code:
  - router/controller registrations
  - handler registries
  - DI wiring / module composition
  - repository implementations
- Avoid mapping every class; aim for the main collaborating parts.
- If you cannot identify components reliably, record **Unknown from code – {suggested action}** and skip the component diagram for that container.

---

### 5) Add evidence references and unknowns

Structurizr DSL is not ideal for line-level evidence. Do this instead:

1. At the top of each `.dsl` file, include a short comment block:
   - What inputs were used (links to repo map/components/flows)
   - A short "Evidence pointers" list (file paths only)
   - "Unknown from code" items, if any

Example comment:

```text
// Inputs:
// - /docs/codebase-overview/repository-map.md
// - /docs/codebase-overview/component-001-*.md
// Evidence pointers:
// - /path/to/router.ts
// - /infra/k8s/service.yaml
// Unknown from code – confirm whether {X} is a separate deployable
```

---

### 6) Update the index (README)

Update: [codebase overview](../../docs/codebase-overview/README.md) with a **C4 Diagrams (Structurizr DSL)** section linking to:

- `c4/01-context.dsl`
- `c4/02-container.dsl`
- `c4/03-component-*.dsl`

Also include brief "How to view" notes (repo-local, no external claims), for example:

- "Open the DSL in your Structurizr tooling / exporter used by this repo (if present)."
- If no tooling is found, record **Unknown from code – identify how diagrams are rendered in this repo**.

---

## Output requirements

- Keep diagrams readable and consistent.
- Use the evidence-first approach; do not invent externals, containers, or components.
- When unsure, record **Unknown from code – {suggested action}** rather than guessing.

---

## Structurizr DSL skeletons (use as starting points)

### Context skeleton

```dsl
workspace "System - C4" "C4 diagrams for the system." {
  model {
    user = person "User" "Primary user type." {
      tags "Person"
    }

    system = softwareSystem "System" "Short description." {
      tags "SoftwareSystem"
    }

    external = softwareSystem "External System" "Short description." {
      tags "ExternalSystem"
    }

    user -> system "Uses"
    system -> external "Integrates with"
  }

  views {
    systemContext system "01-SystemContext" "System Context" {
      include *
      autolayout lr
    }

    styles {
      element "Person" { shape person }
      element "ExternalSystem" { background #999999; color #ffffff }
    }
  }
}
```

### Container skeleton

```dsl
workspace "System - Containers" "Container diagram." {
  model {
    user = person "User" "Primary user type." { tags "Person" }

    system = softwareSystem "System" "Short description." {
      tags "SoftwareSystem"

      api = container "API Service" "Serves HTTP API." "Tech (if known)"
      worker = container "Worker" "Processes background work." "Tech (if known)"
      db = container "Database" "Stores data." "DB tech (if known)" { tags "Database" }
    }

    user -> api "Uses"
    api -> db "Reads/writes"
    api -> worker "Publishes jobs/events"
  }

  views {
    container system "02-Container" "Containers" {
      include *
      autolayout lr
    }
  }
}
```

### Component skeleton

```dsl
workspace "System - Components" "Component diagram for one container." {
  model {
    system = softwareSystem "System" "Short description." {
      api = container "API Service" "Serves HTTP API." "Tech (if known)" {
        controller = component "Controller" "Handles HTTP requests." "Tech (if known)"
        service = component "Application Service" "Orchestrates use-cases." "Tech (if known)"
        repo = component "Repository" "Persists data." "Tech (if known)"
      }
      db = container "Database" "Stores data." "DB tech (if known)" { tags "Database" }
    }

    controller -> service "Calls"
    service -> repo "Uses"
    repo -> db "Reads/writes"
  }

  views {
    component api "03-Component-API" "Components - API Service" {
      include *
      autolayout lr
    }
  }
}
```

---

> **Version**: 1.1.2
> **Last Amended**: 2026-01-17
