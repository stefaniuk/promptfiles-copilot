---
agent: agent
description: Enforce repository-wide compliance with terraform.instructions.md
---

**Mandatory preparation:**

- Read [Terraform instructions](../instructions/terraform.instructions.md) in full and reference their identifiers (for example `[TF-QR-001]`).
- If present, skim [codebase overview](../instructions/include/codebase-overview.md) for vocabulary, but treat Terraform configuration and state as authoritative.

## Goal

Enumerate every Terraform artefact in the repository, detect any discrepancies against `terraform.instructions.md`, plan the refactor/rework workstream, implement the required changes, and confirm compliance.

---

## Discovery (run before writing)

### A. Enumerate Terraform scope

1. Run `git ls-files '*.tf' '*.tfvars'` (include glue files such as `versions.tf`, `providers.tf`, `backend.hcl`, `.terraform.lock.hcl`, `Makefile`, CI configs, Dev Container definitions) to capture the full Terraform footprint.
2. Categorise each file/folder into **modules**, **stacks/environments**, **policies**, **tooling/scripts**, or **documentation**; flag any generated/vendor directories to ignore.
3. Record locations that declare tooling (pre-commit hooks, Makefile targets, CI workflows) so the enforcement plan can validate quality gates.

### B. Load enforcement context

1. Re-read the relevant sections of `terraform.instructions.md` for the stacks/modules present (networking, IAM, compute, observability, etc.).
2. Note any ADRs or docs that explicitly override defaults; if none exist, assume the instructions are fully binding.
3. Summarise uncertainties as **Unknown from code – verify {topic} with maintainers** before proceeding.

---

## Steps

> **Note:** On subsequent runs, detect whether earlier artefacts (for example `docs/terraform-inventory.md`, `docs/terraform-instructions-alignment-plan.md`) already exist and parse them so progress is cumulative rather than duplicated.

### 1) Build the Terraform artefact matrix

1. Produce a table (for example in `docs/terraform-inventory.md`) listing each module/stack file or folder, its role, environments it affects, and key instruction tags that apply.
2. Highlight high-risk areas (state backends, IAM, networking, encryption, CI/CD pipelines) where divergence is most likely.

### 2) Detect discrepancies against instructions

1. For each artefact, scan for violations of the Terraform instruction tags (plan-first discipline, London-only region, tagging, security, observability, etc.).
2. Capture findings with evidence links formatted as `- Evidence: [path/to/file](path/to/file#L10-L40) — violates [TF-REG-003] because ...`.
3. Record unknowns explicitly using **Unknown from code – {action}** (for example missing drift detection or undocumented apply processes).

### 3) Plan refactoring and rework

1. Group findings into actionable workstreams (for example "Remote state hardening", "Region enforcement", "Quality gate automation").
2. For each workstream, provide:
   - Objective
   - Files/stacks/modules to touch (with justification)
   - Specific instruction tags they satisfy
   - Order of execution (prioritise safety-critical fixes first)
3. Store the plan in `docs/terraform-instructions-alignment-plan.md` for traceability.

### 4) Implement the changes (iterative, safe batches)

1. Execute the plan in small batches, keeping commits narrowly scoped and referencing instruction tags.
2. Prefer changes that improve determinism (pinned providers, explicit regions), enhance security (least privilege, encryption), or document/apply workflows.
3. Update docs, Makefiles, CI jobs, and policy-as-code to keep guidance and automation aligned with the Terraform instructions.

### 5) Validate quality gates and behavioural parity

1. After each batch, run `terraform fmt`, `terraform validate`, `terraform plan`, and the repository's lint/scan targets (for example `make fmt`, `make validate`, `make plan`, `make lint`) until all pass with zero warnings per `[TF-QG-007]`.
2. If additional checks exist (for example `make test`, `terraform test`, drift detectors, security scanners), run them when the touched areas require it.
3. Document failures and fixes in the plan file; unresolved issues must be tracked as blockers.

### 6) Summarise outcomes and next steps

1. Append a final enforcement report to `docs/terraform-instructions-alignment-plan.md` covering:
   - Resolved discrepancies (with references)
   - Remaining gaps / technical debt
   - Follow-up actions with owners and due dates
2. Confirm there are no lingering **Unknown from code** items; convert any remaining ones into explicit follow-ups.
3. Share the plan/report with maintainers (for example via PR description) to keep the team aligned.

---

## Output requirements

- Use concrete evidence links for every finding or change request.
- Reference instruction identifiers (for example `[TF-STATE-003]`) when explaining discrepancies or fixes.
- Keep activities broken into the steps above; do not skip steps even if the configuration appears compliant.
- Prefer automation (scripts, linters, drift detectors) over manual spot checks where feasible.
- Maintain ASCII-only text unless the repository already contains Unicode in the touched files.
- When information is missing, record **Unknown from code – {suggested action}** instead of guessing.

---

> **Version**: 1.0.0
> **Last Amended**: 2026-01-10
