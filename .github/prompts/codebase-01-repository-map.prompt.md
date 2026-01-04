---
agent: agent
description: Build a repository map to document the architecture
---

**Mandatory preparation:** read [codebase overview](../instructions/include/codebase-overview.md) in full and follow strictly its rules before executing any step below.

## Goal

Create (or update): [repository map](../../docs/codebase-overview/repository-map.md)

Also ensure it is linked from: [codebase overview](../../docs/codebase-overview/README.md)

---

## Discovery (run before writing)

### A. Identify "non-source" directories and their purpose

1. List top-level directories and classify them into:
   - **Source code** (application/service/library code)
   - **Infrastructure** (IaC, Kubernetes manifests, Helm, Terraform, etc.)
   - **Build/CI** (pipelines, scripts, tooling)
   - **Documentation/process** (docs, ADRs, runbooks, decision logs)
   - **Tests** (unit/integration/e2e/performance)
   - **Generated/vendor** (ignore for mapping unless referenced by build)
2. Record which directories appear to be **generated/vendor** and should be treated as _non-authoritative_.

### B. Read context documents (non-authoritative)

1. Identify key context files such as:
   - `README*`, `doc*/**`, `adr/**`, `spec*/**`, `*.md`
2. Read them for hints and vocabulary only.
3. Do **not** treat them as authoritative unless confirmed by code/config. If an item is only present in docs, record it as **Unknown from code – verify**.

---

## Steps

### 1) Map the repository structure (focused and bounded)

1. Enumerate folders **up to five levels deep**, excluding generated/vendor directories.
2. For each top-level folder (and any folder that looks like a "root" for a product/service), summarise:
   - What it contains (one sentence)
   - Whether it looks like **app/service**, **library**, **shared package**, **infra**, **docs**, **tooling**, **tests**
3. Identify whether the repository is:
   - **Single application**, or
   - **Monorepo** (multiple deployable apps/services), or
   - **Multi-package repo** (shared libs + one deployable), and state which, with evidence.

### 2) Identify deployable units and entry points (per unit)

1. Identify each **deployable unit** (service/app/UI/API/job/CLI) and name it consistently.
2. For each deployable unit, capture:
   - **Entry point type**: HTTP server / worker / scheduled job / CLI / library-only
   - **Primary entry file(s)** (e.g. `main`, `app`, `server`, `cmd/*`, `bin/*`)
   - **How it is started** (command, script, container CMD/ENTRYPOINT, Procfile, systemd, etc.)
3. Identify how routing/command dispatch happens (where applicable):
   - HTTP route registration location(s)
   - CLI command registration location(s)
4. If monorepo, group results by service/app with clear headings.

### 3) Map build, test, and CI/CD (separate concerns)

#### 3A. Local build and run workflows

1. Identify canonical local commands:
   - Build
   - Run
   - Test (unit/integration/e2e)
   - Lint/format
2. Prefer `Makefile`, task runners, or scripts as the source of truth.

#### 3B. CI pipelines and quality gates

1. Identify CI systems in use (e.g. GitHub Actions) and list workflow files.
2. For each workflow, capture:
   - Triggers (push, PR, schedule, manual)
   - Main jobs (build/test/lint/security/deploy)
   - Artefacts produced (images, packages, reports)
3. Record security/scanning steps (SAST, dependency scanning, container scanning, SBOM), if present.

#### 3C. Deployment artefacts and infrastructure

1. Identify deployment mechanisms:
   - Dockerfiles / container build
   - Helm charts / Kubernetes manifests
   - Terraform / other IaC
2. For each deployable unit, link to the deployment artefacts that apply to it.
3. Note environments if represented (dev/test/prod), and where configuration differs.

### 4) Identify dependencies and platform usage (split and explicit)

#### 4A. Languages, frameworks, and runtime

1. Identify languages used and versions, if declared.
2. Identify main frameworks/libraries per deployable unit and versions.

#### 4B. Package managers and manifests

1. Identify manifests and lock files (per ecosystem) and where they live.
2. Note whether the repo uses workspaces (monorepo tooling) where applicable.

#### 4C. External services (inferred from code/config)

1. Identify external dependencies the system relies on, such as:
   - Datastores (SQL/NoSQL)
   - Messaging/queues
   - Caches
   - Object storage
   - Identity/auth providers
   - Third-party APIs
2. Only include a service if you can point to evidence in code/config (imports, clients, env vars, helm values, terraform resources, etc.).
3. Capture cloud managed services where evidenced (AWS/Azure/GCP resources, platform operators, etc.).

---

## Evidence and unknowns (mandatory)

5. For each major statement, add an **Evidence** section with:
   - File path links (URLs must be prefixed with `/` so links resolve correctly)
   - Symbols (function/class names) and/or config keys (env vars, YAML keys)
6. When a required artefact cannot be found, record:
   - **Unknown from code – {action to confirm}**

---

## Output format

Use the following snippet inside `repository-map.md`:

```markdown
## {area}

{summary}

### Evidence

- Evidence: [/path/to/file](/path/to/file#L10-L32) - {symbol or config key}
- Evidence: Unknown from code – {action}
```

---

> **Version**: 1.2.4
> **Last Amended**: 2026-01-04
