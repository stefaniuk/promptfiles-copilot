# Codebase Overview 📚

You are producing a design overview for this codebase.

## Scope

- Produce and maintain Markdown documents under `docs/codebase-overview/`.
- Treat the repository as the only authoritative source.

## Hard rules

- Do not guess: if evidence is missing, write **Unknown from code – {action}**.
- Do not invent components, services, flows, or dependencies.
- Do not rely on documentation claims unless confirmed by code or config.
- Do not quote or summarise code you have not opened in the workspace.

## Evidence rules

- Every major statement must include an **Evidence** bullet.
- Evidence must reference a concrete artefact: file path + symbol and/or config key.
- Evidence links must use an absolute repo path (prefix with `/`) so links resolve.
- Prefer "composition roots" as evidence (router registration, DI wiring, consumer registration, scheduler wiring).
- If you cannot find an artefact, record **Unknown from code – {what to search/confirm next}**.

## Exclusions

- Exclude generated/vendor directories from analysis unless directly referenced by build tooling.
- Do not treat `dist/`, `build/`, `coverage/`, `.venv/`, `node_modules/`, `vendor/` as architectural sources.
- Avoid reading large files end-to-end; locate relevant sections via workspace search first.

## Writing style

- Use headings and short paragraphs.
- Prefer bullet lists over long prose.
- Keep statements specific (names, routes, topics, schedules, config keys).
- Use Mermaid diagrams where they clarify interactions.
- Include a **Last Amended** footer in every file you produce, using this format:

```plaintext
---

> **Last Amended**: YYYY-MM-DD
```

## Working method

### Start of any pass (discovery sweep)

- List top-level directories (e.g. `ls`) and identify likely source roots.
- Identify language/tooling indicators (`Makefile`, `pyproject.toml`, `package.json`, `go.mod`, etc.).
- Identify CI/deploy indicators (`.github/workflows/`, `Dockerfile`, Helm, Kubernetes, Terraform).
- Record any new findings in `docs/codebase-overview/repository-map.md` (even if partial).

### Prompt execution order

- Run prompts in this order:
  - [codebase-01-repository-map](../../prompts/codebase-01-repository-map.prompt.md)
  - [codebase-02-component-catalogue](../../prompts/codebase-02-component-catalogue.prompt.md)
  - [codebase-03-runtime-flows](../../prompts/codebase-03-runtime-flows.prompt.md)
  - [codebase-04-domain-analysis](../../prompts/codebase-04-domain-analysis.prompt.md)
  - [codebase-05-c4-structurizr](../../prompts/codebase-05-c4-structurizr.prompt.md)

### Iteration rules

- Update existing documents; do not restart from scratch.
- Replace vague statements with evidenced specifics on each iteration.
- Convert "Unknown from code" items into evidenced statements when you find proof.

## Indexing and navigation

- Treat `docs/codebase-overview/README.md` as the canonical landing page.
- Link every `component-*.md` document from the README.
- Link every `runtime-flow-*.md` document from the README.
- Maintain an **Unknowns / to verify** section in the README for follow-up work.

---

> **Version**: 1.2.8
> **Last Amended**: 2026-01-05
