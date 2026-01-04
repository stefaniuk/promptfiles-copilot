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

All prompts include `.github/instructions/include/codebase-overview.md`. Keep this file as the single source of truth so every run inherits the same guardrails.

Reference copy:

```md
# Copilot instructions (architecture documentation)

You are producing a design overview for this codebase.

Hard rules

- Stay grounded in the repository. If you are unsure, say "Unknown from code" and list what you would need to check.
- Prefer evidence: reference file paths and symbols (functions/classes/config keys). Do not invent components.
- Work iteratively: write/update Markdown files under `docs/codebase-overview/` as you learn more.
- Keep language simple and use British English.
- Avoid reading huge files end-to-end. Use workspace search to find entry points, then read only relevant sections.
- Exclude generated/vendor folders (e.g. node_modules, dist, build, coverage, .venv, vendor).
- Every time you add a claim to the architecture docs, include at least one "Evidence" bullet pointing to code locations.

Output style

- Use headings, short paragraphs, and bullet lists.
- Where helpful, use Mermaid diagrams in Markdown.

Process

- Start each pass with a discovery sweep: list top-level folders, skim README/contributing docs, and note manifest/technology indicators (for example `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `build.gradle`, `Makefile`).
- Always run the architecture prompts sequentially: `01-repo-map`, `02-component-catalogue`, `03-runtime-flows`.
- After each prompt run, review the generated Markdown under `docs/codebase-overview/` and iterate rather than starting from scratch.
- Keep `README.md` as the canonical landing page; link every new component or flow document from it.
- Capture uncertainties explicitly in an **Unknowns / to verify** section so follow-up passes know what to investigate next, and record follow-up actions alongside each unknown.
```

---

## Prompt files (repeatable passes)

Prompt files live under `.github/prompts/` and already pull in the `codebase-overview` instructions. Run them in order and iterate on the generated docs/codebase-overview artefacts.

### 1) Repo map prompt

File: `.github/prompts/codebase-01-repository-map.prompt.md`

Purpose: orchestrates creation of `docs/codebase-overview/repo-map.md`, starting with a discovery sweep before capturing folder structure, entry points, build/deploy artefacts, dependencies, and explicit **Evidence** / **Unknown from code** bullets using the provided template.

### 2) Component catalogue prompt

File: `.github/prompts/codebase-02-component-catalogue.prompt.md`

Purpose: creates one Markdown file per major component under `docs/codebase-overview/components/`, using discovery heuristics to select components, enforcing the component template (purpose, interfaces, data, observability), and requiring evidence or `Unknown from code` for every subsection before updating `README.md`.

### 3) Runtime flows prompt

File: `.github/prompts/codebase-03-runtime-flows.prompt.md`

Purpose: documents 3–6 critical flows inside `docs/codebase-overview/flows/runtime-flows.md`, beginning with a discovery scan of orchestrators/jobs, then applying the runtime-flow template (narrative, Mermaid diagram, error handling, evidence/unknowns) before linking the flows from `README.md`.

---

## How to run in VS Code

1. Open **Copilot Chat**.
2. Switch to **Agent** mode (so it can search the workspace and write files).
3. Select **GPT-5.1-Codex** in the model picker.
4. Run the prompt files in this order:

- `codebase-01-repository-map`
- `codebase-02-component-catalogue`
- `codebase-03-runtime-flows`

Expected working pattern:

- Search the workspace for entry points and key modules (use `Cmd+Shift+F`, `rg`, `fd`, or `ls` rather than opening huge files blindly)
- Read only the relevant sections of code/config
- Write/update Markdown under `docs/codebase-overview/`
- Repeat until each artefact is solid

**Tip:** filter out generated/vendor directories (for example add `--glob "!node_modules"` when using ripgrep) to stay focused on authoritative code.

---

## Quality controls (prevents "architecture fiction")

Apply these checks as you go:

- Evidence-first rule
  No architecture claim without an "Evidence" bullet that points to file paths and symbols/config keys. If evidence is missing, explicitly record `Unknown from code — <follow-up>`.

- Unknowns list
  Keep a section in `docs/codebase-overview/README.md` called **Unknowns / to verify**, and echo unresolved unknowns inside every component/flow file so gaps stay localised.

- Scope boundaries
  Each component document should state what it _does_ and what it _does not_ own.

- Assumption audit
  After each pass, ask the agent:

  - "List the top 20 assumptions you made. For each, provide evidence or mark ‘Unknown from code’."

- Ignore noise
  Ensure vendor and generated artefacts are excluded (e.g. `node_modules`, `dist`, `.venv`, `build`, `coverage`).

- README verification
  Before finishing a pass, ensure `README.md` links to the latest repo map, every component file, and every runtime-flow file, and that it summarises key findings plus open unknowns.

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

- `repo-map.md` lets a new engineer find the main moving parts quickly and records unknowns + follow-ups
- Each component file clearly explains responsibilities and interfaces with evidence
- `runtime-flows.md` covers the most important flows and failure cases, each with diagrams and evidence
- `README.md` reads coherently end-to-end, links to every generated artefact, and highlights open questions
- Unknowns are explicitly listed with owners or next steps

### Final verification checklist

- [ ] `docs/codebase-overview/repo-map.md` includes discovery findings, entry points, build/deploy assets, dependencies, and evidence/unknown bullets.
- [ ] Every component file follows the template and is referenced from `README.md`.
- [ ] `docs/codebase-overview/flows/runtime-flows.md` (or individual flow files) contain narratives, Mermaid diagrams, error-handling notes, and evidence.
- [ ] `README.md` links to repo map, all components, all flows, glossary, and includes an **Unknowns / to verify** section.
- [ ] Outstanding unknowns have explicit follow-up notes so the next pass knows what to inspect.
