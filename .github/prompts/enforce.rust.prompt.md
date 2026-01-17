---
agent: agent
description: Enforce repository-wide compliance with rust.instructions.md
---

**Mandatory preparation:**

- Read the [constitution](../../.specify/memory/constitution.md) for non-negotiable rules, if you have not done already.
- Read the [Rust instructions](../instructions/rust.instructions.md).
- Reference identifiers (for example `[RS-QR-001]`) as you must assess compliance against each of them across the codebase and remediate any deviations.
- Read the [codebase overview instructions](../instructions/includes/codebase-overview-baseline.include.md) and adopt the approach for gathering supporting evidence.

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Enumerate every Rust artefact in the repository, detect any discrepancies against `rust.instructions.md`, plan the refactor/rework workstream, implement the required changes, and confirm compliance.

---

## Discovery (run before writing)

### A. Enumerate Rust scope

1. Run `git ls-files '*.rs'` (include glue files such as `Cargo.toml`, `Cargo.lock`, `rust-toolchain.toml`, `.cargo/config.toml`, `Makefile`, CI configs) to capture the full Rust footprint.
2. Categorise each file into **binaries/CLI**, **libraries/crates**, **async runtime code**, **unsafe blocks**, **tests**, **benchmarks**, or **build scripts**.
3. Record locations that declare tooling (Clippy, rustfmt, cargo-deny, CI workflows) to ensure the instructions apply consistently.

### B. Load enforcement context

1. Re-read the relevant sections of `rust.instructions.md` for the patterns present (decision criteria, async, error handling, CLI behaviour, unsafe, API design, observability, etc.).
2. Note any repository ADRs or docs that explicitly override defaults; if none exist, assume the instructions are fully binding.
3. Summarise uncertainties as **Unknown from code – verify {topic} with maintainers** before proceeding.

---

## Steps

> **Note:** On subsequent runs, check whether artefacts from earlier executions (for example `docs/prompt-reports/rust-inventory.md`, `docs/prompt-reports/rust-instructions-alignment-plan.md`) already exist and parse them so progress is cumulative rather than duplicated.

### 1) Build the Rust artefact matrix

1. Produce a table (for example in `docs/prompt-reports/rust-inventory.md`) listing each Rust file or crate, its role, and the key instruction tags that apply.
2. Highlight high-risk areas (unsafe blocks, async boundaries, error handling, CLI entrypoints, public API surfaces) where divergence is most likely.

### 2) Detect discrepancies against instructions

1. For each artefact, scan for violations of instruction tags (function size, clone usage, async correctness, error types, unsafe comments, CLI contract, observability, etc.).
2. Assess each artefact and file against compliance of each reference identifier (for example `[RS-QR-001]`) from the `rust.instructions.md` file.
3. Capture findings with precise evidence links, formatted as `- Evidence: [path/to/file](path/to/file#L10-L40) — violates [RS-ASY-001] because ...`.
4. Record unknowns explicitly using **Unknown from code – {action}** (for example missing `// SAFETY:` comment or undocumented cancellation behaviour).

### 3) Plan refactoring and rework

1. Group findings into actionable workstreams (for example "Async correctness", "Error type alignment", "Unsafe review", "CLI contract compliance", "Observability integration").
2. For each workstream, provide:
   - Objective
   - Files to touch (with justification)
   - Specific instruction tags they satisfy
   - Order of execution (prioritise safety-critical fixes first — unsafe, async, error handling)
3. Store the plan in `docs/prompt-reports/rust-instructions-alignment-plan.md` for traceability.

### 4) Implement the changes (iterative, safe batches)

1. Execute the plan in small batches, keeping commits narrowly scoped and referencing instruction tags.
2. Prefer refactors that add `// SAFETY:` comments, fix blocking-in-async, replace `unwrap()` with proper error handling, align CLI exit codes, or integrate `tracing`.
3. Update docs, Makefiles, CI, and configuration to keep guidance, automation, and behaviour in sync.

### 5) Validate quality gates and behavioural parity

1. After each batch, run `cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test`, `cargo test --no-default-features`, `cargo test --all-features`, `cargo doc --no-deps`, and `cargo audit` (or mapped make targets) and iterate until all pass per [RS-QG-001]–[RS-QG-005].
2. If additional checks exist (for example `cargo deny check`, `cargo +nightly miri test`, benchmark suites), run them when the touched areas require it.
3. Document failures and fixes in the plan file; unresolved issues must be tracked as blockers.

### 6) Summarise outcomes and next steps

1. Produce a final enforcement report (append to `docs/prompt-reports/rust-instructions-alignment-plan.md`) covering:
   - Resolved discrepancies (with references)
   - Remaining gaps / technical debt
   - Follow-up actions with owners and due dates
2. Confirm there are no lingering **Unknown from code** items; if any remain, convert them into explicit follow-ups.
3. Share the plan/report with maintainers (for example via PR description) to keep the team aligned.

---

## Output requirements

- Use concrete evidence links for every finding or change request.
- Reference instruction identifiers (for example `[RS-ERR-001]`) when explaining discrepancies or fixes.
- Keep activities broken into the steps above; do not skip steps even if the code appears compliant.
- Prefer automation (Clippy, rustfmt, cargo-deny, cargo-audit) over manual spot checks where feasible.
- Maintain ASCII-only text unless the repository already contains Unicode in the touched files.
- When information is missing, record **Unknown from code – {suggested action}** instead of guessing.

Context for prioritization: $ARGUMENTS

---

> **Version**: 1.0.3
> **Last Amended**: 2025-01-17
