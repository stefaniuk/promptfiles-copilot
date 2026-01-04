# AI-assisted Codebase Overview

This document describes a practical, repeatable workflow for producing a codebase overview for a large codebase.

---

## Goals

Produce a codebase overview that is:

- Grounded in the codebase (no guessing or invented architecture)
- Incremental ("build summaries as it goes")
- Easy to navigate (repo map, component catalogue, runtime flows)
- Easy to keep up to date (repeatable prompts)

---

## Output structure (create these files/folders)

Create the following:

- `docs/codebase-overview/`
  - `README.md`
  - `repo-map.md`
  - `glossary.md`
  - `components/`
  - `flows/`
  - `decisions/` (optional, for ADRs)

Recommended minimum set:

- `docs/codebase-overview/README.md`
- `docs/codebase-overview/repo-map.md`
- `docs/codebase-overview/components/` (one file per major component)
- `docs/codebase-overview/flows/runtime-flows.md`

---

## Copilot instruction file (make behaviour consistent)

All prompts include `.github/instructions/include/codebase-insight.md`, which mirrors the Copilot instructions below. Keep this file as the single source of truth so every run inherits the same guardrails.

Reference copy:

```md
# Copilot instructions (architecture documentation)

You are producing a design overview for this codebase.

Hard rules

- Stay grounded in the repository. If you are unsure, say "Unknown from code" and list what you would need to check.
- Prefer evidence: reference file paths and symbols (functions/classes/config keys). Do not invent components.
- Work iteratively: write/update Markdown files under docs/codebase-overview/ as you learn more.
- Keep language simple and use British English.
- Avoid reading huge files end-to-end. Use workspace search to find entry points, then read only relevant sections.
- Exclude generated/vendor folders (e.g. node_modules, dist, build, coverage, .venv, vendor).
- Every time you add a claim to the architecture docs, include at least one "Evidence" bullet pointing to code locations.

Output style

- Use headings, short paragraphs, and bullet lists.
- Where helpful, use Mermaid diagrams in Markdown.

Process

- Always run the architecture prompts sequentially: `01-repo-map`, `02-component-catalogue`, `03-runtime-flows`.
- After each prompt run, review the generated Markdown under `docs/codebase-overview/` and iterate rather than starting from scratch.
- Keep `README.md` as the canonical landing page; link every new component or flow document from it.
- Capture uncertainties explicitly in an **Unknowns / to verify** section so follow-up passes know what to investigate next.
```

---

## Prompt files (repeatable passes)

Prompt files live under `.github/prompts/` and already import the `codebase-insight` instructions. Run them in order and iterate on the generated docs/architecture artefacts.

### 1) Repo map prompt

File: `.github/prompts/01-repo-map.prompt.md`

Purpose: orchestrates creation of `docs/codebase-overview/repo-map.md`, capturing folder structure, entry points, build/deploy artefacts, and dependencies with **Evidence** bullets.

### 2) Component catalogue prompt

File: `.github/prompts/02-component-catalogue.prompt.md`

Purpose: creates one Markdown file per major component under `docs/codebase-overview/components/`, updates `README.md` with a catalogue, and enforces evidence-backed descriptions of responsibilities, interfaces, data, config, and observability.

### 3) Runtime flows prompt

File: `.github/prompts/03-runtime-flows.prompt.md`

Purpose: documents 3–6 critical flows inside `docs/codebase-overview/flows/runtime-flows.md`, including narratives, Mermaid sequence diagrams, error-handling notes, and evidence references; also reminds authors to flag unknowns explicitly.

---

## How to run in VS Code

1. Open **Copilot Chat**.
2. Switch to **Agent** mode (so it can search the workspace and write files).
3. Select **GPT-5.1-Codex** in the model picker.
4. Run the prompt files in this order:
   - `01-repo-map`
   - `02-component-catalogue`
   - `03-runtime-flows`

Expected working pattern:

- Search the workspace for entry points and key modules
- Read only the relevant sections of code/config
- Write/update Markdown under `docs/codebase-overview/`
- Repeat until each artefact is solid

---

## Quality controls (prevents "architecture fiction")

Apply these checks as you go:

- Evidence-first rule
  No architecture claim without an "Evidence" bullet that points to file paths and symbols/config keys.

- Unknowns list
  Keep a section in `docs/codebase-overview/README.md` called **Unknowns / to verify**.

- Scope boundaries
  Each component document should state what it _does_ and what it _does not_ own.

- Assumption audit
  After each pass, ask the agent:

  - "List the top 20 assumptions you made. For each, provide evidence or mark ‘Unknown from code’."

- Ignore noise
  Ensure vendor and generated artefacts are excluded (e.g. `node_modules`, `dist`, `.venv`, `build`, `coverage`).

---

## Suggested outline for README.md

After the component pass, ensure `docs/codebase-overview/README.md` contains:

- Purpose of the system
- High-level architecture (short summary)
- Component catalogue (links to `components/*.md`)
- Key interfaces (HTTP, messaging, scheduled jobs)
- Data storage overview
- Deployment and runtime (how it runs in environments)
- Observability (logs/metrics/traces)
- Security and access (authn/authz, secrets, boundaries)
- Operational concerns (scaling, failure modes, DR)
- Unknowns / to verify
- Glossary link

---

## Optional next passes

Once the basics are in place, add one or more of these:

- C4-style diagrams (Context / Container / Component) using Mermaid
- ADRs for key decisions (write into `docs/codebase-overview/adr/`)
- Threat model sketch (trust boundaries + key risks)
- Tech debt register (grounded in issues and code hotspots)

---

## Done criteria

You are "done" when:

- `repo-map.md` lets a new engineer find the main moving parts quickly
- Each component file clearly explains responsibilities and interfaces with evidence
- `runtime-flows.md` covers the most important flows and failure cases
- `README.md` reads coherently end-to-end and links to everything
- Unknowns are explicitly listed, not guessed
