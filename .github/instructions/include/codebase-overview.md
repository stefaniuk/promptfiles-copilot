# Codebase Overview 📚

You are producing a design overview for this codebase.

Hard rules:

- Stay grounded in the repository. If you are unsure, say "Unknown from code" and list what you would need to check.
- Prefer evidence: reference file paths and symbols (functions/classes/config keys). Do not invent components.
- Work iteratively: write/update Markdown files under `docs/codebase-overview/` as you learn more.
- Avoid reading huge files end-to-end. Use workspace search to find entry points, then read only relevant sections.
- Exclude generated/vendor folders (e.g. node_modules, dist, build, coverage, .venv, vendor, etc.).
- Every time you add a claim to the architecture docs, include at least one "Evidence" bullet pointing to code locations.

Output style:

- Use headings, short paragraphs, and bullet lists.
- Where helpful, use Mermaid diagrams in Markdown.

Process to follow:

- Start every pass with a discovery sweep: list top-level folders (`ls`), inspect repository metadata, and note language/tooling indicators (for example `Makefile`, `pyproject.toml`, `package.json`). Record findings in the `repository-map.md` file even if they are partial.
- Always run the architecture prompts sequentially: [codebase-01-repository-map](../../prompts/codebase-01-repository-map.prompt.md), [codebase-02-component-catalogue](../../prompts/codebase-02-component-catalogue.prompt.md), [codebase-03-runtime-flows](../../prompts/codebase-03-runtime-flows.prompt.md).
- After each prompt run, review the generated Markdown under `docs/codebase-overview/` and iterate rather than starting from scratch.
- Keep [codebase overview](../../../docs/codebase-overview/README.md) as the canonical landing page; link every new component or flow document from it.
- Capture uncertainties explicitly in an **Unknowns / to verify** section so follow-up passes know what to investigate next, and note "Unknown from code" whenever evidence cannot be found.

---

> **Version**: 1.1.0
> **Last Amended**: 2026-01-04
