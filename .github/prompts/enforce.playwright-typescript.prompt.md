---
agent: agent
description: Enforce repository-wide compliance with playwright-typescript.instructions.md
---

**Mandatory preparation:**

- Read the [constitution](../../.specify/memory/constitution.md) for non-negotiable rules, if you have not done already.
- Read the [Playwright TypeScript instructions](../instructions/playwright-typescript.instructions.md).
- Read the [TypeScript instructions](../instructions/typescript.instructions.md) for general TypeScript standards.
- Read the [Playwright baseline](../instructions/includes/playwright-baseline.include.md) for shared Playwright guidance.
- Reference identifiers (for example `[PW-TS-QR-001]`) as you must assess compliance against each of them across the codebase and remediate any deviations.
- Read the [codebase overview instructions](../instructions/includes/codebase-overview-baseline.include.md) and adopt the approach for gathering supporting evidence.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Enumerate every Playwright TypeScript test artefact in the repository, detect any discrepancies against `playwright-typescript.instructions.md`, plan the refactor/rework workstream, implement the required changes, and confirm compliance.

---

## Discovery (run before writing)

### A. Enumerate Playwright TypeScript scope

1. Run `git ls-files '**/*.spec.ts' '**/*.spec.tsx' '**/*.test.ts' '**/*.test.tsx' 'tests/**/*.ts' 'tests/**/*.tsx'` (include glue files such as `playwright.config.ts`, `package.json`, `pnpm-lock.yaml`, `Makefile`, CI configs) to capture the full Playwright TypeScript test footprint.
2. Categorise each file into **test files**, **page objects**, **fixtures**, **helpers/utilities**, **configuration**, or **CI/tooling**.
3. Record locations that declare tooling (Playwright Test, ESLint, TypeScript config, CI workflows) to ensure the instructions apply consistently.

### B. Load enforcement context

1. Re-read the relevant sections of `playwright-typescript.instructions.md` for the test patterns present (locators, assertions, test.step, test.describe, Page Object Model, etc.).
2. Note any repository ADRs or docs that explicitly override defaults; if none exist, assume the instructions are fully binding.
3. Summarise uncertainties as **Unknown from code – verify {topic} with maintainers** before proceeding.

---

## Steps

> **Note:** On subsequent runs, check whether artefacts from earlier executions (for example `docs/prompt-reports/playwright-typescript-inventory.md`, `docs/prompt-reports/playwright-typescript-instructions-alignment-plan.md`) already exist and parse them so progress is cumulative rather than duplicated.

### 1) Build the Playwright TypeScript artefact matrix

1. Produce a table (for example in `docs/prompt-reports/playwright-typescript-inventory.md`) listing each test file or folder, its role, and the key instruction tags that apply.
2. Highlight high-risk areas (locator patterns, assertion usage, missing await, flaky test patterns) where divergence is most likely.

### 2) Detect discrepancies against instructions

1. For each artefact, scan for violations of instruction tags (role-based locators, web-first assertions, test.step usage, anti-patterns, Page Object Model, etc.).
2. Assess each artefact and file against compliance of each reference identifier (for example `[PW-TS-QR-001]`) from the `playwright-typescript.instructions.md` file.
3. Apply the shared Playwright baseline requirements (isolation, retries, timeouts, anti-patterns) per [PW-TS-STB-001] and [PW-TS-ANT-006], and enforce applicable TypeScript instruction tags for the test code.
4. Capture findings with precise evidence links, formatted as `- Evidence: [path/to/file](path/to/file#L10-L40) — violates [PW-TS-LOC-002] because ...`.
5. Record unknowns explicitly using **Unknown from code – {action}** (for example missing `playwright.config.ts` or undocumented fixture patterns).

### 3) Plan refactoring and rework

1. Group findings into actionable workstreams (for example "Locator modernisation", "Assertion alignment", "test.step adoption", "Page Object extraction", "Flakiness mitigation").
2. For each workstream, provide:
   - Objective
   - Files to touch (with justification)
   - Specific instruction tags they satisfy
   - Order of execution (prioritise stability-critical fixes first)
3. Store the plan in `docs/prompt-reports/playwright-typescript-instructions-alignment-plan.md` for traceability.

### 4) Implement the changes (iterative, safe batches)

1. Execute the plan in small batches, keeping commits narrowly scoped and referencing instruction tags.
2. Prefer refactors that replace CSS/XPath with role-based locators, add missing `await`, wrap actions in `test.step()`, extract Page Objects, or remove anti-patterns.
3. Update docs, Makefiles, CI, and configuration to keep guidance, automation, and behaviour in sync.

### 5) Validate quality gates and behavioural parity

1. After each batch, run `npx playwright test --project=chromium` or the repository's Playwright target (for example `make test-e2e`, `pnpm test:e2e`) and iterate until tests pass and remain stable per [PW-TS-EXE-001]–[PW-TS-EXE-008] and [PW-TS-STB-001]–[PW-TS-STB-004].
2. When changes touch shared TypeScript tooling or application code, run the TypeScript quality gates per [TS-QG-001]–[TS-QG-007].
3. If additional checks exist (for example `--ui` debugging, `--trace on` for failures), run them when the touched areas require it.
4. Document failures and fixes in the plan file; unresolved issues must be tracked as blockers.

### 6) Summarise outcomes and next steps

1. Produce a final enforcement report (append to `docs/prompt-reports/playwright-typescript-instructions-alignment-plan.md`) covering:
   - Resolved discrepancies (with references)
   - Remaining gaps / technical debt
   - Follow-up actions with owners and due dates
2. Confirm there are no lingering **Unknown from code** items; if any remain, convert them into explicit follow-ups.
3. Share the plan/report with maintainers (for example via PR description) to keep the team aligned.

---

## Output requirements

- Use concrete evidence links for every finding or change request.
- Reference instruction identifiers (for example `[PW-TS-LOC-001]`) when explaining discrepancies or fixes.
- Keep activities broken into the steps above; do not skip steps even if the tests appear compliant.
- Prefer automation (ESLint, Playwright trace analysis) over manual spot checks where feasible.
- Maintain ASCII-only text unless the repository already contains Unicode in the touched files.
- When information is missing, record **Unknown from code – {suggested action}** instead of guessing.

Context for prioritization: $ARGUMENTS

---

> **Version**: 1.0.3
> **Last Amended**: 2026-01-17
