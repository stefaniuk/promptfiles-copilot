---
agent: agent
description: Enforce repository-wide compliance with reactjs.instructions.md
---

**Mandatory preparation:**

- Read the [constitution](../../.specify/memory/constitution.md) for non-negotiable rules, if you have not done already.
- Read the [ReactJS instructions](../instructions/reactjs.instructions.md).
- Reference identifiers (for example `[RJS-QR-001]`) as you must assess compliance against each of them across the codebase and remediate any deviations.
- Read the [codebase overview instructions](../instructions/include/codebase-overview.include.md) and adopt the approach for gathering supporting evidence.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Enumerate every React artefact in the repository, detect any discrepancies against `reactjs.instructions.md`, plan the refactor/rework workstream, implement the required changes, and confirm compliance.

---

## Discovery (run before writing)

### A. Enumerate React scope

1. Run `git ls-files '*.tsx' '*.jsx'` (include glue files such as `package.json`, `pnpm-lock.yaml`, `tsconfig*.json`, `vite.config.ts`, `next.config.js`, `Makefile`, CI configs) to capture the full React footprint.
2. Categorise each file into **pages/routes**, **components**, **hooks**, **contexts/providers**, **utilities**, **tests**, or **configuration**.
3. Record locations that declare tooling (ESLint, Prettier/Biome, TypeScript config, Vitest/Jest, Storybook) to ensure the instructions apply consistently.

### B. Load enforcement context

1. Re-read the relevant sections of `reactjs.instructions.md` for the patterns present (component design, hooks, state management, forms, accessibility, performance, etc.).
2. Note any repository ADRs or docs that explicitly override defaults; if none exist, assume the instructions are fully binding.
3. Summarise uncertainties as **Unknown from code – verify {topic} with maintainers** before proceeding.

---

## Steps

> **Note:** On subsequent runs, check whether artefacts from earlier executions (for example `docs/prompt-reports/reactjs-inventory.md`, `docs/prompt-reports/reactjs-instructions-alignment-plan.md`) already exist and parse them so progress is cumulative rather than duplicated.

### 1) Build the React artefact matrix

1. Produce a table (for example in `docs/prompt-reports/reactjs-inventory.md`) listing each React file or folder, its role, and the key instruction tags that apply.
2. Highlight high-risk areas (large components, custom hooks, context providers, form handling, accessibility) where divergence is most likely.

### 2) Detect discrepancies against instructions

1. For each artefact, scan for violations of instruction tags (functional components, hooks rules, accessibility, performance patterns, error boundaries, etc.).
2. Assess each artefact and file against compliance of each reference identifier (for example `[RJS-QR-001]`) from the `reactjs.instructions.md` file.
3. Capture findings with precise evidence links, formatted as `- Evidence: [path/to/file](path/to/file#L10-L40) — violates [RJS-CMP-003] because ...`.
4. Record unknowns explicitly using **Unknown from code – {action}** (for example missing Error Boundary or undocumented state management approach).

### 3) Plan refactoring and rework

1. Group findings into actionable workstreams (for example "Component splitting", "Hooks extraction", "Accessibility remediation", "Performance optimisation", "Form standardisation").
2. For each workstream, provide:
   - Objective
   - Files to touch (with justification)
   - Specific instruction tags they satisfy
   - Order of execution (prioritise accessibility and correctness fixes first)
3. Store the plan in `docs/prompt-reports/reactjs-instructions-alignment-plan.md` for traceability.

### 4) Implement the changes (iterative, safe batches)

1. Execute the plan in small batches, keeping commits narrowly scoped and referencing instruction tags.
2. Prefer refactors that split large components, extract custom hooks, add Error Boundaries, improve accessibility, or remove anti-patterns (inline objects, missing deps).
3. Update docs, Makefiles, CI, and configuration to keep guidance, automation, and behaviour in sync.

### 5) Validate quality gates and behavioural parity

1. After each batch, run the canonical quality gates (for example `make fmt`, `make lint`, `make typecheck`, `make test`) and iterate until all pass with zero warnings (per `[RJS-QG-001]`–`[RJS-QG-003]`).
2. If additional checks exist (for example Storybook build, accessibility audits, visual regression tests), run them when the touched areas require it.
3. Document failures and fixes in the plan file; unresolved issues must be tracked as blockers.

### 6) Summarise outcomes and next steps

1. Produce a final enforcement report (append to `docs/prompt-reports/reactjs-instructions-alignment-plan.md`) covering:
   - Resolved discrepancies (with references)
   - Remaining gaps / technical debt
   - Follow-up actions with owners and due dates
2. Confirm there are no lingering **Unknown from code** items; if any remain, convert them into explicit follow-ups.
3. Share the plan/report with maintainers (for example via PR description) to keep the team aligned.

---

## Output requirements

- Use concrete evidence links for every finding or change request.
- Reference instruction identifiers (for example `[RJS-HK-002]`) when explaining discrepancies or fixes.
- Keep activities broken into the steps above; do not skip steps even if the code appears compliant.
- Prefer automation (ESLint react-hooks, jsx-a11y, TypeScript) over manual spot checks where feasible.
- Maintain ASCII-only text unless the repository already contains Unicode in the touched files.
- When information is missing, record **Unknown from code – {suggested action}** instead of guessing.

Context for prioritization: $ARGUMENTS

---

> **Version**: 1.0.0
> **Last Amended**: 2026-01-11
