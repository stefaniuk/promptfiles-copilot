# spec-kit structure

## Development

### Instructions

Drop all the relevant instructions and supporting files to your projects `.github/instructions` directory.

### Prompts

- `/my-documentation-review`
- `/my-code-compliance-review`
- `/my-test-automation-quality-review`

---

## Prompts review

### Review all prompts, provide downloadable files

With spec-kit to support my specification-driven development (SDD), I use custom prompts alongside it. However, I have realised they have the following issues:

- They do not consistently take the spec-kit constitution into account.
- They focus only on the current feature (for example `003`) rather than considering the full specification set across all features (starting from `001`), especially when updating documentation outside the `/specs` directory.

Could you review the constitution and all the prompts and strengthen them to ensure they:

- Treat the constitution as the highest authority and obey all of its requirements.
- Always take into account all specifications across all features (`/specs/*`), not just the latest feature.
- Ensure documentation outside `/specs` reflects the latest implementation changes while also incorporating relevant details from earlier features where they still apply (for completeness and continuity).

Below I include the constitution document and my custom prompts in the following order:

- `constitution`
- `my-documentation-review`
- `my-code-compliance-review`
- `my-test-automation-quality-review`

In your response, provide updated versions of each as separate, downloadable files in raw Markdown format so I can download them, open them in my editor, and copy and paste.

---

## Prompt update commands

- Update the spec-kit constitution document

  ```plaintext
  /speckit.constitution Update the constitution document by inserting the following content exactly as provided. Do not change, rewrite, reorder, summarise, or paraphrase the provided content. Preserve the author's intent and meaning exactly. Content to insert: ...
  ```

- Update my documentation review prompt

  ```plaintext
  /speckit.constitution Update the `.github/prompts/my-documentation-review.prompt.md` prompt by inserting the following content exactly as provided. Do not change, rewrite, reorder, summarise, or paraphrase the provided content. Only update the `[INCLUDE REPOSITORY-SPECIFIC ... HERE]` sections accordingly to the repository context. Preserve the author's intent and meaning exactly. Content to insert: ...
  ```

- Update my code compliance review prompt

  ```plain text
  /speckit.constitution Update the `.github/prompts/my-code-compliance-review.prompt.md` prompt by inserting the following content exactly as provided. Do not change, rewrite, reorder, summarise, or paraphrase the provided content. Only update the `[INCLUDE REPOSITORY-SPECIFIC ... HERE]` sections accordingly to the repository context. Preserve the author's intent and meaning exactly. Content to insert: ...
  ```

- Update my test automation quality review prompt

  ```plain text
  /speckit.constitution Update the `.github/prompts/my-test-automation-quality-review.prompt.md` prompt by inserting the following content exactly as provided. Do not change, rewrite, reorder, summarise, or paraphrase the provided content. Only update the `[INCLUDE REPOSITORY-SPECIFIC ... HERE]` sections accordingly to the repository context. Preserve the author's intent and meaning exactly. Content to insert: ...
  ```

---

## TODO

- new prompts
  - my-diagrams-review.prompt (C4 model diagrams, data flows, infrastructure)
  - architecture-review.prompt (architect for flow)
  - migrate from [tech A] to [tech B]
- new instructions
  - github workflow/actions pipelines
  - docker
  - markdown
- **Add new prompts (spec-kit workflow support)**
  - **Conventional Commits (spec-linked)**
    - Draft commit messages that reference the relevant spec identifiers, include breaking-change notation where required, and keep scope tight to the current feature.
  - **Pull request creation (spec-kit-ready)**
    - Produce a PR description that links to the feature's `spec.md`, summarises changes by identifier, includes test evidence, risk/rollback notes, and a reviewer checklist aligned to the constitution and spec-kit artefacts.
  - **Decision record prompt (ADR creation/update)**
    - Create or update an ADR linked from the spec section that motivated the decision; include alternatives and consequences; keep it automation-friendly (consistent headings, stable filenames).
  - **Release notes prompt (identifier-driven)**
    - Generate release notes/changelog entries grouped by spec identifiers and feature folder, highlighting behaviour changes and any backwards-incompatible changes.
