---
description: Execute the implementation plan by processing and executing all tasks defined in tasks.md
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Check checklists status** (if FEATURE_DIR/checklists/ exists):

   - Scan all checklist files in the checklists/ directory
   - For each checklist, count:
     - Total items: All lines matching `- [ ]` or `- [X]` or `- [x]`
     - Completed items: Lines matching `- [X]` or `- [x]`
     - Incomplete items: Lines matching `- [ ]`
   - Create a status table:

     ```text
     | Checklist | Total | Completed | Incomplete | Status |
     |-----------|-------|-----------|------------|--------|
     | ux.md     | 12    | 12        | 0          | ✓ PASS |
     | test.md   | 8     | 5         | 3          | ✗ FAIL |
     | security.md | 6   | 6         | 0          | ✓ PASS |
     ```

   - Calculate overall status:

     - **PASS**: All checklists have 0 incomplete items
     - **FAIL**: One or more checklists have incomplete items

   - **If any checklist is incomplete**:

     - Display the table with incomplete item counts
     - **STOP** and ask: "Some checklists are incomplete. Do you want to proceed with implementation anyway? (yes/no)"
     - Wait for user response before continuing
     - If user says "no" or "wait" or "stop", halt execution
     - If user says "yes" or "proceed" or "continue", proceed to step 3

   - **If all checklists are complete**:
     - Display the table showing all checklists passed
     - Automatically proceed to step 3

3. **Documentation Consistency Gate** (run before implementation begins):

   Before loading implementation context, verify the full documentation set is consistent and cohesive.

   **A. Run the documentation review**:

   - Execute `/speckit.documentation.review` against the feature directory
   - This review checks all specification artefacts (spec.md, plan.md, tasks.md, data-model.md, contracts/, checklists/, etc.) for:
     - Ubiquitous language consistency
     - Definition ownership and de-duplication
     - Structural and formatting consistency
     - Cross-document alignment and traceability
     - Identifier completeness

   **B. Evaluate review outcome**:

   - If the review reports **zero issues**: proceed to step 4
   - If the review reports **issues**:
     - Display the findings summary
     - **BLOCK**: Do not proceed to implementation
     - Remediate all issues following the review's recommendations
     - Re-run `/speckit.documentation.review` until the documentation set passes

   **C. Gate criteria**:

   - All ubiquitous language terms must be consistent
   - No duplicated definitions remain
   - All requirement identifiers are present and traceable
   - Cross-document references are valid
   - Only then may implementation context loading (step 4) begin

4. Load and analyse the implementation context:

   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, and file structure
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read quickstart.md for integration scenarios

