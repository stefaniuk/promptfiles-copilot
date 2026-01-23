---
agent: agent
description: Enforce repository-wide compliance with tauri.instructions.md
---

**Mandatory preparation:**

- Read the [constitution](../../.specify/memory/constitution.md) for non-negotiable rules, if you have not done already.
- Read the [Tauri instructions](../instructions/tauri.instructions.md).
- Read the [Rust instructions](../instructions/rust.instructions.md), [ReactJS instructions](../instructions/reactjs.instructions.md), and [TypeScript instructions](../instructions/typescript.instructions.md) for shared language and tooling expectations.
- Reference identifiers (for example `[TAU-QR-001]`) as you must assess compliance against each of them across the codebase and remediate any deviations.
- Read the [codebase overview instructions](../instructions/includes/codebase-overview-baseline.include.md) and adopt the approach for gathering supporting evidence.

## User Input ⌨️

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal 🎯

Enumerate every Tauri artefact in the repository, detect any discrepancies against `tauri.instructions.md`, plan the refactor/rework workstream, implement the required changes, and confirm compliance.

---

## Discovery (run before writing) 🔍

### A. Enumerate Tauri scope

1. Run `git ls-files 'src-tauri/**/*.rs' 'src-tauri/**/*.json' 'src/**/*.ts' 'src/**/*.tsx'` (include glue files such as `tauri.conf.json`, `capabilities/*.json`, `Cargo.toml`, `package.json`, `Makefile`, CI configs) to capture the full Tauri footprint.
2. Categorise each file into **Rust backend (commands/events)**, **frontend UI**, **capabilities/permissions**, **IPC contracts**, **configuration**, **build/distribution**, or **tests**.
3. Record locations that declare tooling (Tauri CLI, Clippy, ESLint, TypeScript config, CI workflows) to ensure the instructions apply consistently.

### B. Load enforcement context

1. Re-read the relevant sections of `tauri.instructions.md` for the patterns present (security model, IPC design, capabilities, distribution, testing, etc.).
2. Note any repository ADRs or docs that explicitly override defaults; if none exist, assume the instructions are fully binding.
3. Summarise uncertainties as **Unknown from code – verify {topic} with maintainers** before proceeding.

---

## Steps 👣

> **Note:** On subsequent runs, check whether artefacts from earlier executions (for example `docs/prompts/tauri-inventory.md`, `docs/prompts/tauri-instructions-alignment-plan.md`) already exist and parse them so progress is cumulative rather than duplicated.

### 1) Build the Tauri artefact matrix

1. Produce a table (for example in `docs/prompts/tauri-inventory.md`) listing each Tauri file or component, its role, and the key instruction tags that apply.
2. Highlight high-risk areas (capability definitions, IPC commands, CSP configuration, filesystem access, update signing) where divergence is most likely.

### 2) Detect discrepancies against instructions

1. For each artefact, scan for violations of instruction tags (least privilege, strict CSP, no remote content, UI untrusted, commands vs events, operation IDs, etc.).
2. Assess each artefact and file against compliance of each reference identifier (for example `[TAU-QR-001]`) from the `tauri.instructions.md` file.
3. Validate the Tauri quality checklist and anti-patterns per [TAU-CHK-001]–[TAU-CHK-009] and §9.
4. Confirm toolchain pinning and distribution requirements per [TAU-DST-001]–[TAU-DST-004], plus dependency scanning per [TAU-TST-004].
5. Ensure Rust/React/TypeScript instruction tags are enforced for their respective surfaces per [TAU-CHK-008]–[TAU-CHK-009].
6. Capture findings with precise evidence links, formatted as `- Evidence: [path/to/file](path/to/file#L10-L40) — violates [TAU-CAP-001] because ...`.
7. Record unknowns explicitly using **Unknown from code – {action}** (for example overly permissive capability or missing update signature).

### 3) Plan refactoring and rework

1. Group findings into actionable workstreams (for example "Capability tightening", "CSP hardening", "IPC contract alignment", "Event listener cleanup", "Update signing").
2. For each workstream, provide:
   - Objective
   - Files to touch (with justification)
   - Specific instruction tags they satisfy
   - Order of execution (prioritise security-critical fixes first — capabilities, CSP, remote content)
3. Store the plan in `docs/prompts/tauri-instructions-alignment-plan.md` for traceability.

### 4) Implement the changes (iterative, safe batches)

1. Execute the plan in small batches, keeping commits narrowly scoped and referencing instruction tags.
2. Prefer refactors that restrict capabilities, strengthen CSP, remove remote content, add operation IDs, clean up event listeners, or align IPC patterns.
3. Update docs, Makefiles, CI, and configuration to keep guidance, automation, and behaviour in sync.

### 5) Validate quality gates and behavioural parity

1. After each batch, run Rust and TypeScript quality gates (`cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test`, `cargo test --no-default-features`, `cargo test --all-features`, `cargo doc --no-deps`, `cargo audit`, plus `make format`, `make lint`, `make typecheck`, `make test` or repository equivalents) and iterate until all pass.
2. Run dependency scanning for Rust + npm per [TAU-TST-004] and verify update signing if the updater is enabled per [TAU-DST-003].
3. If additional checks exist (for example `tauri build`, capability validation, signing verification), run them when the touched areas require it.
4. Document failures and fixes in the plan file; unresolved issues must be tracked as blockers.

### 6) Summarise outcomes and next steps

1. Produce a final enforcement report (append to `docs/prompts/tauri-instructions-alignment-plan.md`) covering:
   - Resolved discrepancies (with references)
   - Remaining gaps / technical debt
   - Follow-up actions with owners and due dates
2. Confirm there are no lingering **Unknown from code** items; if any remain, convert them into explicit follow-ups.
3. Share the plan/report with maintainers (for example via PR description) to keep the team aligned.

---

## Output requirements 📋

- Use concrete evidence links for every finding or change request.
- Reference instruction identifiers (for example `[TAU-SEC-001]`) when explaining discrepancies or fixes.
- Keep activities broken into the steps above; do not skip steps even if the code appears compliant.
- Prefer automation (Clippy, ESLint, Tauri capability validation) over manual spot checks where feasible.
- Maintain ASCII-only text unless the repository already contains Unicode in the touched files.
- When information is missing, record **Unknown from code – {suggested action}** instead of guessing.

Context for prioritization: $ARGUMENTS

---

> **Version**: 1.0.4
> **Last Amended**: 2026-01-17
> **Last Amended**: 2026-01-17
