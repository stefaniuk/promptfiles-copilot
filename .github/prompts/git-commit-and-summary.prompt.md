---
description: Generate conventional commit message and summary from the current changes diff
---

**Mandatory preparation:**

- Ensure the repository has the `main` branch locally (`git fetch origin main:main` if needed).
- Read language/tooling instructions that apply to the files changed in the diff (for example [python.instructions.md](../instructions/python.instructions.md), [typescript.instructions.md](../instructions/typescript.instructions.md), [makefile.instructions.md](../instructions/makefile.instructions.md), etc.) so that commit messaging reflects the actual scope and intent.

## Goal

Produce three copy-ready outputs that always reflect the current work, whether the changes live on a dedicated branch or only in the working tree on `main`/detached `HEAD`:

1. A **Branch Name Suggestion**: if you are already on a feature branch, report whether it is suitable (and suggest an improvement if not); if you are on `main`/detached `HEAD`, propose a new branch using `scope-short-description` (e.g. `auth-add-sso-callback`).
2. A single-line **Conventional Commit** message (`type(scope?): summary`) that accurately describes the dominant change.
3. A concise **Change Summary** (Markdown) capturing the key modifications and their impact for release notes or PR descriptions.

All artefacts must be fully backed by the diff between `main` and the current `HEAD`, enriched with any staged or unstaged working tree changes.

---

## Discovery (run before writing)

### A. Establish the diff against `main`

Run the labelled batch below **once** from the repository root so each command prints a `>>> <command>` header followed by its output. This keeps every datum tied to the command that produced it and avoids duplicate executions.

```bash
for cmd in \
  "git fetch origin main" \
  "git diff --stat main...HEAD" \
  "git diff --name-status main...HEAD" \
  "git diff main...HEAD" \
  "git rev-parse --abbrev-ref HEAD" \
  "git status -sb" \
  "git log -3 --oneline"; do
  printf '\n>>> %s\n' "$cmd"
  eval "$cmd"
done
```

1. Use the labelled outputs above to confirm `main` is up to date.
2. Read the `git diff --stat` and `git diff --name-status` sections for the overview.
3. Inspect the `git diff main...HEAD` section for full context.
4. Capture branch/working-tree details from the `git status -sb` and `git rev-parse --abbrev-ref HEAD` sections.
5. If the diffs sections show no changes, output **"No diff vs main – nothing to commit."** and stop.
6. Mirror recent commit tone using the `git log -3 --oneline` section.

### B. Classify the change

1. Determine the dominant change type(s) for Conventional Commits (`feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `build`, `ci`, `perf`, `revert`).
2. Identify an optional `scope` by using the most relevant component, package, or directory touched (prefer values already used in the repo; fall back to a short directory name if unsure).
3. Note any breaking changes or notable follow-ups.

---

## Steps

### 1) Extract key evidence

1. List the primary files/folders touched.
2. Summarise behavioural changes (APIs, CLIs, jobs, infra, docs) in plain language.
3. Capture side effects (tests added, config changes, dependency updates).
4. Record unknowns explicitly (**Unknown from code – {action}**).
5. Note the current branch state (feature branch vs `main`/detached). If already on a feature branch, confirm whether its name matches the dominant change and suggest an improvement if not; otherwise, craft a new branch slug using `scope-short-description`.

### 2) Craft the Conventional Commit line

Follow these rules:

1. Format: `type(scope?): summary`.
2. `summary` ≤ 72 characters, present tense, no trailing punctuation.
3. Mention breaking changes by appending `!` after the type/scope (`feat(api)!: ...`) and list details in the summary block.
4. Ensure the summary is specific (e.g. `feat(auth): add SSO callback validator`).
5. If multiple change types exist, pick the most user-facing; note secondary changes in the summary section.

### 3) Write the change summary (copy-ready)

Produce a short Markdown block containing:

- **Overview:** 1–2 sentences describing the change impact.
- **Highlights:** Bullet list (max 5) with evidence-backed points referencing files/components.
- **Testing/verification:** Commands or checks run (or **Unknown from code – run {command}**).
- **Breaking changes / follow-ups:** Explicit call-outs if any.

### 4) Compile the final output (copy-ready template)

Return content exactly in this shape for easy copy/paste:

```markdown
## Branch name

{branch name}

## Commit message

{single line of commit message}

## Change Summary

**Overview**

...

**Highlights**

- ...

**Testing**

- ...

**Breaking changes / Follow-ups**

- ...
```

## Output requirements

- Ground every statement in the diff; if evidence is missing, record **Unknown from code – {suggested action}**.
- Ensure the branch suggestion covers both cases: re-affirm or improve the current feature branch name, or propose a new branch when working directly on `main`/detached `HEAD`.
- Prefer British English and concise, active phrasing.
- If multiple commits might be useful, mention that under **Highlights**, but still emit one Conventional Commit line for the combined diff.
- Do not invent scopes, behaviours, or tests; rely solely on repository evidence.
- Ensure the final output matches the template exactly so it is ready to copy/paste.

---

> **Version**: 1.1.0
> **Last Amended**: 2026-01-17