5. **Project Setup Verification**:

   - **REQUIRED**: Create/verify ignore files based on actual project setup:

   **Detection & Creation Logic**:

   - Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```

   - Check if Dockerfile\* exists or Docker in plan.md → create/verify .dockerignore
   - Check if .eslintrc\* exists → create/verify .eslintignore
   - Check if eslint.config.\* exists → ensure the config's `ignores` entries cover required patterns
   - Check if .prettierrc\* exists → create/verify .prettierignore
   - Check if .npmrc or package.json exists → create/verify .npmignore (if publishing)
   - Check if terraform files (\*.tf) exist → create/verify .terraformignore
   - Check if .helmignore needed (helm charts present) → create/verify .helmignore

   **If ignore file already exists**: Verify it contains essential patterns, append missing critical patterns only
   **If ignore file missing**: Create with full pattern set for detected technology

   **Common Patterns by Technology** (from plan.md tech stack):

   - **Node.js/JavaScript/TypeScript**: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - **Python**: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`
   - **Java**: `target/`, `*.class`, `*.jar`, `.gradle/`, `build/`
   - **C#/.NET**: `bin/`, `obj/`, `*.user`, `*.suo`, `packages/`
   - **Go**: `*.exe`, `*.test`, `vendor/`, `*.out`
   - **Ruby**: `.bundle/`, `log/`, `tmp/`, `*.gem`, `vendor/bundle/`
   - **PHP**: `vendor/`, `*.log`, `*.cache`, `*.env`
   - **Rust**: `target/`, `debug/`, `release/`, `*.rs.bk`, `*.rlib`, `*.prof*`, `.idea/`, `*.log`, `.env*`
   - **Kotlin**: `build/`, `out/`, `.gradle/`, `.idea/`, `*.class`, `*.jar`, `*.iml`, `*.log`, `.env*`
   - **C++**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.so`, `*.a`, `*.exe`, `*.dll`, `.idea/`, `*.log`, `.env*`
   - **C**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.a`, `*.so`, `*.exe`, `Makefile`, `config.log`, `.idea/`, `*.log`, `.env*`
   - **Swift**: `.build/`, `DerivedData/`, `*.swiftpm/`, `Packages/`
   - **R**: `.Rproj.user/`, `.Rhistory`, `.RData`, `.Ruserdata`, `*.Rproj`, `packrat/`, `renv/`
   - **Universal**: `.DS_Store`, `Thumbs.db`, `*.tmp`, `*.swp`, `.vscode/`, `.idea/`

   **Tool-Specific Patterns**:

   - **Docker**: `node_modules/`, `.git/`, `Dockerfile*`, `.dockerignore`, `*.log*`, `.env*`, `coverage/`
   - **ESLint**: `node_modules/`, `dist/`, `build/`, `coverage/`, `*.min.js`
   - **Prettier**: `node_modules/`, `dist/`, `build/`, `coverage/`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - **Terraform**: `.terraform/`, `*.tfstate*`, `*.tfvars`, `.terraform.lock.hcl`
   - **Kubernetes/k8s**: `*.secret.yaml`, `secrets/`, `.kube/`, `kubeconfig*`, `*.key`, `*.crt`

6. Parse tasks.md structure and extract:

   - **Task phases**: Setup, Tests, Core, Integration, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements

7. Execute implementation following the task plan:

   - **Phase-by-phase execution**: Complete each phase before moving to the next
   - **Respect dependencies**: Run sequential tasks in order, parallel tasks [P] can run together
   - **Follow TDD approach**: Execute test tasks before their corresponding implementation tasks
   - **File-based coordination**: Tasks affecting the same files must run sequentially
   - **Validation checkpoints**: Verify each phase completion before proceeding
   - **Instruction enforcement gate**: After completing each phase, run the enforcement cycle (step 8) before advancing

8. **Instruction Enforcement Cycle** (run after each phase):

   After completing a phase, enforce compliance with repository instruction packs before moving to the next phase.

   **A. Detect applicable technologies**:

   - Run `git ls-files` and identify file extensions present in the repository
   - Map extensions to enforcement prompts:
     - `*.py` → `/python-enforce-instructions`
     - `*.ts`, `*.tsx`, `*.js` → `/typescript-enforce-instructions`
     - `Makefile`, `*.mk` → `/makefile-enforce-instructions`
     - `*.tf` → `/terraform-enforce-instructions`
   - Only include prompts for technologies with files touched or created in the current phase

   **B. Run enforcement for each detected technology**:

   - Execute the corresponding `/[tech]-enforce-instructions` prompt
   - Capture all discrepancies and violations reported
   - If discrepancies are found:
     - Display a summary table of violations grouped by instruction identifier
     - **BLOCK**: Do not proceed to the next phase
     - Remediate all discrepancies following the enforcement prompt's guidance
     - Re-run `make lint` and `make test` after each fix batch
     - Repeat enforcement until no discrepancies remain

   **C. Enforcement gate criteria**:

   - All applicable `/[tech]-enforce-instructions` prompts must report zero discrepancies
   - `make lint` and `make test` must pass with zero errors and zero warnings
   - Only then may the next phase begin

   **D. Enforcement summary**:

   - After passing the gate, log which technologies were checked and confirm compliance
   - Record any **Unknown from code** items as follow-ups for the final report

9. Implementation execution rules:

   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests before code**: If you need to write tests for contracts, entities, and integration scenarios
   - **Core development**: Implement models, services, CLI commands, endpoints
   - **Integration work**: Database connections, middleware, logging, external services
   - **Polish and validation**: Unit tests, performance optimisation, documentation

