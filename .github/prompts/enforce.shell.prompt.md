---
agent: agent
description: Enforce repository-wide compliance with shell.instructions.md
---

**Mandatory preparation:**

- Read the [constitution](../../.specify/memory/constitution.md) for non-negotiable rules, if you have not done already.
- Read the [Shell instructions](../instructions/shell.instructions.md).
- Reference identifiers (for example `[SH-QR-001]`) as you must assess compliance against each of them across the codebase and remediate any deviations.
- Read the [codebase overview instructions](../instructions/includes/codebase-overview-baseline.include.md) and adopt the approach for gathering supporting evidence.

## User Input ⌨️

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal 🎯

Enumerate every shell script artefact in the repository, detect any discrepancies against `shell.instructions.md`, plan the refactor/rework workstream, implement the required changes, and confirm compliance.

---

## Discovery (run before writing) 🔍

### A. Enumerate shell script scope

1. Run `git ls-files '*.sh' '*.bash' '*.zsh'` (include glue files such as `.shellcheckrc`, Makefile targets, CI configs, `scripts/` helpers, and test scripts) to capture the full shell footprint.
2. Categorise each file into **CLI entrypoints**, **wrapper scripts**, **libraries (`*.lib.sh`)**, **tests**, **hooks**, or **CI/tooling**; flag generated or vendored scripts to avoid editing.
3. Record locations that define standard helpers (`is-arg-true`), native/Docker execution fallbacks, test suites, and ShellCheck configuration.

### B. Load enforcement context

1. Re-read the relevant sections of `shell.instructions.md` for the patterns present (header structure, function conventions, dual execution, testing).
2. Note any repository ADRs or docs that explicitly override defaults; if none exist, assume the instructions are fully binding.
3. Summarise uncertainties as **Unknown from code – verify {topic} with maintainers** before proceeding.

---

## Steps 👣

> **Note:** On subsequent runs, check whether artefacts from earlier executions (for example `docs/prompts/shell-inventory.md`, `docs/prompts/shell-instructions-alignment-plan.md`) already exist and parse them so progress is cumulative rather than duplicated.

### 1) Build the shell artefact matrix

1. Produce a table (for example in `docs/prompts/shell-inventory.md`) listing each script/library, its role, and the key instruction tags that apply.
2. Highlight high-risk areas (missing headers, unsafe defaults, inconsistent function naming, unquoted variables, missing tests) where divergence is most likely.

### 2) Detect discrepancies against instructions

1. For each artefact, scan for violations of instruction tags (header structure, `set -euo pipefail`, `main()` entrypoint, kebab-case functions, explicit returns, doc blocks, safe variable handling, error handling).
2. Assess each artefact and file against compliance of each reference identifier (for example `[SH-QR-001]`) from the `shell.instructions.md` file.
3. Verify wrapper scripts follow the native/Docker execution pattern per [SH-EXEC-001]–[SH-EXEC-005] and use the `is-arg-true` helper per [SH-VAR-006].
4. Check library conventions per [SH-LIB-001]–[SH-LIB-005] (naming, no `main`/`exit`, function prefixes).
5. Validate test suite patterns per [SH-TST-001]–[SH-TST-016] where scripts require coverage.
6. Capture findings with precise evidence links, formatted as `- Evidence: [path/to/script.sh](path/to/script.sh#L10-L40) — violates [SH-HDR-001] because ...`.
7. Record unknowns explicitly using **Unknown from code – {action}** (for example unclear execution mode or missing test harness).

### 3) Plan refactoring and rework

1. Group findings into actionable workstreams (for example "Header normalization", "Wrapper execution alignment", "Test suite coverage", "ShellCheck hygiene").
2. For each workstream, provide:
   - Objective
   - Files to touch (with justification)
   - Specific instruction tags they satisfy
   - Order of execution (prioritise safety and error-handling fixes first)
3. Store the plan in `docs/prompts/shell-instructions-alignment-plan.md` for traceability.

### 4) Implement the changes (iterative, safe batches)

1. Execute the plan in small batches, keeping commits narrowly scoped and referencing instruction tags.
2. Prefer refactors that add standard headers, enforce safe defaults, restructure into `main()` with helper functions, and align wrappers with native/Docker fallback.
3. Update docs, Makefiles, CI, and scripts to keep guidance, automation, and behaviour in sync.

### 5) Validate quality gates and behavioural parity

1. After each batch, run ShellCheck on the affected scripts (for example `shellcheck scripts/**/*.sh` or repository targets) and iterate until all pass with zero warnings per [SH-QG-001]–[SH-QG-005].
2. If test suites exist, run the affected shell tests and any related Makefile targets.
3. Document failures and fixes in the plan file; unresolved issues must be tracked as blockers.

### 6) Summarise outcomes and next steps

1. Append a final enforcement report to `docs/prompts/shell-instructions-alignment-plan.md` covering:
   - Resolved discrepancies (with references)
   - Remaining gaps / technical debt
   - Follow-up actions with owners and due dates
2. Confirm there are no lingering **Unknown from code** items; convert any remaining ones into explicit follow-ups.
3. Share the plan/report with maintainers (for example via PR description) to keep the team aligned.

---

## Output requirements 📋

- Use concrete evidence links for every finding or change request.
- Reference instruction identifiers (for example `[SH-HDR-001]`) when explaining discrepancies or fixes.
- Keep activities broken into the steps above; do not skip steps even if the scripts appear compliant.
- Prefer automation (ShellCheck, tests) over manual spot checks where feasible.
- Maintain ASCII-only text unless the repository already contains Unicode in the touched files.
- When information is missing, record **Unknown from code – {suggested action}** instead of guessing.

Context for prioritization: $ARGUMENTS

---

> **Version**: 1.0.1
> **Last Amended**: 2026-01-17
