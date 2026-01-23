---
agent: agent
description: Enforce repository-wide compliance with makefile.instructions.md
---

**Mandatory preparation:**

- Read the [constitution](../../.specify/memory/constitution.md) for non-negotiable rules, if you have not done already.
- Read the [Makefile instructions](../instructions/makefile.instructions.md).
- Reference identifiers (for example `[MK-QR-001]`) as you must assess compliance against each of them across the codebase and remediate any deviations.
- Read the [codebase overview instructions](../instructions/includes/codebase-overview-baseline.include.md) and adopt the approach for gathering supporting evidence.

## User Input ⌨️

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal 🎯

Enumerate every Makefile (including included `*.mk` modules), detect discrepancies against `makefile.instructions.md`, plan the refactor/rework workstream, implement the required changes, and confirm compliance.

---

## Discovery (run before writing) 🔍

### A. Enumerate Makefile scope

1. Run `git ls-files 'Makefile' '**/*.mk'` (include bootstrap scripts under `scripts/`, CI configs, and helper shell scripts) to capture the full orchestration footprint.
2. Categorise each file into **root Makefiles**, **shared modules**, **task-specific includes**, **helper scripts**, or **CI integrations**.
3. Record locations that declare canonical targets (for example `make deps`, `make format`, `make lint`, `make typecheck`, `make test`, `make test-all`, `make build`, `make run`/`make up`/`make down`, `make doctor`) and any scripts they delegate to, so quality gates can be enforced consistently.

### B. Load enforcement context

1. Re-read the relevant sections of `makefile.instructions.md` for the repository patterns in play (bootstrap modules, target UX, CI alignment, shell safety, etc.).
2. Note any ADRs or docs that explicitly override defaults; if none exist, assume the instructions are fully binding.
3. Summarise uncertainties as **Unknown from code – verify {topic} with maintainers** before proceeding.

---

## Steps 👣

> **Note:** On subsequent runs, detect whether artefacts from earlier executions (for example `docs/prompts/makefile-inventory.md`, `docs/prompts/makefile-instructions-alignment-plan.md`) already exist and parse them so progress is cumulative rather than duplicated.

### 1) Build the Makefile artefact matrix

1. Produce a table (for example in `docs/prompts/makefile-inventory.md`) listing each Makefile/module, its scope (root, shared, CI-only), key public targets, and instruction tags that apply.
2. Highlight high-risk areas (help/UX coverage, shell safety, destructive targets, CI-only scripts) where divergence is most likely.

### 2) Detect discrepancies against instructions

1. For each artefact, scan for violations of the Makefile instruction tags (thin root requirement, help/UX coverage, local-first targets, `.ONESHELL`, fail-fast shell flags, safe clean targets, CLI contract alignment, CI reuse, etc.).
2. Assess each artefact and file against compliance of each reference identifier (for example `[MK-QR-001]`) from the `makefile.instructions.md` file.
3. Confirm local-first targets and help metadata align with [MK-LCL-001]–[MK-LCL-007] and [MK-UX-001]–[MK-UX-009], including CLI contract compliance per [MK-UX-009].
4. Capture findings with precise evidence links, for example `- Evidence: [Makefile](Makefile#L5-L30) — violates [MK-UX-003] because public targets lack descriptions.`
5. Record unknowns explicitly using **Unknown from code – {action}** (for example unclear bootstrap tooling or missing confirmation flags for destructive targets).

### 3) Plan refactoring and rework

1. Group findings into actionable workstreams (for example "Help/UX standardisation", "Shell safety hardening", "CI + local target parity").
2. For each workstream, provide:
   - Objective
   - Files/modules/scripts to touch (with justification)
   - Specific instruction tags they satisfy
   - Order of execution (prioritise safety-critical fixes first)
3. Store the plan in `docs/prompts/makefile-instructions-alignment-plan.md` for traceability.

### 4) Implement the changes (iterative, safe batches)

1. Execute the plan in small batches, keeping commits narrowly scoped and referencing instruction tags.
2. Prefer refactors that move complex logic into scripts, add missing help descriptions, enforce fail-fast shell settings, and align CI pipelines with make targets.
3. Update docs, scripts, and CI workflows to keep guidance, automation, and behaviour in sync with the Makefile instructions.

### 5) Validate quality gates and behavioural parity

1. After each batch, run `make lint` and `make test`; if the targets do not exist, run the repository's equivalent canonical commands and follow the quality gates baseline for command selection and warning handling per `[MK-QG-001]`–`[MK-QG-004]`.
2. If additional targets exist (for example `make deps`, `make format`, `make typecheck`, `make test-all`, `make build`, `make run`, `make doctor`), run the ones affected by the changes.
3. Document failures and fixes in the plan file; unresolved issues must be tracked as blockers.

### 6) Summarise outcomes and next steps

1. Append a final enforcement report to `docs/prompts/makefile-instructions-alignment-plan.md` covering:
   - Resolved discrepancies (with references)
   - Remaining gaps / technical debt
   - Follow-up actions with owners and due dates
2. Confirm there are no lingering **Unknown from code** items; convert any remaining ones into explicit follow-ups.
3. Share the plan/report with maintainers (for example via PR description) to keep the team aligned.

---

## Output requirements 📋

- Use concrete evidence links for every finding or change request.
- Reference instruction identifiers (for example `[MK-UX-001]`) when explaining discrepancies or fixes.
- Keep activities broken into the steps above; do not skip steps even if the Makefile surface looks compliant.
- Prefer automation (scripted linting, automated help checks) over manual spot audits where feasible.
- Maintain ASCII-only text unless the repository already contains Unicode in the touched files.
- When information is missing, record **Unknown from code – {suggested action}** instead of guessing.

Context for prioritization: $ARGUMENTS

---

> **Version**: 1.1.5
> **Last Amended**: 2026-01-17