10. Progress tracking and error handling:

- Report progress after each completed task
- Halt execution if any non-parallel task fails
- For parallel tasks [P], continue with successful tasks, report failed ones
- Provide clear error messages with context for debugging
- Suggest next steps if implementation cannot proceed
- **IMPORTANT** For completed tasks, make sure to mark the task off as [X] in the tasks file.

11. Completion validation:

- Verify all required tasks are completed
- Check that implemented features match the original specification
- Validate that tests pass and coverage meets requirements
- Confirm the implementation follows the technical plan
- Report final status with summary of completed work

12. **Code Compliance Review Gate** (run after all phases complete):

    After completing all implementation phases and passing step 11, run the code compliance review to ensure the codebase aligns with the specification.

    **A. Run the code compliance review**:

    - Execute `/speckit.code.review` against the repository
    - This review checks:
      - Constitution compliance (no violations of non-negotiable rules)
      - Specification coverage (all implemented behaviour is covered by the spec)
      - Discrepancy detection (code↔spec↔plan alignment)

    **B. Evaluate review outcome**:

    - If the review reports **zero issues**: proceed to completion summary
    - If the review reports **issues**:
      - Display the findings summary grouped by category (constitution violations, code without spec, spec without code, underspecified requirements)
      - **BLOCK**: Do not mark implementation as complete
      - For each issue, follow the review's proposed resolution:
        - Constitution violations → revise or remove implementation
        - Code without spec → update specification to match implementation (default) or remove code
        - Spec without code → implement missing behaviour or mark as deferred
        - Underspecified requirements → clarify specification with deterministic acceptance criteria
      - Re-run `/speckit.code.review` until no issues remain

    **C. Gate criteria**:

    - No constitution violations
    - All implemented behaviour is covered by the specification
    - Plan/tasks/checklists do not introduce behaviour absent from the specification
    - `make lint` and `make test` pass with zero errors and zero warnings
    - Only then is implementation considered complete

    **D. Compliance summary**:

    - Log the outcome of the code compliance review
    - Record any deferred items as follow-ups for the final report

13. **Test Automation Quality Review Gate** (run after code compliance passes):

    After passing the code compliance review (step 12), run the test automation quality review to ensure the test suite provides behavioural confidence and aligns with the specification.

    **A. Run the test automation quality review**:

    - Execute `/speckit.test.review` against the repository
    - This review checks:
      - Test pyramid health (unit-test majority, minimal E2E)
      - Unit test quality and behavioural confidence
      - High-value test gaps (missing happy paths, error paths, edge cases)
      - Test↔specification alignment (all specified behaviour is tested)
      - Brittle or unclear tests that need refactoring

    **B. Evaluate review outcome**:

    - If the review reports **no high-value gaps and healthy pyramid**: proceed to final completion
    - If the review reports **issues**:
      - Display the findings summary grouped by category (pyramid issues, unit test gaps, refactoring needed, cross-level gaps)
      - **BLOCK**: Do not mark implementation as complete
      - For each issue, follow the review's recommendations:
        - High-value unit test gaps → add missing tests for specified behaviour
        - Brittle/unclear tests → refactor to improve determinism, readability, and speed
        - Pyramid imbalance → shift confidence into unit tests where appropriate
        - Spec↔test misalignment → add tests for specified but untested behaviour
      - Re-run `make lint` and `make test` after each fix batch
      - Re-run `/speckit.test.review` until no high-value issues remain

    **C. Gate criteria**:

    - Test pyramid is healthy (unit-test majority)
    - All high-value unit test gaps are addressed
    - No brittle or non-deterministic tests remain
    - All specified behaviour has corresponding test coverage
    - `make lint` and `make test` pass with zero errors and zero warnings
    - Only then is implementation considered complete

    **D. Test quality summary**:

    - Log the outcome of the test automation quality review
    - Report final test pyramid shape and confidence level
    - Record any deferred low-value improvements as follow-ups

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/speckit.tasks` first to regenerate the task list.
