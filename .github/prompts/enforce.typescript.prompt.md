---
agent: agent
description: Enforce repository-wide compliance with typescript.instructions.md
---

**Mandatory preparation:**

- Read the [constitution](../../.specify/memory/constitution.md) for non-negotiable rules, if you have not done already.
- Read the [TypeScript instructions](../instructions/typescript.instructions.md).
- Reference identifiers (for example `[TS-QR-001]`) as you must assess compliance against each of them across the codebase and remediate any deviations.
- Read the [codebase overview instructions](../instructions/includes/codebase-overview-baseline.include.md) and adopt the approach for gathering supporting evidence.

## User Input ⌨️

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal 🎯

Enumerate every TypeScript artefact in the repository, detect any discrepancies against `typescript.instructions.md`, plan the refactor/rework workstream, implement the required changes, and confirm compliance.

---

## Discovery (run before writing) 🔍

### A. Enumerate TypeScript scope

1. Run `git ls-files '*.ts' '*.tsx' '*.js'` (include glue files such as `package.json`, `pnpm-lock.yaml`, `tsconfig*.json`, `Makefile`, CI configs) to capture the full TypeScript/JavaScript footprint.
2. Categorise each file into **entrypoints/CLI**, **services/APIs**, **web apps/UI**, **libraries/modules**, **tests**, **tooling/scripts**, or **configuration**.
3. Record locations that declare tooling (ESLint, Prettier/Biome, TypeScript config, Jest/Vitest, pnpm) to ensure the instructions apply consistently.

### B. Load enforcement context

1. Re-read the relevant sections of `typescript.instructions.md` for the surfaces present (CLI, API, UI, workers, etc.).
2. Note any repository ADRs or docs that explicitly override defaults; if none exist, assume the instructions are fully binding.
3. Summarise uncertainties as **Unknown from code – verify {topic} with maintainers** before proceeding.

---

## Steps 👣

> **Note:** On subsequent runs, check whether artefacts from earlier executions (for example `docs/prompts/typescript-inventory.md`, `docs/prompts/typescript-instructions-alignment-plan.md`) already exist and parse them so progress is cumulative rather than duplicated.

### 1) Build the TypeScript artefact matrix

1. Produce a table (for example in `docs/prompts/typescript-inventory.md`) listing each TypeScript/JavaScript file or folder, its role, and the key instruction tags that apply.
2. Highlight high-risk areas (entrypoints, shared utilities, routing layers, data models) where divergence is most likely.

### 2) Detect discrepancies against instructions

1. For each artefact, scan for violations of instruction tags (CLI contract, async correctness, observability, security, accessibility, etc.).
2. Assess each artefact and file against compliance of each reference identifier (for example `[TS-QR-001]`) from the `typescript.instructions.md` file.
3. Verify toolchain and local-first requirements per [TS-LCL-001]–[TS-LCL-012] (make targets, Node version pinning, lockfile, corepack, package manager) and strict compiler defaults per [TS-TSC-001]–[TS-TSC-004].
4. Capture findings with precise evidence links, formatted as `- Evidence: [path/to/file](path/to/file#L10-L40) — violates [TS-CTR-014] because ...`.
5. Record unknowns explicitly using **Unknown from code – {action}** (for example missing strict compiler flags or undocumented integration modes).

### 3) Plan refactoring and rework

1. Group findings into actionable workstreams (for example "CLI stream separation", "Async timeouts", "Structured logging alignment", "UI accessibility").
2. For each workstream, provide:
   - Objective
   - Files to touch (with justification)
   - Specific instruction tags they satisfy
   - Order of execution (prioritise safety-critical fixes first)
3. Store the plan in `docs/prompts/typescript-instructions-alignment-plan.md` for traceability.

### 4) Implement the changes (iterative, safe batches)

1. Execute the plan in small batches, keeping commits narrowly scoped and referencing instruction tags.
2. Prefer refactors that move logic into shared modules, add missing tooling config, or adjust CLIs/APIs/UI to match the contract.
3. Update docs, Makefiles, CI, and configuration to keep guidance, automation, and behaviour in sync.

### 5) Validate quality gates and behavioural parity

1. After each batch, run the canonical quality gates (`make format`, `make lint`, `make typecheck`, `make test`); if make targets do not exist, run the repository equivalents and follow the quality gates baseline per [TS-QG-001]–[TS-QG-007].
2. If additional checks exist (for example `pnpm run test-e2e`, `pnpm run typecheck -- --watch`), run them when the touched areas require it.
3. Document failures and fixes in the plan file; unresolved issues must be tracked as blockers.

### 6) Summarise outcomes and next steps

1. Produce a final enforcement report (append to `docs/prompts/typescript-instructions-alignment-plan.md`) covering:
   - Resolved discrepancies (with references)
   - Remaining gaps / technical debt
   - Follow-up actions with owners and due dates
2. Confirm there are no lingering **Unknown from code** items; if any remain, convert them into explicit follow-ups.
3. Share the plan/report with maintainers (for example via PR description) to keep the team aligned.

---

## Output requirements 📋

- Use concrete evidence links for every finding or change request.
- Reference instruction identifiers (for example `[TS-CTR-016]`) when explaining discrepancies or fixes.
- Keep activities broken into the steps above; do not skip steps even if the code appears compliant.
- Prefer automation (scripts, linters) over manual spot checks where feasible.
- Maintain ASCII-only text unless the repository already contains Unicode in the touched files.
- When information is missing, record **Unknown from code – {suggested action}** instead of guessing.

Context for prioritization: $ARGUMENTS

---

> **Version**: 1.1.5
> **Last Amended**: 2026-01-17
