You **MUST** adhere to the following mandatory requirements when generating development tasks.

**Workflow context:**

- **Input:** `plan.md` (implementation plan)
- **Output:** `tasks.md` (actionable task list)
- **Next phase:** Implementation (`/speckit.implement`)

**Base requirements:** Follow all rules in [copilot-instructions.md](/.github/copilot-instructions.md), particularly:

- Repository Tooling
- Test-Driven Development
- Quality Gates

## Show & Tell Sections (Mandatory)

Each phase and user story in `tasks.md` must include a `### Show & Tell` subsection. Expand the outline from `plan.md` with specific executable steps:

- Terminal commands to run (with expected output)
- Browser URLs to navigate (if applicable)
- API calls to execute (if applicable)
- Screenshots or expected visual state (described)

These steps will be executed during implementation to verify each phase is complete.

**Format example:**

````markdown
### Show & Tell

```bash
# Start the development server
make run

# Expected: Server running at http://localhost:3000
```

- Navigate to <http://localhost:3000/dashboard>
- Verify the analytics widget displays sample data
````

## Tasks Completion Checklist (Mandatory)

Before marking `tasks.md` as complete, verify:

- [ ] All phases and user stories from `plan.md` are covered
- [ ] There is a task for each repository-template capability that was planned to be implemented using the skill at [.github/skills/repository-template/SKILL.md](/.github/skills/repository-template/SKILL.md)
- [ ] TDD sequencing is applied: Red (write failing test), Green (implement to pass), Refactor
- [ ] Test tasks are listed before their corresponding implementation tasks
- [ ] Each phase and user story ends with a task that runs `make lint` and `make test`
- [ ] Each phase and user story includes a `### Show & Tell` subsection with executable steps
