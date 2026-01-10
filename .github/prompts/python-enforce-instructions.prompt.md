---
agent: agent
description: Enforce repository-wide compliance with python.instructions.md
---

**Mandatory preparation:**

- Read [python instructions](../instructions/python.instructions.md) in full and reference their identifiers (for example `[PY-QR-001]`).
- If present, skim [codebase overview](../instructions/include/codebase-overview.md) for vocabulary, but treat code/config as authoritative.

## Goal

Enumerate every Python artefact in the repository, detect any discrepancies against `python.instructions.md`, plan the refactor/rework workstream, implement the required changes, and confirm compliance.

---

## Discovery (run before writing)

### A. Enumerate Python scope

1. Run `git ls-files '*.py'` (and include glue files such as `pyproject.toml`, `uv.lock`, `requirements*.txt`, `Makefile`, CI configs) to capture the full Python footprint.
2. Categorise each file into **entrypoints/CLI**, **framework apps (FastAPI/Django/etc.)**, **libraries/modules**, **tests**, **tooling/scripts**, or **configuration**.
3. Record locations that declare tooling (for example Ruff, Pytest, mypy, uv) to ensure instructions apply consistently.

### B. Load enforcement context

1. Re-read the relevant sections of `python.instructions.md` for the features present (CLI, API, Lambda, etc.).
2. Note any repository ADRs or docs that explicitly override defaults; if none exist, assume the instructions are fully binding.
3. Summarise any uncertainties as **Unknown from code – verify {topic} with maintainers** before proceeding.

---

## Steps

> **Note:** On subsequent runs, check whether the artefacts produced by earlier executions (for example `docs/prompt-reports/python-inventory.md`, `docs/prompt-reports/python-instructions-alignment-plan.md`) already exist and parse them so progress is cumulative rather than duplicated.

### 1) Build the Python artefact matrix

1. Produce a table (for example in `docs/prompt-reports/python-inventory.md`) listing each Python file/folder, its role, and key instruction tags that apply.
2. Highlight high-risk areas (entrypoints, shared utilities, data models) where divergence is most likely.

### 2) Detect discrepancies against instructions

1. For each artefact, scan for violations of the instruction tags (CLI contract, quality gates, observability, security, etc.).
2. Capture findings with precise evidence links, formatted as `- Evidence: [path/to/file](path/to/file#L10-L40) — violates [PY-CTR-008] because ...`.
3. Record unknowns explicitly using **Unknown from code – {action}** (for example missing `uv` lockfile or undocumented CLI modes).

### 3) Plan refactoring and rework

1. Group findings into actionable workstreams (for example "CLI stream separation", "Structured logging", "Quality gates automation").
2. For each workstream, provide:
   - Objective
   - Files to touch (with justification)
   - Specific instructions tags they satisfy
   - Order of execution (prioritise safety-critical fixes first)
3. Store the plan in `docs/prompt-reports/python-instructions-alignment-plan.md` for traceability.

### 4) Implement the changes (iterative, safe batches)

1. Execute the plan in small batches, keeping commits narrowly scoped and referencing instruction tags.
2. Prefer refactors that move logic into shared modules, add missing tooling config, or adjust CLIs/APIs to match the contract.
3. Update docs, Makefiles, CI, and configuration to keep guidance, automation, and behaviour in sync.

### 5) Validate quality gates and behavioural parity

1. After each batch, run `make lint` and `make test`; iterate until both pass with zero warnings (per `[PY-QG-003]`).
2. If additional checks exist (for example `make type-check`, `uv run pytest -m integration`), run them when the touched areas require it.
3. Document any failures and fixes in the plan file; unresolved issues must be tracked as blockers.

### 6) Summarise outcomes and next steps

1. Produce a final enforcement report (append to `docs/prompt-reports/python-instructions-alignment-plan.md`) covering:
   - Resolved discrepancies (with references)
   - Remaining gaps / technical debt
   - Follow-up actions with owners and due dates
2. Confirm there are no lingering **Unknown from code** items; if any remain, turn them into explicit follow-ups.
3. Share the plan/report with maintainers (for example via PR description) to keep the team aligned.

---

## Output requirements

- Use concrete evidence links for every finding or change request.
- Reference instruction identifiers (for example `[PY-CTR-006]`) when explaining discrepancies or fixes.
- Keep activities broken into the steps above; do not skip steps even if the code appears compliant.
- Prefer automation (scripts, linters) over manual spot checks where feasible.
- Maintain ASCII-only text unless the repository already contains Unicode in the touched files.
- When information is missing, record **Unknown from code – {suggested action}** instead of guessing.

---

> **Version**: 1.0.1
> **Last Amended**: 2026-01-10
