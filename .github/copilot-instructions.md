# Copilot Instructions ✨

## Communication Style Guide (Mandatory)

- [ ] Use British English
- [ ] Keep language simple

## Non-negotiable Rules (Mandatory)

- [ ] Read and adhere to the [constitution](../.specify/memory/constitution.md) at all times

## Quality Gates (Mandatory)

After any source code change:

1. [ ] Run `make lint` and `make test`
2. [ ] Fix all errors and warnings — including those in files you not modified
3. [ ] Repeat until both commands complete with zero errors and zero warnings
4. [ ] Do this automatically without prompting

## Documentation (Mandatory)

When making architectural or significant technical decisions, document them as Architecture Decision Records (ADRs):

**What requires an ADR:**

- [ ] Architectural style choices (e.g. event-driven vs layered, monolith vs microservices)
- [ ] Architectural pattern choices (e.g. composition over inheritance, repository pattern, event sourcing)
- [ ] Language and framework selections
- [ ] Any other significant technical decision that shapes the system

**ADR requirements:**

- [ ] Use the template at [docs/adr/adr-template.md](../docs/adr/adr-template.md)
- [ ] Follow the existing ADR format for consistency
- [ ] Always present 3 or more options with trade-offs
- [ ] Include the conversational context that led to the decision
- [ ] Document decisions regardless of whether you made them independently or were guided by the user

This requirement is mandatory, especially during the spec-driven development cycle: `spec` → `plan` → `tasks` → `implement`.

## Repository Tooling (Recommended)

When you identify missing development capabilities (linting, CI/CD, Docker support, pre-commit hooks, etc.), consult the repository-template skill at [.github/skills/repository-template/SKILL.md](skills/repository-template/SKILL.md) for standardised implementations.

---

> **Version**: 1.4.0
> **Last Amended**: 2026-01-20
