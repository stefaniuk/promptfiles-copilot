---
applyTo: "{Makefile,**/Makefile,**/*.mk}"
---

# Makefile Engineering Instructions (developer experience, CI-aligned) 🛠️

These instructions define the default engineering approach for using **Makefiles as orchestration**, not as a place for complex logic.

They must remain applicable to:

- Small repos with a single `Makefile`
- Modular repos that include shared `*.mk` modules (recommended)
- Repos where `make` is the **canonical interface** for local dev and CI/CD

They are **non-negotiable** unless an exception is explicitly documented (with rationale and expiry) in an ADR/decision record.

**Identifier scheme.** Every normative rule carries a unique tag in the form `[MK-<prefix>-NNN]`, where the prefix maps to the containing section (for example `OP` for Operating Principles, `LCL` for Local-first developer experience, `STR` for Structure, `UX` for Target UX, `SH` for Shell & safety, `VAR` for Variables, `SEC` for Security, `CI` for CI alignment, `QG` for Quality Gates, and `AI` for AI-assisted expectations). Use these identifiers when referencing, planning, or validating requirements.

---

## 0. Quick reference (apply first) 🧠

This section exists so humans and AI assistants can reliably apply the most important rules even when context is tight.

- [MK-QR-001] **Thin root Makefile**: keep the top-level `Makefile` small; push reusable logic into `scripts/**/*.mk` and `scripts/**/*.sh` ([MK-STR-001], [MK-STR-004], [MK-SH-008]).
- [MK-QR-002] **Help-first UX**: default goal is `help`; every public target has an inline description and category ([MK-UX-001]–[MK-UX-006]).
- [MK-QR-003] **Safe by default**: no destructive behaviour without explicit scoping and confirmation options ([MK-SEC-001]–[MK-SEC-006]).
- [MK-QR-004] **Fail fast**: recipes must fail on errors; never hide failures ([MK-SH-001]–[MK-SH-006]).
- [MK-QR-005] **CI uses make**: CI/CD should call the same targets developers run locally ([MK-CI-001]–[MK-CI-006]).
- [MK-QR-006] **Deterministic targets**: stable outputs and consistent environment handling ([MK-OP-003], [MK-VAR-001]–[MK-VAR-006]).
- [MK-QR-007] **Small, testable changes**: prefer incremental improvements; do not rewrite the build system as a "clean-up" ([MK-OP-002], [MK-AI-001]).
- [MK-QR-008] **Fast feedback**: local development and tests must be quick and confidence-building ([MK-OP-005], [MK-LCL-001]–[MK-LCL-005]).
- [MK-QR-009] **Run the quality gates** after any Makefile/script change and iterate to clean ([MK-QG-001]–[MK-QG-003]).

---

## 1. Operating principles 🧭

