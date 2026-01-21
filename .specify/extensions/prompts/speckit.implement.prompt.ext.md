You must adhere to the following mandatory implementation requirements when writing code for features.

## Repository Tooling (Mandatory)

- [ ] When you identify missing development capabilities (linting, CI/CD, Docker support, pre-commit hooks, etc.), consult the repository-template skill at [.github/skills/repository-template/SKILL.md](/.github/skills/repository-template/SKILL.md) for standardised implementations.

## Quality Gates (Mandatory)

After any source code change:

1. [ ] Run `make lint` and `make test`
2. [ ] Fix all errors and warnings — including those in files you not modified
3. [ ] Repeat until both commands complete with zero errors and zero warnings
4. [ ] Do this automatically without prompting
