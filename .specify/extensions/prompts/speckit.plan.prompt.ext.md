You must adhere to the following mandatory planning requirements when creating a development plan.

## Documentation (Mandatory)

When making architectural or significant technical decisions, document them as Architecture Decision Records (ADRs):

**What requires an ADR:**

- [ ] Architectural style choices (e.g. event-driven vs layered, monolith vs microservices)
- [ ] Architectural pattern choices (e.g. composition over inheritance, repository pattern, event sourcing)
- [ ] Language and framework selections
- [ ] Any other significant technical decision that shapes the system

**ADR requirements:**

- [ ] Use the template at [docs/adr/adr-template.md](/docs/adr/adr-template.md)
- [ ] Follow the existing ADR format for consistency
- [ ] Always present 3 or more options with trade-offs
- [ ] Include the conversational context that led to the decision
- [ ] Document decisions regardless of whether you made them independently or were guided by the user

This requirement is mandatory, especially during the spec-driven development cycle: `spec` → `plan` → `tasks` → `implement`.

## Toolchain Version (Mandatory)

- [ ] Use the latest stable language, runtime, and framework versions at the time of change, search the internet for the latest versions

## Plan (Mandatory)

- [ ] Plan each phase and user story to include a Show & Tell section with all instructions needed to demonstrate the completed work to stakeholders (e.g. terminal commands, browser navigation, API calls)
- [ ] Plan to always bring the below capabilities as the minimum using the repository-template skill at [.github/skills/repository-template/SKILL.md](/.github/skills/repository-template/SKILL.md), and ensure they are up to date:
  - [ ] Core Make System
  - [ ] Pre-commit Hooks
  - [ ] Secret Scanning
  - [ ] File Format Checking
  - [ ] Markdown Linting
  - [ ] Docker Support
  - [ ] Tool Version Management
