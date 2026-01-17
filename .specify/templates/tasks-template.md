---
description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: The examples below include test tasks. Tests are OPTIONAL - only include them if explicitly requested in the feature specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

<!--
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.

  The /speckit.tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/

  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment

  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 0: Governance & Documentation Gates

**Purpose**: Validate prerequisites, checklist completion, and documentation consistency before touching implementation artefacts.

- [ ] T000 Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` to capture FEATURE_DIR and AVAILABLE_DOCS
- [ ] T001 Audit all files under `specs/[###-feature-name]/checklists/` and block if any `- [ ]` items remain
- [ ] T002 Run `/review.speckit-documentation` for `specs/[###-feature-name]/` and resolve all findings before proceeding

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T003 Create project structure per implementation plan
- [ ] T004 Initialize [language] project with [framework] dependencies
- [ ] T005 [P] Configure linting and formatting tools
- [ ] T006 Run instruction enforcement cycle for Setup outputs (execute `/[tech]-enforce-instructions`, then `make lint && make test`)

### Demo Instructions (show Setup running)

- **Commands**:

  ```bash
  [List the exact CLI/API commands that prove the setup slice works]
  ```

- **Navigation**: `[Where to look in the UI/logs to confirm Setup is complete]`
- **Expected outcome**: `[What success looks like for this phase]`
- **Show & Tell cue**: `[Talking points stakeholders should cover while demoing Setup]`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T007 Setup database schema and migrations framework
- [ ] T008 [P] Implement authentication/authorization framework
- [ ] T009 [P] Setup API routing and middleware structure
- [ ] T010 Create base models/entities that all stories depend on
- [ ] T011 Configure error handling and logging infrastructure
- [ ] T012 Setup environment configuration management
- [ ] T013 Run instruction enforcement cycle for Foundational outputs (execute `/[tech]-enforce-instructions`, then `make lint && make test`)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

### Demo Instructions (show Foundational slice running)

- **Commands**:

  ```bash
  [Exact commands or test suites that demonstrate the foundational capabilities]
  ```

- **Navigation**: `[Dashboards, health checks, or admin screens to view]`
- **Expected outcome**: `[Observable impact confirming readiness for user stories]`
- **Show & Tell cue**: `[Narrative to explain why the foundation unlocks later slices]`

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 (OPTIONAL - only if tests requested) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T014 [P] [US1] Contract test for [endpoint] in tests/contract/test\_[name].py
- [ ] T015 [P] [US1] Integration test for [user journey] in tests/integration/test\_[name].py

### Implementation for User Story 1

- [ ] T016 [P] [US1] Create [Entity1] model in src/models/[entity1].py
- [ ] T017 [P] [US1] Create [Entity2] model in src/models/[entity2].py
- [ ] T018 [US1] Implement [Service] in src/services/[service].py (depends on T016, T017)
- [ ] T019 [US1] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] T020 [US1] Add validation and error handling
- [ ] T021 [US1] Add logging for user story 1 operations
- [ ] T022 [US1] Run instruction enforcement cycle for User Story 1 outputs (execute `/[tech]-enforce-instructions`, then `make lint && make test`)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

### Demo Instructions (show User Story 1 running)

- **Commands**:

  ```bash
  [CLI/API sequence demonstrating the story end to end]
  ```

- **Navigation**: `[Exact UI flow, route, or dashboard to walk through]`
- **Expected outcome**: `[User-facing result to verify]`
- **Show & Tell cue**: `[Key story beats to highlight during the session]`

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 (OPTIONAL - only if tests requested) ⚠️

- [ ] T023 [P] [US2] Contract test for [endpoint] in tests/contract/test\_[name].py
- [ ] T024 [P] [US2] Integration test for [user journey] in tests/integration/test\_[name].py

### Implementation for User Story 2

- [ ] T025 [P] [US2] Create [Entity] model in src/models/[entity].py
- [ ] T026 [US2] Implement [Service] in src/services/[service].py
- [ ] T027 [US2] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] T028 [US2] Integrate with User Story 1 components (if needed)
- [ ] T029 [US2] Run instruction enforcement cycle for User Story 2 outputs (execute `/[tech]-enforce-instructions`, then `make lint && make test`)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

### Demo Instructions (show User Story 2 running)

- **Commands**:

  ```bash
  [CLI/API sequence demonstrating story 2]
  ```

- **Navigation**: `[Exact UI flow, route, or dashboard to walk through]`
- **Expected outcome**: `[User-facing result to verify]`
- **Show & Tell cue**: `[Key differentiators to emphasise to stakeholders]`

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 (OPTIONAL - only if tests requested) ⚠️

- [ ] T030 [P] [US3] Contract test for [endpoint] in tests/contract/test\_[name].py
- [ ] T031 [P] [US3] Integration test for [user journey] in tests/integration/test\_[name].py

### Implementation for User Story 3

- [ ] T032 [P] [US3] Create [Entity] model in src/models/[entity].py
- [ ] T033 [US3] Implement [Service] in src/services/[service].py
- [ ] T034 [US3] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] T035 [US3] Run instruction enforcement cycle for User Story 3 outputs (execute `/[tech]-enforce-instructions`, then `make lint && make test`)

**Checkpoint**: All user stories should now be independently functional

### Demo Instructions (show User Story 3 running)

- **Commands**:

  ```bash
  [CLI/API sequence demonstrating story 3]
  ```

- **Navigation**: `[Exact UI flow, route, or dashboard to walk through]`
- **Expected outcome**: `[User-facing result to verify]`
- **Show & Tell cue**: `[Narrative for demonstrating this slice end-to-end]`

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Additional unit tests (if requested) in tests/unit/
- [ ] TXXX Security hardening
- [ ] TXXX Run quickstart.md validation
- [ ] TXXX Run instruction enforcement cycle for Polish deliverables (execute `/[tech]-enforce-instructions`, then `make lint && make test`)

### Demo Instructions (show Polish improvements running)

- **Commands**:

  ```bash
  [Commands/tests that highlight cross-cutting refinements]
  ```

- **Navigation**: `[Dashboards or UI areas where improvements appear]`
- **Expected outcome**: `[Signals proving the polish work is live]`
- **Show & Tell cue**: `[Summary talking points to wrap up the showcase]`

---

## Final Quality Gates

**Purpose**: Block completion until the codebase aligns with the specification and the automated test suite provides sufficient confidence.

- [ ] T036 Run `/review.speckit-code` for `specs/[###-feature-name]/` and resolve every finding before proceeding (rerun `make lint && make test` afterward)
- [ ] T037 Run `/review.speckit-test`, close high-value gaps, rebalance the test pyramid if required, and rerun `make lint && make test`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Governance (Phase 0)**: Must complete before touching source files
- **Setup (Phase 1)**: No dependencies - can start immediately (after Phase 0 gates pass)
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (if tests requested):
Task: "Contract test for [endpoint] in tests/contract/test_[name].py"
Task: "Integration test for [user journey] in tests/integration/test_[name].py"

# Launch all models for User Story 1 together:
Task: "Create [Entity1] model in src/models/[entity1].py"
Task: "Create [Entity2] model in src/models/[entity2].py"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence

---

> **Version**: 1.0.1
> **Last Amended**: 2026-01-17