These principles extend [constitution.md §3](../../.specify/memory/constitution.md#3-core-principles-non-negotiable).

- [MK-OP-001] Treat the Makefile interface as a **public contract** for engineers and CI: stable target names, stable variables, predictable behaviour.
- [MK-OP-002] Prefer **small, explicit, testable** changes over broad rewrites.
- [MK-OP-003] Design for **determinism**: the same inputs produce the same outputs.
- [MK-OP-004] Make is for **orchestration**. Complex logic belongs in scripts (shell, Python, etc.).
- [MK-OP-005] **Fast feedback is paramount**: key local targets must be quick, automated, and confidence-building.
- [MK-OP-006] Avoid inventing requirements or expanding scope beyond what the repo needs.
- [MK-OP-007] Optimise for **maintenance, usability, and change safety**, not cleverness.

---

## 2. Local-first developer experience (bleeding-edge fast feedback) ⚡

The build system must be **fully usable locally**, providing rapid feedback before CI.

### 2.1 Single-command workflow (must exist)

Provide repository-standard targets so an engineer can operate the repo quickly:

- [MK-LCL-001] Bootstrap: `make dev` — prepares a working local environment (installs tools, dependencies)
- [MK-LCL-002] Lint/format: `make lint` — runs linters and formatters
- [MK-LCL-003] Test (fast lane): `make test` — must run quickly (aim: < 10 seconds for unit tests) and deterministically
- [MK-LCL-004] Full suite: `make test-all` — includes integration/e2e tiers (if applicable)
- [MK-LCL-005] Build: `make build` — compiles or packages artefacts (if applicable)
- [MK-LCL-006] Run locally: `make run` or `make up` / `make down` — starts/stops the application or dependency stack (if applicable)

### 2.2 Clear, actionable errors

- [MK-LCL-007] Any target that runs tools must produce clear, actionable errors when tools are missing (for example "install X via asdf" or "run make dev").
- [MK-LCL-008] Do not fail silently; prefer explicit prerequisite checks with helpful messages.

### 2.3 Script delegation (recommended)

- [MK-LCL-009] Prefer calling scripts under `scripts/**/*.sh` (or similar) from make, rather than writing test/build logic inside make recipes.
- [MK-LCL-010] Scripts should be independently runnable for debugging.

### 2.4 Environment check (recommended)

- [MK-LCL-011] Where supported, provide a "doctor" target (for example `make doctor`) that confirms local prerequisites and surfaces actionable fixes.

---

## 3. Structure and modularity 🧱

### 3.1 File layout and includes (recommended baseline)

- [MK-STR-001] The root `Makefile` should be **thin** and primarily:
  - include shared bootstrap modules (for example `include scripts/init.mk`);
  - define only project-specific hooks used by developers and CI/CD.
- [MK-STR-002] Shared targets must live in `scripts/**/*.mk` modules where feasible.
- [MK-STR-003] Required modules use `include`. Optional modules use `-include`.
- [MK-STR-004] Reusable logic must live in scripts (for example `scripts/**/something.sh`) and be called from a wrapper target; do not embed large shell programs inside recipes.
- [MK-STR-005] If the repo uses a shared template module, add a clear banner comment such as "DO NOT edit – maintained upstream".

### 3.2 Target composition across modules

- [MK-STR-006] When multiple included modules contribute to the same target, use **double-colon** rules so modules can extend safely:
  - `clean::` for cleanup steps
  - `config::` for environment configuration steps
- [MK-STR-007] Each module's contribution to `clean::` and `config::` must be independently safe and not depend on another module having run first.

---

## 4. Target UX and discoverability 📖

### 4.1 Help is mandatory

- [MK-UX-001] `.DEFAULT_GOAL := help` must be set.
- [MK-UX-002] A `help` target must exist and print a readable list of public targets.
- [MK-UX-003] Each **public** target must include an inline description using the standard pattern:

  ```makefile
  some-target: # One-line description - mandatory: foo=[...]; optional: bar=[..., default is X] @Category
  ```

- [MK-UX-004] Categories must be short and consistent. Preferred set:
  - `@Pipeline`, `@Development`, `@Testing`, `@Quality`, `@Operations`, `@Configuration`, `@ExamplesAndTests`, `@Others`
- [MK-UX-005] Internal/helper targets must be prefixed with `_` and must not be presented as the primary entrypoints.
- [MK-UX-006] Target names should use **verb-noun** and hyphens (for example `test-unit`, `docker-build`, `terraform-plan`).

### 4.2 Guardrails for "public" targets

- [MK-UX-007] Public targets must document required variables (mandatory/optional) in the help description.
- [MK-UX-008] Public targets must not rely on interactive prompts in CI paths; provide non-interactive defaults and flags.

---

## 5. Shell execution model and failure behaviour 🧨

**Section summary (key subsections):**

- 5.1 Fail-fast defaults — non-negotiable shell safety
- 5.2 Parallelism and environment — recursive calls and job control
- 5.3 Keep recipes small — delegation to scripts

### 5.1 Fail-fast defaults (non-negotiable)

- [MK-SH-001] Use bash consistently unless the repo explicitly documents another shell:
  - `SHELL := /bin/bash`
- [MK-SH-002] Use a fail-fast shell mode (at least `-e`), and prefer:
  - `.ONESHELL:`
  - `.SHELLFLAGS := -ce` (and enable tracing in verbose mode, for example `-cex`)
- [MK-SH-003] Do not mask failures. Avoid patterns like `|| true` unless there is a clear comment explaining why it is safe.
- [MK-SH-004] When a recipe fails, it must fail the make target (non-zero exit).

### 5.2 Parallelism and environment

- [MK-SH-005] Default to `.NOTPARALLEL:` unless you have proved targets are safe in parallel.
- [MK-SH-006] Prefer `$(MAKE)` over `make` for recursive calls, so flags and jobserver settings propagate.

### 5.3 Keep recipes small

- [MK-SH-007] A make recipe should not exceed ~5 effective lines of logic. If it does, move that logic into a script.
- [MK-SH-008] Wrapper targets (for example `_docker`, `_test`, `_terraform`) are encouraged:
  - set up environment/variables
  - call a script or sourced library function
  - handle "missing file/tool" with an actionable error message

---

## 6. Variables, parameters, and defaults 🔧

- [MK-VAR-001] Expose common parameters as variables with sane defaults using `?=`.
- [MK-VAR-002] Support convenient aliases where it improves usability (for example allow `docker_dir` and `dir` to map to the same value).
- [MK-VAR-003] Do not hardcode organisation- or environment-specific paths inside recipes; prefer variables and documented defaults.
- [MK-VAR-004] Variables passed to scripts must be explicit and stable (avoid hidden global coupling).
- [MK-VAR-005] Do not print secrets when listing variables or echoing commands. Treat variables ending with `_PASSWORD`, `_PASS`, `_KEY`, `_SECRET`, `_TOKEN` as sensitive by default.
- [MK-VAR-006] Prefer `MAKEFLAGS += --no-print-directory` (or equivalent) to reduce noise.
- [MK-VAR-007] Document precedence when variables can be set via multiple sources (command-line, environment, file). Prefer: command-line > environment > file > built-in default.

---

## 7. Safety and security defaults 🔐

**Section summary (key subsections):**

- 7.1 Destructive actions — safe defaults, confirmation patterns
- 7.2 Secrets handling — never embed or print secrets
- 7.3 Network and cloud operations — explicit intent, no implicit cloud calls

### 7.1 Destructive actions

- [MK-SEC-001] Default behaviour must be safe. Destructive actions must require explicit intent.
- [MK-SEC-002] `clean` must only delete well-known generated artefacts within the repo (no unscoped `rm -rf` outside the workspace).
- [MK-SEC-003] If a target can delete or overwrite user data, it must:
  - support `DRY_RUN=1` where feasible, and/or
  - require a strong confirmation variable (for example `CONFIRM=YES`).

### 7.2 Secrets handling

- [MK-SEC-004] Never embed secrets in Makefiles.
- [MK-SEC-005] Never print secrets in logs, help output, or error messages.
- [MK-SEC-006] Sensitive variable patterns are defined in [MK-VAR-005].

### 7.3 Network and cloud operations

- [MK-SEC-007] Network or cloud operations must be explicit (for example `make deploy ENV=...`) and must not run by default in `dev`, `lint`, or `test`.
- [MK-SEC-008] Default local targets must not require real cloud credentials.

---

## 8. CI/CD alignment 🧰

**Section summary (key subsections):**

- 8.1 Target naming and stability — predictable CI interface
- 8.2 Reproducibility — determinism and clean workspaces

### 8.1 Target naming and stability

- [MK-CI-001] CI/CD workflows should call make targets (not duplicated inline bash).
- [MK-CI-002] Pipeline targets should be stable and predictable. Common names include:
  - `dependencies`, `build`, `test`, `publish`, `deploy`, `clean`
- [MK-CI-003] Targets used in CI must be non-interactive.

### 8.2 Reproducibility

- [MK-CI-004] Targets used in CI must be deterministic and safe in a clean workspace.
- [MK-CI-005] Where possible, local and CI use the **same** targets and scripts.
- [MK-CI-006] If CI requires extra flags (for example `CI=true`), they must be documented and should not change core behaviour beyond safety and logging.
- [MK-CI-007] Logs produced by CI targets must be structured or parseable where possible; prefer stable output formats.

---

## 9. Mandatory quality gates (constitution §7.8) ✅

Per operating principles ([MK-OP-002], [MK-OP-005]) **and** [constitution.md §7.8](../../.specify/memory/constitution.md#78-mandatory-local-quality-gates), after making **any** change to Makefiles, scripts, or build configuration, you must run the repository's **canonical** quality gates:

1. Prefer:

- [MK-QG-001] `make lint`
- [MK-QG-002] `make test`

2. If `make` targets do not exist, discover and run the project's equivalent commands.

- [MK-QG-003] You must continue iterating until all checks complete successfully with **no errors or warnings**. Do this automatically, without requiring an additional prompt.
- [MK-QG-004] Warnings must be treated as defects unless explicitly waived in an ADR (rationale + expiry).

---

## 10. AI-assisted change expectations 🤖

This section defines expectations when AI assistants modify Makefiles or build scripts.

### 10.1 Scope and intent

- [MK-AI-001] Do not invent targets or workflows not needed by the repo.
- [MK-AI-002] Keep changes minimal and aligned with existing conventions.
- [MK-AI-003] Avoid inventing requirements, widening scope, or introducing behaviour not present in the specification.

### 10.2 New target checklist

If you introduce a new public target, you must:

- [MK-AI-004] Add a help description + category ([MK-UX-003], [MK-UX-004]).
- [MK-AI-005] Keep the recipe small ([MK-SH-007]).
- [MK-AI-006] Add/update scripts as needed ([MK-SH-008]).
- [MK-AI-007] Ensure it runs locally and in CI where intended ([MK-CI-001]–[MK-CI-006]).
- [MK-AI-008] Run quality gates and iterate to clean ([MK-QG-001]–[MK-QG-004]).

### 10.3 Existing target modifications

When modifying existing targets:

- [MK-AI-009] Preserve backward compatibility unless a breaking change is explicitly requested.
- [MK-AI-010] Document any behavioural changes in commit messages or PR descriptions.
- [MK-AI-011] Verify the change works in both local and CI contexts.

### 10.4 Deviations

- [MK-AI-012] If you must deviate from these instructions, propose an ADR/decision record (rationale + expiry).

---

> **Version**: 1.1.0
> **Last Amended**: 2026-01-03
