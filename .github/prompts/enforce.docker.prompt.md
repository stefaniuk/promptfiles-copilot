---
agent: agent
description: Enforce repository-wide compliance with docker.instructions.md
---

**Mandatory preparation:**

- Read the [constitution](../../.specify/memory/constitution.md) for non-negotiable rules, if you have not done already.
- Read the [Dockerfile instructions](../instructions/docker.instructions.md).
- Reference identifiers (for example `[DF-QR-001]`) as you must assess compliance against each of them across the codebase and remediate any deviations.
- Read the [codebase overview instructions](../instructions/includes/codebase-overview-baseline.include.md) and adopt the approach for gathering supporting evidence.

## User Input ⌨️

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal 🎯

Enumerate every Dockerfile artefact in the repository, detect any discrepancies against `docker.instructions.md`, plan the refactor/rework workstream, implement the required changes, and confirm compliance.

---

## Discovery (run before writing) 🔍

### A. Enumerate Dockerfile scope

1. Run `git ls-files 'Dockerfile' 'Dockerfile.*'` (include glue files such as `.tool-versions`, `Dockerfile.dockerignore`, `.dockerignore`, `VERSION`, Makefile targets, CI configs, and build scripts) to capture the full container footprint.
2. Categorise each file into **base/foundation images**, **application runtime images**, **dev/test/CI images**, or **generated artefacts** (for example `Dockerfile.effective`) and flag any files that should not be edited.
3. Record locations that define base image pinning, build args/env, stage naming, metadata labels, non-root users, and the Docker lifecycle targets (`docker-bake-dockerfile`, `docker-lint`, `docker-build`, `docker-run`, `docker-push`).

### B. Load enforcement context

1. Re-read the relevant sections of `docker.instructions.md` for the patterns present (multi-stage builds, metadata blocks, cleanup strategy, etc.).
2. Note any repository ADRs or docs that explicitly override defaults; if none exist, assume the instructions are fully binding.
3. Summarise uncertainties as **Unknown from code – verify {topic} with maintainers** before proceeding.

---

## Steps 👣

> **Note:** On subsequent runs, check whether artefacts from earlier executions (for example `docs/prompts/docker-inventory.md`, `docs/prompts/docker-instructions-alignment-plan.md`) already exist and parse them so progress is cumulative rather than duplicated.

### 1) Build the Dockerfile artefact matrix

1. Produce a table (for example in `docs/prompts/docker-inventory.md`) listing each Dockerfile/variant, its purpose, stage names, base image pinning, metadata label location, and key instruction tags that apply.
2. Highlight high-risk areas (unpinned `FROM`, missing cleanup, root user, missing `.dockerignore`, metadata not at end) where divergence is most likely.

### 2) Detect discrepancies against instructions

1. For each artefact, scan for violations of Dockerfile instruction tags (canonical instruction order, pinned base images, `set -ex` in RUN, build dependency cleanup, non-root user, metadata block placement, anti-patterns).
2. Assess each artefact and file against compliance of each reference identifier (for example `[DF-QR-001]`) from the `docker.instructions.md` file.
3. Verify build lifecycle integration per [DF-LC-001]–[DF-LC-008] (effective Dockerfile generation, `VERSION`, `.tool-versions`, lint/build targets).
4. Validate quality gate expectations per [DF-QG-001]–[DF-QG-005] and note any `hadolint` ignores that are unjustified.
5. Capture findings with precise evidence links, formatted as `- Evidence: [path/to/Dockerfile](path/to/Dockerfile#L10-L40) — violates [DF-FROM-001] because ...`.
6. Record unknowns explicitly using **Unknown from code – {action}** (for example missing base image pinning or unclear image purpose).

### 3) Plan refactoring and rework

1. Group findings into actionable workstreams (for example "Base image pinning", "RUN cleanup and layering", "Metadata alignment", "Lifecycle target parity").
2. For each workstream, provide:
   - Objective
   - Files to touch (with justification)
   - Specific instruction tags they satisfy
   - Order of execution (prioritise security and reproducibility fixes first)
3. Store the plan in `docs/prompts/docker-instructions-alignment-plan.md` for traceability.

### 4) Implement the changes (iterative, safe batches)

1. Execute the plan in small batches, keeping commits narrowly scoped and referencing instruction tags.
2. Prefer refactors that pin base images, enforce canonical instruction order, consolidate RUN layers with cleanup, add non-root users, and move metadata to the final block.
3. Update docs, Makefiles, CI, and build scripts to keep guidance, automation, and behaviour in sync (including generated Dockerfile workflows).

### 5) Validate quality gates and behavioural parity

1. After each batch, run `make docker-bake-dockerfile` and `make docker-lint` (or the repository's equivalent hadolint command) and iterate until all pass with zero warnings per [DF-QG-001]–[DF-QG-005].
2. If build/run targets exist (for example `make docker-build`, `make docker-run`), run the ones affected by the changes.
3. Document failures and fixes in the plan file; unresolved issues must be tracked as blockers.

### 6) Summarise outcomes and next steps

1. Append a final enforcement report to `docs/prompts/docker-instructions-alignment-plan.md` covering:
   - Resolved discrepancies (with references)
   - Remaining gaps / technical debt
   - Follow-up actions with owners and due dates
2. Confirm there are no lingering **Unknown from code** items; convert any remaining ones into explicit follow-ups.
3. Share the plan/report with maintainers (for example via PR description) to keep the team aligned.

---

## Output requirements 📋

- Use concrete evidence links for every finding or change request.
- Reference instruction identifiers (for example `[DF-STR-001]`) when explaining discrepancies or fixes.
- Keep activities broken into the steps above; do not skip steps even if the Dockerfiles appear compliant.
- Prefer automation (hadolint, build tooling) over manual spot checks where feasible.
- Maintain ASCII-only text unless the repository already contains Unicode in the touched files.
- When information is missing, record **Unknown from code – {suggested action}** instead of guessing.

Context for prioritization: $ARGUMENTS

---

> **Version**: 1.0.1
> **Last Amended**: 2026-01-17
