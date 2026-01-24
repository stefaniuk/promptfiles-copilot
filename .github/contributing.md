# Contributing to Prompt Files

Thank you for your interest in contributing to this prompt library! This guide will help you understand how to add, improve, or extend prompts, instructions, agents, and skills.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Ways to Contribute](#ways-to-contribute)
- [Getting Started](#getting-started)
- [Artefact Types](#artefact-types)
- [Writing Guidelines](#writing-guidelines)
- [Quality Standards](#quality-standards)
- [Pull Request Process](#pull-request-process)
- [Style Guide](#style-guide)

---

<a id="code-of-conduct"></a>

## 🤝 Code of Conduct

- Be respectful and constructive in all interactions
- Focus on the work, not the person
- Welcome newcomers and help them get started
- Share knowledge openly

---

<a id="ways-to-contribute"></a>

## 💡 Ways to Contribute

| Contribution Type    | Description                                          |
| :------------------- | :--------------------------------------------------- |
| 🐛 **Bug fixes**     | Fix errors in existing prompts or instructions       |
| ✨ **New prompts**   | Add prompts for new workflows or tools               |
| 📋 **Instructions**  | Create coding standards for new languages/frameworks |
| 🤖 **Agents**        | Build new Copilot agents for specific tasks          |
| 🧠 **Skills**        | Package complex capabilities with supporting assets  |
| 📖 **Documentation** | Improve README, examples, or inline comments         |
| 🧪 **Testing**       | Validate prompts work as expected                    |

---

<a id="getting-started"></a>

## 🚀 Getting Started

### Prerequisites

- Git
- Make (for running quality gates)
- A text editor (VS Code recommended for Copilot integration)

### Setup

```bash
# Clone the repository
git clone https://github.com/stefaniuk/promptfiles.git
cd promptfiles

# Verify quality gates work
make lint && make test
```

### Repository Structure

```text
.github/
├── agents/           # Copilot agent definitions
├── instructions/     # Coding standards by language/framework
│   ├── includes/     # Shared instruction fragments
│   └── templates/    # Instruction templates
├── prompts/          # Task-specific prompts
├── skills/           # Bundled capabilities with assets
└── copilot-instructions.md  # Global Copilot instructions

.specify/
├── memory/           # Project constitution and context
└── templates/        # Spec, plan, and task templates

docs/
└── adr/              # Architecture decision records
```

---

<a id="artefact-types"></a>

## 📦 Artefact Types

### Prompts (`.github/prompts/*.prompt.md`)

Single-purpose prompt files that guide Copilot through specific tasks.

**When to create a prompt:**

- Repeatable workflow (code review, documentation, refactoring)
- Task requiring specific structure or format
- Process with defined steps or checklist

**File naming:** `<prefix>.<category-or-action>.prompt.md` (prefix + category + verb)

Examples: `speckit.plan.prompt.md`, `codebase.01-repository-map.prompt.md`, `review.speckit-code.prompt.md`, `util.gh-pr.prompt.md`, `enforce.python.prompt.md`

### Instructions (`.github/instructions/*.instructions.md`)

Coding standards and best practices scoped to specific file types.

**When to create instructions:**

- New programming language support
- Framework-specific conventions (React, Django, Terraform)
- Tool-specific rules (Docker, Makefile)

**File naming:** `<technology>.instructions.md`

Examples: `python.instructions.md`, `terraform.instructions.md`

**Required frontmatter:**

```yaml
---
applyTo: "**/*.py" # Glob pattern for file matching
---
```

### Agents (`.github/agents/*.md`)

Copilot agent definitions that combine prompts with specific behaviours.

**When to create an agent:**

- Complex multi-step workflow
- Specialised domain expertise
- Workflow requiring specific agent configuration

**File naming:** `<namespace>.<action>.agent.md`

Examples: `speckit.specify.agent.md`, `speckit.implement.agent.md`

### Skills (`.github/skills/<skill-name>/`)

Bundled capabilities with supporting assets (templates, examples, data).

**When to create a skill:**

- Capability requiring supporting files
- Complex domain needing examples or templates
- Workflow with reusable assets

**Structure:**

```text
.github/skills/<skill-name>/
├── SKILL.md           # Main skill definition
├── templates/         # Supporting templates
└── examples/          # Usage examples
```

---

<a id="writing-guidelines"></a>

## ✍️ Writing Guidelines

### For Prompts

1. **Start with context** — explain what the prompt does and when to use it
2. **Be specific** — vague instructions produce vague results
3. **Include examples** — show expected inputs and outputs
4. **Define success criteria** — what does "done" look like?
5. **Handle edge cases** — what should happen with invalid input?

### For Instructions

1. **Use unique identifiers** — every rule gets a tag like `[PY-QR-001]`
2. **Group logically** — organise by concern (quality, security, testing)
3. **Explain why** — rationale helps AI and humans apply rules correctly
4. **Link to constitution** — reference relevant sections
5. **Provide quick reference** — summarise critical rules at the top

### Identifier Format

```text
[<LANG>-<SECTION>-<NUMBER>]

Examples:
[PY-QR-001]   Python, Quick Reference, rule 1
[TS-SEC-003]  TypeScript, Security, rule 3
[TF-BEH-010]  Terraform, Behaviour, rule 10
```

### For Agents

1. **Single responsibility** — one agent, one job
2. **Clear activation** — explain how to invoke the agent
3. **Define scope** — what the agent will and won't do
4. **Specify outputs** — what artefacts the agent produces

---

<a id="quality-standards"></a>

## ✅ Quality Standards

### Before Submitting

All contributions must pass quality gates:

```bash
make lint && make test
```

### Content Checklist

- [ ] **British English** — colour, behaviour, organisation (not color, behavior, organization)
- [ ] **Simple language** — avoid jargon where possible
- [ ] **Consistent formatting** — follow existing patterns
- [ ] **No sensitive data** — no credentials, tokens, or personal information
- [ ] **Tested** — verify prompts produce expected results
- [ ] **Documented** — include usage examples

### Identifier Requirements

For instructions files:

- [ ] Every normative rule has a unique identifier
- [ ] Identifiers follow the `[XX-YYY-NNN]` format
- [ ] No duplicate identifiers within or across files
- [ ] Identifiers are referenced in quick reference section

---

<a id="pull-request-process"></a>

## 🔄 Pull Request Process

### 1. Create an Issue (Optional but Recommended)

For significant changes, open an issue first to discuss:

- What problem does this solve?
- What's the proposed approach?
- Are there alternatives considered?

### 2. Branch Naming

```text
<type>/<short-description>

Examples:
feat/rust-instructions
fix/python-typing-rules
docs/contributing-guide
```

### 3. Commit Messages

Follow conventional commits:

```text
<type>(<scope>): <description>

Types: feat, fix, docs, style, refactor, test, chore

Examples:
feat(instructions): add Rust coding standards
fix(prompts): correct review.speckit-code checklist
docs(readme): update quick start section
```

### 4. PR Description

Include:

- **What** — summary of changes
- **Why** — motivation and context
- **How** — implementation approach
- **Testing** — how you verified the changes work

### 5. Review Process

1. Automated checks must pass (`make lint && make test`)
2. At least one maintainer review required
3. Address feedback promptly
4. Squash commits before merge (if requested)

---

<a id="style-guide"></a>

## 🎨 Style Guide

### Markdown

- Use ATX-style headers (`#`, `##`, `###`)
- One sentence per line (for better diffs)
- Blank line before and after code blocks
- Use fenced code blocks with language hints

### Code Examples

- Use realistic, self-contained examples
- Include comments explaining non-obvious parts
- Show both correct and incorrect patterns where helpful

### Tables

```markdown
| Column A | Column B |
| :------- | :------- |
| Value 1  | Value 2  |
```

### Lists

- Use `-` for unordered lists
- Use `1.` for ordered lists (let Markdown handle numbering)
- Indent nested items with 2 spaces

---

## 🙋 Questions?

- Check existing issues and PRs for similar topics
- Open an issue for questions about contributing
- Tag maintainers if you need guidance

---

**Thank you for helping make AI-assisted development better for everyone!**
