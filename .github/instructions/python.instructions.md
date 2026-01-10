---
applyTo: "**/*.py"
---

# Python Engineering Instructions (CLI + API, framework-agnostic) 🐍

These instructions define the default engineering approach for building **modern, production-grade Python CLIs and APIs**.

They must remain applicable to:

- Minimal CLIs (standard library `argparse`)
- Command frameworks (for example Typer, Click)
- Rich output and TUIs (for example Rich, Textual, prompt_toolkit)
- **Django** (including Django REST Framework)
- **FastAPI** (ASGI)
- **AWS Lambda–hosted APIs** (for example API Gateway + Lambda, function URLs, or containers)

They are **non-negotiable** unless an exception is explicitly documented (with rationale and expiry) in an ADR/decision record.

**Identifier scheme.** Every normative rule carries a unique tag in the form `[PY-<prefix>-NNN]`, where the prefix maps to the containing section (for example `OP` for Operating Principles, `LCL` for Local-first developer experience, `QG` for Quality Gates, continuing through `AI` for AI-assisted expectations). Use these identifiers when referencing, planning, or validating requirements.

---

## 0. Quick reference (apply first) 🧠

This section exists so humans and AI assistants can reliably apply the most important rules even when context is tight.

- [PY-QR-001] **Specification first**: treat the specification as the source of truth for behaviour ([PY-OP-001]).
- [PY-QR-002] **Small, safe changes**: prefer small, explicit, testable changes ([PY-OP-002], [PY-OP-006]).
- [PY-QR-003] **Fast feedback**: local development and tests must be quick and confidence-building ([PY-OP-007], [PY-LCL-001]–[PY-LCL-006]).
- [PY-QR-004] **Run the quality gates** after any code/test change and iterate to clean ([PY-QG-001]–[PY-QG-004]).
- [PY-QR-005] **Validate at boundaries** and reject ambiguous inputs ([PY-DATA-001]–[PY-DATA-003]).
- [PY-QR-006] **Deterministic outputs**: stable ordering, stable field naming, no hidden randomness ([PY-OP-003], [PY-CTR-007]).
- [PY-QR-007] **Correct CLI streams**: stdout for primary output, stderr for diagnostics ([PY-BEH-008]–[PY-BEH-011]).
- [PY-QR-008] **No secrets in args or logs**: use env vars or secure prompts; never print secrets ([PY-SEC-001]–[PY-SEC-004], [PY-OBS-013]).
- [PY-QR-009] **Local by default**: no real cloud/network by default; use fakes/emulators; explicit integration mode switches ([PY-EXT-001]–[PY-EXT-007]).
- [PY-QR-010] **Operational visibility**: correlation IDs and structured logs for APIs; controlled diagnostics only ([PY-OBS-004]–[PY-OBS-010], [PY-OBS-015]–[PY-OBS-026], [PY-ERR-013]).

---

## 1. Operating principles 🧭

These principles extend [constitution.md §3](../../.specify/memory/constitution.md#3-core-principles-non-negotiable).

- [PY-OP-001] Treat the **specification as the source of truth** for behaviour. If behaviour is not specified, it does not exist.
- [PY-OP-002] Prefer **small, explicit, testable** changes over broad rewrites or large refactors.
- [PY-OP-003] Design for **determinism** (stable outputs for the same inputs) and:
  - [PY-OP-003a] **operability** (clear errors, easy diagnosis) for CLIs
  - [PY-OP-003b] **observability** (you can explain what happened and why) for APIs
- [PY-OP-004] Optimise for **maintenance, usability/operability, and change safety**, not cleverness.
- [PY-OP-005] **Fast feedback is paramount**: local development must be quick, automated, and confidence-building.
- [PY-OP-006] Avoid inventing requirements, widening scope, or introducing behaviour not present in the specification.
- [PY-OP-007] Avoid heavyweight work at import time (slow startup, surprises in tests, higher cold-start cost). Initialise heavy resources lazily or behind explicit entrypoints.
- [PY-OP-008] Keep global state minimal and explicit. Prefer dependency injection and explicit wiring over hidden module-level singletons.

---

## 2. Local-first developer experience (bleeding-edge fast feedback) ⚡

The system must be **fully developable and testable locally**, even when it integrates with external services as part of a larger system.

### 2.1 Single-command workflow (must exist)

Provide repository-standard commands so an engineer can do the following quickly:

- [PY-LCL-001] Bootstrap: `make dev` — installs tooling and dependencies, and prepares a usable local environment
- [PY-LCL-002] Lint/format: `make lint`
- [PY-LCL-003] Test (fast lane): `make test` — must run quickly (aim: < 10 seconds, provide another make target for slower tests) and deterministically
- [PY-LCL-004] Full suite: `make test-all` — includes integration/e2e tiers
- [PY-LCL-005] Run CLI locally: `make run` — runs with safe defaults (**no cloud dependencies by default**)
- [PY-LCL-006] Run API locally: `make up` / `make down` — starts/stops local dependency stack (if applicable)

If `make` is not used, provide an equivalent task runner with the same intent and predictable names.

### 2.2 Reproducible toolchain (avoid "works on my machine")

- [PY-LCL-007] Pin the Python version (for example `.python-version` and/or project metadata).
- [PY-LCL-008] Use deterministic dependency management (lock file preferred).
- [PY-LCL-009] Use `uv` as the canonical Python project and package manager (lock file, installs, scripted commands) unless an ADR formally documents a different choice:
  - [PY-LCL-009a] `uv sync` for deterministic installs across laptops and CI
  - [PY-LCL-009b] `uv run ...` for invoking tools and project commands
  - [PY-LCL-009c] If a repo must deviate from `uv`, record the exception (scope + expiry) in an ADR before merging
- [PY-LCL-010] Keep the developer toolchain minimal and fast.

Repository defaults (unless the repository explicitly documents an alternative):

- [PY-LCL-011] Ruff is the mandatory linter/formatter; configure `ruff check` and `ruff format` as the defaults for `make lint` / CI quality gates
- [PY-LCL-012] Pytest for tests
- [PY-LCL-013] mypy (or the repository-approved static type checker) for deterministic type analysis

### 2.3 Pre-commit hooks (strongly recommended)

Provide a `pre-commit` configuration that runs the same checks as CI in a fast, local-friendly way:

- [PY-LCL-014] formatting (Ruff)
- [PY-LCL-015] linting (Ruff)
- [PY-LCL-016] basic type checks (where fast enough)
- [PY-LCL-017] secret scanning (for example gitleaks)

Hooks must be quick; heavy checks belong in CI and explicit local targets.

### 2.4 OCI images for parity and zero-setup (strongly recommended)

Provide an OCI-based option so behaviour is consistent across laptops and CI:

- [PY-LCL-018] A lightweight dev image that includes:
  - [PY-LCL-018a] Python + locked dependencies
  - [PY-LCL-018b] lint/test tooling
  - [PY-LCL-018c] any required system packages
- [PY-LCL-019] Provide one command to use it:
  - [PY-LCL-019a] `make docker-test` / `make docker-run` (or Dev Containers), etc.

Rules:

- [PY-LCL-020] OCI support must be **optional** (native dev still works), but it must be maintained.
- [PY-LCL-021] Never bake secrets into images.
- [PY-LCL-022] The same commands (`make lint`, `make test`) must work inside and outside the container.

### 2.5 Fast iteration patterns (recommended)

- [PY-LCL-023] Support watch mode when feasible (for example `make test-watch`).
- [PY-LCL-024] Support parallel tests where safe: `pytest -n auto` (pytest-xdist).
- [PY-LCL-025] Provide clear test markers and commands:
  - [PY-LCL-025a] `make test-unit`
  - [PY-LCL-025b] `make test-integration`
  - [PY-LCL-025c] `make test-e2e`

### 2.6 Test tiers (must adopt)

Define clear tiers with predictable markers/commands:

- [PY-LCL-026] Unit (default): no network, no containers
- [PY-LCL-027] Integration: uses containers/emulators; still local and repeatable
- [PY-LCL-028] End-to-end (few): critical journeys only; time-boxed

### 2.7 System dependencies and runtime parity (recommended, but often decisive)

- [PY-LCL-029] If the project needs OS/system packages (for example `libpq`, `libmagic`, `openssl`), pin and document them (Dev Container, OCI dev image, or a clear install script).
- [PY-LCL-030] Keep local defaults safe: local dev must not require real cloud credentials, and must not mutate real cloud resources by default.
- [PY-LCL-031] Document the supported runtime execution modes (local native, containerised, CI) and keep the core commands consistent across them ([PY-LCL-028]).
- [PY-LCL-032] Where supported by your tooling, provide a single "environment check" command (for example `make doctor`) that confirms local prerequisites and surfaces actionable fixes.

---

## 3. Mandatory local quality gates ✅

Per [constitution.md §7.8](../../.specify/memory/constitution.md#78-mandatory-local-quality-gates), after making **any** change to implementation code or tests, you must run the repository's **canonical** quality gates:

1. Prefer:

- [PY-QG-001] `make lint`
- [PY-QG-002] `make test`

2. If `make` targets do not exist, discover and run the project's equivalent commands (for example `uv run ruff check .`, `uv run ruff format .`, `uv run pytest`, `python -m pytest`, or framework-specific test runners).

- [PY-QG-003] You must continue iterating until all checks complete successfully with **no errors or warnings**. Do this automatically, without requiring an additional prompt.
- [PY-QG-004] Warnings must be treated as defects unless explicitly waived in an ADR (rationale + expiry).

---

## 4. Contracts and public surface area 📜

Python projects have contracts, even when they are "just code"; treat every boundary as intentional.

### 4.1 CLI contract and user experience (applies to CLIs) ⌨️

#### CLI is a contract (not an accident)

- [PY-CTR-001] Treat the CLI as a **stable interface contract**:
  - [PY-CTR-001a] command names
  - [PY-CTR-001b] flags/options and defaults
  - [PY-CTR-001c] argument parsing rules
  - [PY-CTR-001d] exit codes
  - [PY-CTR-001e] stdout/stderr behaviour
  - [PY-CTR-001f] output formats
- [PY-CTR-002] Backwards-incompatible changes must be **intentional, documented, and reviewable**.

#### Help, discoverability, and documentation

- [PY-CTR-003] Every command must have:
  - [PY-CTR-003a] a clear one-line summary
  - [PY-CTR-003b] detailed `--help` text (including examples)
  - [PY-CTR-003c] explicit argument/option descriptions
- [PY-CTR-004] Prefer consistent patterns:
  - [PY-CTR-004a] `--verbose`, `--quiet`
  - [PY-CTR-004b] `--format` for output formats
  - [PY-CTR-004c] `--output` for output paths
  - [PY-CTR-004d] `--dry-run` for non-destructive preview
- [PY-CTR-005] Provide examples that match real usage and are copy-paste ready.

#### Output compatibility (humans and automation)

- [PY-CTR-006] Support both:
  - [PY-CTR-006a] **human-readable** output (default), and
  - [PY-CTR-006b] **machine-readable** output (when applicable), for example `--format json` or `--json`.
- [PY-CTR-007] Output must be deterministic:
  - [PY-CTR-007a] stable ordering rules
  - [PY-CTR-007b] stable field naming
  - [PY-CTR-007c] no hidden randomness
- [PY-CTR-008] Never mix progress/status messages into structured output.

### 4.2 API contract and surface area (applies to APIs) 🌐

#### API is a contract (not an accident)

- [PY-CTR-009] Treat the external API as a **stable contract** (HTTP semantics, payload shapes, status codes, headers).
- [PY-CTR-010] Changes to the contract must be **intentional, documented, and reviewable**.
- [PY-CTR-011] Prefer backward-compatible changes. When breaking changes are necessary:
  - [PY-CTR-011a] make them explicit
  - [PY-CTR-011b] provide a migration path
  - [PY-CTR-011c] version the API where appropriate

#### Versioning policy

- [PY-CTR-012] Prefer **non-breaking evolution** (additive fields, new endpoints, optional query parameters).
- [PY-CTR-013] If versioning is required:
  - [PY-CTR-013a] use a consistent scheme (for example `/v1/` path prefix or content negotiation)
  - [PY-CTR-013b] avoid ad-hoc per-endpoint versioning

#### OpenAPI / schema outputs (where supported)

- [PY-CTR-014] If the framework can generate OpenAPI or an equivalent schema, treat it as **first-class**:
  - [PY-CTR-014a] accurate request/response models
  - [PY-CTR-014b] clear summaries/descriptions
  - [PY-CTR-014c] examples when they reduce ambiguity
- [PY-CTR-015] Do not leak internal persistence models or implementation details into the contract.

---

## 5. Behaviour rules 🚦

**Section summary (key subsections):**

- 5.1 CLI command structure and semantics — subcommands and composition
- 5.2 HTTP behaviour rules — methods, status codes, retries, pagination

### 5.1 CLI command structure and semantics (applies to CLIs)

#### Subcommands and composition

- [PY-BEH-001] Prefer a consistent shape: `tool <command> <subcommand> [options]`.
- [PY-BEH-002] Use subcommands to separate behaviours, not positional-argument tricks.
- [PY-BEH-003] Keep commands single-responsibility; avoid "do everything" commands.

#### Exit codes (must be consistent)

- [PY-BEH-004] Exit codes must follow the shared [CLI contract](./include/cli-contract.md#1-exit-codes-non-negotiable) (`0` success, `1` general failure, `2` usage error) unless an ADR approves a deviation.
- [PY-BEH-005] Never signal failure only via text; exit codes must reflect outcomes.
- [PY-BEH-006] When no specific code is reserved, default to `1` for operational failures per the CLI contract and document any additional codes.
- [PY-BEH-007] If automation depends on specific failure modes, define and test those exit codes, referencing the CLI contract for documentation expectations.

#### Stdout vs stderr (non-negotiable)

- [PY-BEH-008] Follow the [CLI contract stream semantics](./include/cli-contract.md#2-stdout-vs-stderr-stream-semantics): keep primary outputs on `stdout`, diagnostics on `stderr`.
- [PY-BEH-009] Diagnostics (progress, warnings, debug, human-readable errors) must never pollute `stdout`.
- [PY-BEH-010] The tool must behave correctly when stdout is piped or redirected; treat `stderr` as the only channel for diagnostics.

#### Timeouts and cancellation

- [PY-BEH-011] Long-running operations must be interruptible:
  - [PY-BEH-011a] handle `Ctrl+C` (SIGINT) gracefully
  - [PY-BEH-011b] avoid leaving partial/corrupt outputs
- [PY-BEH-012] All outbound calls must have explicit timeouts.
- [PY-BEH-013] Provide a `--timeout` option where it materially affects UX.

### 5.2 HTTP behaviour rules (applies to APIs)

#### Semantics

- [PY-BEH-014] Use correct methods: `GET` (read), `POST` (create), `PUT` (replace), `PATCH` (partial update), `DELETE` (remove).
- [PY-BEH-015] Use correct status codes:
  - [PY-BEH-015a] `200/204` for successful reads/updates/deletes as appropriate
  - [PY-BEH-015b] `201` for create with a `Location` header when applicable
  - [PY-BEH-015c] `400` for invalid input, `401` unauthenticated, `403` unauthorised, `404` not found
  - [PY-BEH-015d] `409` for conflicts (including concurrency conflicts)
  - [PY-BEH-015e] `422` only where the chosen framework's conventions make it the correct and consistent choice
  - [PY-BEH-015f] `429` for rate limiting
  - [PY-BEH-015g] `5xx` only for server faults

#### Idempotency and retries

- [PY-BEH-016] Design for safe retries:
  - [PY-BEH-016a] `GET`, `PUT`, `DELETE` must be idempotent by design.
  - [PY-BEH-016b] `POST` should be idempotent **when the client may retry** (support idempotency keys where appropriate).
- [PY-BEH-017] Make concurrency rules explicit:
  - [PY-BEH-017a] use optimistic concurrency controls (ETags/version fields) where relevant
  - [PY-BEH-017b] return `409` on conflicts with a clear error code

#### Pagination, filtering, sorting

- [PY-BEH-018] For collections, prefer:
  - [PY-BEH-018a] pagination (cursor-based when feasible)
  - [PY-BEH-018b] explicit filtering (query parameters)
  - [PY-BEH-018c] stable sorting with deterministic defaults
- [PY-BEH-019] Make ordering rules explicit and deterministic.

#### Timeouts

- [PY-BEH-020] All outbound calls must have explicit timeouts.
- [PY-BEH-021] Avoid unbounded waits in request/response flows.

---

## 6. Configuration and precedence ⚙️

### 6.1 Precedence order (must be explicit)

Define and document precedence. Prefer this order:

1. Command-line flags/options
2. Environment variables
3. Configuration file(s)
4. Built-in defaults

### 6.2 Configuration file support

- [PY-CFG-001] If configuration files are used, prefer a predictable location and format.
- [PY-CFG-002] Ensure config is:
  - [PY-CFG-002a] schema-validated
  - [PY-CFG-002b] backwards-compatible where possible
  - [PY-CFG-002c] explicit about defaults

### 6.3 Environment variables

- [PY-CFG-003] Use a consistent prefix (for example `TOOL_...`).
- [PY-CFG-004] Document each variable and how it maps to flags/options.
- [PY-CFG-005] Default local configuration must be safe: do not require real cloud credentials, and do not enable destructive behaviour unless explicitly requested by flags/options.

---

## 7. Data validation and modelling 🧱

### 7.1 Validation (mandatory at boundaries, non-negotiable)

- [PY-DATA-001] Validate inputs at the boundary.
  - [PY-DATA-001a] For CLIs: flags/args, config files, environment variables, file paths
  - [PY-DATA-001b] For APIs: request body, query parameters, path parameters, headers (when relevant)
- [PY-DATA-002] Validation rules must be **deterministic, explicit, and testable**.
- [PY-DATA-003] Avoid silent coercion. If inputs are ambiguous, reject them with a clear validation error.

### 7.2 Model separation (APIs and non-trivial CLIs)

Keep these concepts separate:

- [PY-DATA-004] API models (request/response)
- [PY-DATA-005] domain models (business concepts and invariants)
- [PY-DATA-006] persistence models (database representations)

Do not expose persistence models directly through an API.

### 7.3 Stable data contracts (APIs and structured CLI outputs)

- [PY-DATA-007] Use explicit field names, types, and optionality.
- [PY-DATA-008] Prefer additive changes (new optional fields) over breaking changes.

---

## 8. External integrations without slowing local dev 🔌

If the system depends on cloud services (AWS, HTTP APIs, databases), local feedback must still be fast.

Rules:

- [PY-EXT-001] Default local behaviour must not require network access.
- [PY-EXT-002] Provide **three integration modes**, in order of preference:
  1. **Fake** (in-process implementation for fast unit tests)
  2. **Emulator** (external local service, for example LocalStack, DynamoDB Local, a local Postgres container)
  3. **Real cloud** (only for explicit integration runs)

Mandatory practices:

- [PY-EXT-003] Use dependency injection / adapters so the CLI/API can swap implementations cleanly.
- [PY-EXT-004] Provide a `--profile`/`--env`/`--mode` switch (or config) to select integration mode.
- [PY-EXT-005] Tests must not hit real cloud by default.
- [PY-EXT-006] When emulators are used, start them automatically (for example via Docker Compose or Testcontainers).
- [PY-EXT-007] Pin emulator image versions to avoid drift.

Suggested emulator choices (pick what matches the system):

- [PY-EXT-008] AWS: LocalStack (or service-specific local emulators)
- [PY-EXT-009] DynamoDB: DynamoDB Local (or LocalStack)
- [PY-EXT-010] SQS/SNS/EventBridge: LocalStack
- [PY-EXT-011] Databases: Postgres/MySQL via Docker Compose
- [PY-EXT-012] HTTP dependencies: local stub server that matches OpenAPI/JSON Schema, or mocked HTTP via `responses`

---

## 9. Error handling and failure semantics 🧯

### 9.1 Fail explicitly, not silently (non-negotiable)

- [PY-ERR-001] Silent failure is forbidden.
- [PY-ERR-002] Partial success must be explicit (and specified).
- [PY-ERR-003] Do not return `200` with an embedded error.

### 9.2 CLI error messages (human-first) ⌨️

- [PY-ERR-004] Error output must be:
  - [PY-ERR-004a] concise
  - [PY-ERR-004b] plain language
  - [PY-ERR-004c] actionable ("what to do next")
- [PY-ERR-005] Avoid stack traces by default.
- [PY-ERR-006] Where helpful, include:
  - [PY-ERR-006a] a stable `error_code`
  - [PY-ERR-006b] a short "next steps" hint
  - [PY-ERR-006c] a reference to documentation/runbook (if available)

### 9.3 API error responses (consistent and machine-parseable) 🌐

All error responses must be consistent and machine-parseable. Prefer this structure:

- [PY-ERR-007] `error_code`: stable identifier (for automation, dashboards, and runbooks)
- [PY-ERR-008] `message`: human-readable explanation (plain language)
- [PY-ERR-009] `details`: optional structured details (for example field validation issues)
- [PY-ERR-010] `correlation_id`: request id / trace id when available

### 9.4 Error classification (applies to APIs; recommended for CLIs with structured output)

- [PY-ERR-011] Distinguish between:
  - [PY-ERR-011a] validation errors
  - [PY-ERR-011b] domain/business rule errors
  - [PY-ERR-011c] authentication/authorisation errors
  - [PY-ERR-011d] not found
  - [PY-ERR-011e] conflicts/concurrency errors
  - [PY-ERR-011f] dependency/boundary errors (database, AWS, network)
- [PY-ERR-012] Do not leak sensitive internals in error messages.

### 9.5 Debugging modes 🪲

- [PY-ERR-013] Support controlled diagnostics:
  - [PY-ERR-013a] `--verbose` increases detail
  - [PY-ERR-013b] `--debug` may include stack traces (still never secrets)
- [PY-ERR-014] Diagnostics must not change behaviour, only observability.

---

## 10. Observability and operational readiness 🔭

Observability is non-negotiable.

**Section summary (key subsections):**

- 10.0 Minimum baseline — the bar that applies everywhere
- 10.1–10.2 Correlation IDs — CLI run identity and API request identity
- 10.3 Logging rules — structured logs, what to include, what never to log
- 10.4–10.5 Request lifecycle and dependency visibility
- 10.6–10.7 Distributed tracing and metrics
- 10.8–10.11 Error capture, runbooks, audit logs, Lambda notes

### 10.0 Minimum baseline (apply everywhere) ✅

- [PY-OBS-001] Treat this as the minimum bar:
  - CLIs: run identity + sane stderr diagnostics ([PY-OBS-002]–[PY-OBS-003], [PY-OBS-011]–[PY-OBS-014])
  - APIs: correlation IDs + structured logs + request start/end lifecycle logs ([PY-OBS-004]–[PY-OBS-010], [PY-OBS-015]–[PY-OBS-026])

### 10.1 CLI run identity and correlation 🧾

For CLIs:

- [PY-OBS-002] Generate a `run_id` for each invocation (UUID or equivalent).
- [PY-OBS-003] Include `run_id` in:
  - [PY-OBS-003a] debug/verbose logs
  - [PY-OBS-003b] error output
  - [PY-OBS-003c] structured outputs (when relevant, as metadata)

### 10.2 API correlation and request identity 🧾

For APIs, every request must have stable identifiers that flow through the whole call chain:

- [PY-OBS-004] Accept an inbound correlation id (prefer `X-Request-Id`) **or generate one** if missing.
- [PY-OBS-005] Accept an inbound W3C trace context (`traceparent` / `tracestate`) where present.
- [PY-OBS-006] Return the correlation id in every response header (at minimum `X-Request-Id`).
- [PY-OBS-007] Propagate correlation and trace context to all outbound calls (HTTP, AWS SDK calls, queues/events where supported).

Rules:

- [PY-OBS-008] Do not overwrite inbound ids unless they are invalid.
- [PY-OBS-009] If you create a new id, log it once early and attach it everywhere.
- [PY-OBS-010] Ensure correlation ids are included in:
  - [PY-OBS-010a] every log record (as a structured field)
  - [PY-OBS-010b] error responses (`correlation_id`)
  - [PY-OBS-010c] traces (as attributes)

### 10.3 Logging rules (CLI and API) 🧱

For CLIs:

- [PY-OBS-011] Default behaviour:
  - [PY-OBS-011a] minimal logs to stderr
  - [PY-OBS-011b] no noisy debug output
- [PY-OBS-012] Structured logging (JSON) should be available when useful:
  - [PY-OBS-012a] `--log-format json` (or equivalent)
  - [PY-OBS-012b] `--log-level` (INFO/WARNING/ERROR/DEBUG)
- [PY-OBS-013] When emitting structured output, include the CLI invocation fields defined in the [Structured Logging Baseline](./include/observability-logging-baseline.md#2-required-fields-clis) and never log secrets, tokens, credentials, or raw personal data.
- [PY-OBS-014] Prefer event-style logs with stable names:
  - [PY-OBS-014a] `command.start`, `command.end`, `step.start`, `step.end`, `dependency.call`, `dependency.error`

For APIs (mandatory structured logging):

Logs must be structured (prefer JSON), queryable, and consistent.

- [PY-OBS-015] Service/API logs must include the required fields defined in the [Structured Logging Baseline](./include/observability-logging-baseline.md#1-required-fields-services-apis); do not fork or trim that list locally.
- [PY-OBS-016] HTTP metadata (method, path template, status code) and timing/outcome fields from the baseline are mandatory for every request log entry.
- [PY-OBS-017] Apply the baseline secrecy rules ([section 3](./include/observability-logging-baseline.md#3-sensitive-data--secrecy-rules)): never log secrets, credentials, or raw personal data; mask or truncate payloads when logging is explicitly required.
- [PY-OBS-018] Use the baseline event taxonomy ([section 4](./include/observability-logging-baseline.md#4-event-naming--taxonomy)) so request/dependency events stay searchable across repos.
- [PY-OBS-019] Prefer high-signal logs only:
  - [PY-OBS-019a] start/end of request (one each)
  - [PY-OBS-019b] key domain decision points (not every line)
  - [PY-OBS-019c] boundary calls (DB, AWS, HTTP)
  - [PY-OBS-019d] errors (once, with structured context)
  - [PY-OBS-019e] When `DEBUG`/diagnostic logging is enabled, emit a single function/method entry log for every call path, capturing the operation name and a sanitised summary of arguments per the [Structured Logging Baseline §5](./include/observability-logging-baseline.md#5-diagnostics--sampling); never include sensitive data.

Log level policy:

- [PY-OBS-020] `DEBUG`: only for local/dev or explicitly enabled diagnostics (never required in normal production operation)
- [PY-OBS-021] `INFO`: normal request lifecycle and major domain events
- [PY-OBS-022] `WARNING`: degraded behaviour, retries, unexpected but handled conditions
- [PY-OBS-023] `ERROR`: failed operations, exceptions, dependency failures
- [PY-OBS-024] `CRITICAL`: data loss, security incidents, corruption, or systemic failure

### 10.4 API request lifecycle logging (start/end) ⏱️

For every API request, produce:

- [PY-OBS-025] exactly one `request.start` log (minimal fields)
- [PY-OBS-026] exactly one `request.end` log (must include `status_code` and `duration_ms`)

Ensure the end log happens even on exceptions.

### 10.5 Dependency call visibility (DB, HTTP, AWS) 🔌

All external boundary calls must be observable:

- [PY-OBS-027] Emit a `dependency.call` log with:
  - [PY-OBS-027a] dependency name (`dynamodb`, `aurora`, `s3`, `http.<service>`, etc.)
  - [PY-OBS-027b] operation (for example `GetItem`, `SELECT`, `POST /v1/payments`)
  - [PY-OBS-027c] `duration_ms`
  - [PY-OBS-027d] outcome
- [PY-OBS-028] On failure, emit `dependency.error` with:
  - [PY-OBS-028a] `error_class`, `error_code` (where mapped), and retry intention
- [PY-OBS-029] Do not leak sensitive query parameters or payloads.
- [PY-OBS-030] For database queries, log:
  - [PY-OBS-030a] query name / prepared statement id (not raw SQL unless explicitly safe)
  - [PY-OBS-030b] row count (if cheap)
  - [PY-OBS-030c] slow query warnings with thresholds

### 10.6 Distributed tracing (services and methods) 🧵

Tracing must be supported using standard trace context:

- [PY-OBS-031] Prefer OpenTelemetry semantics (even if the backend is AWS X-Ray, Jaeger, etc.).
- [PY-OBS-032] Create spans for:
  - [PY-OBS-032a] request handler / entrypoint
  - [PY-OBS-032b] major internal operations (use-cases)
  - [PY-OBS-032c] each boundary call (DB, AWS SDK, HTTP)
- [PY-OBS-033] Attach attributes to spans:
  - [PY-OBS-033a] `request_id`, `user_role` (never PII), `operation`
  - [PY-OBS-033b] dependency name and operation
  - [PY-OBS-033c] outcome and `error_code` when applicable

Propagation rules:

- [PY-OBS-034] Always propagate trace context to outbound HTTP calls.
- [PY-OBS-035] For async/event-driven flows:
  - [PY-OBS-035a] preserve correlation ids in message attributes/metadata
  - [PY-OBS-035b] include trace context where supported

Sampling rules:

- [PY-OBS-036] Use sensible sampling in production.
- [PY-OBS-037] Ensure errors are traceable even when sampling is low (for example error-biased sampling where available).

### 10.7 Metrics (the signals that drive action) 📈

Metrics must support operational decisions and alerting.

At minimum, record:

- [PY-OBS-038] request rate (by `operation` and response class `2xx/4xx/5xx`)
- [PY-OBS-039] error rate (by `error_code` and class)
- [PY-OBS-040] latency (p50/p95/p99 per `operation`)
- [PY-OBS-041] saturation signals (queue depth, concurrency, connection pool usage where applicable)
- [PY-OBS-042] dependency metrics (latency and error rate per dependency)

Cardinality rules:

- [PY-OBS-043] Do not put raw ids (user ids, request ids) into metric labels.
- [PY-OBS-044] Keep labels stable and bounded (use route templates and coarse categories).

### 10.8 Error capture, debugging, and "fast diagnosis" 🧠

Error handling must support rapid diagnosis without exposing internals to clients:

- [PY-OBS-045] Map errors to stable `error_code`s and HTTP statuses.
- [PY-OBS-046] Log the exception once, with:
  - [PY-OBS-046a] `error_code`, `error_class`, `request_id`, `trace_id`
  - [PY-OBS-046b] a stack trace (server logs only)
  - [PY-OBS-046c] relevant safe context (operation, dependency, validation details)
  - [PY-OBS-046d] Set the severity to `ERROR` for every exception log, even if the software can recover, so operators can see the failure signal.
- [PY-OBS-047] Avoid duplicate logging:
  - [PY-OBS-047a] do not log and then re-log the same exception at multiple layers unless each log adds new information.
- [PY-OBS-048] Provide a safe client message; never expose stack traces to clients.
- [PY-OBS-049] Support a controlled "diagnostic mode":
  - [PY-OBS-049a] enabled by configuration, not code changes
  - [PY-OBS-049b] increases logging detail without changing behaviour
  - [PY-OBS-049c] still must not leak secrets or personal data

### 10.9 Runbook hooks and actionable outputs 🧭

Where an error is operationally meaningful:

- [PY-OBS-050] include a `runbook` link or reference key (for example `RUN-API-012`) in logs for `ERROR`/`CRITICAL` events.
- [PY-OBS-051] ensure the log fields are sufficient to:
  - [PY-OBS-051a] reproduce the issue locally (inputs summarised safely)
  - [PY-OBS-051b] identify the failing dependency and operation
  - [PY-OBS-051c] understand whether it is transient vs persistent

### 10.10 Audit and security event logging 🛡️

Security-relevant actions must produce explicit audit logs:

- [PY-OBS-052] authentication events (success/failure)
- [PY-OBS-053] authorisation denials (`403`)
- [PY-OBS-054] privileged operations
- [PY-OBS-055] configuration changes
- [PY-OBS-056] data export / bulk operations (where applicable)

Audit log rules:

- [PY-OBS-057] never log credentials or raw tokens
- [PY-OBS-058] include who/what/when:
  - [PY-OBS-058a] actor type (service/user), role (not identity), operation, outcome, request_id
- [PY-OBS-059] ensure audit events are distinguishable from application logs (`event: security.audit`)

### 10.11 Serverless notes (Lambda) ☁️

When running in AWS Lambda:

- [PY-OBS-060] Always log with correlation ids that map to:
  - [PY-OBS-060a] API Gateway request ids where available
  - [PY-OBS-060b] Lambda `aws_request_id`
- [PY-OBS-061] Ensure cold start visibility:
  - [PY-OBS-061a] log a one-time `cold_start` event per container lifecycle (best effort)
- [PY-OBS-062] Prefer structured logs for CloudWatch and ensure they are parseable.
- [PY-OBS-063] Ensure timeouts and downstream retries are visible and measurable.

---

## 11. Security defaults 🔐

**Section summary (key subsections):**

- 11.1 CLI security rules — secrets, file paths, remote calls
- 11.2 API security rules — core rules, AuthN, AuthZ, service-to-service, secrets, headers, testing

### 11.1 CLI security rules (applies to CLIs)

- [PY-SEC-001] Do not accept secrets via command-line args unless unavoidable (they leak via shell history and process lists).
  - [PY-SEC-001a] Prefer environment variables or secure prompts.
- [PY-SEC-002] Never print secrets in output or logs.
- [PY-SEC-003] Validate and normalise all file paths and external inputs.
- [PY-SEC-004] Treat remote calls as untrusted boundaries; handle:
  - [PY-SEC-004a] timeouts
  - [PY-SEC-004b] retries/backoff (when safe)
  - [PY-SEC-004c] clear failure reporting

### 11.2 API security rules (applies to APIs) 🔐

Security is part of the API contract. **Authentication and authorisation are not optional.** If an endpoint is not explicitly declared as public, it is private.

#### Core rules (always)

- [PY-SEC-005] **Default deny**:
  - [PY-SEC-005a] Deny all requests unless authentication is successful _and_ authorisation passes.
  - [PY-SEC-005b] Do not "assume internal" or "assume trusted network".
- [PY-SEC-006] **Separate concerns**:
  - [PY-SEC-006a] Authentication (who/what is calling) and authorisation (what they can do) must be distinct and explicit.
- [PY-SEC-007] **Do not invent identity**:
  - [PY-SEC-007a] Never infer a user/service identity from headers you did not validate.
- [PY-SEC-008] **Principle of least privilege**:
  - [PY-SEC-008a] Grant the smallest permissions required; avoid broad roles like `admin` unless truly necessary.

#### Authentication (AuthN)

Choose one primary mechanism per API surface and apply it consistently.

Accepted mechanisms (preferred order depends on context):

- [PY-SEC-009] **User-facing APIs**: OAuth 2.0 / OIDC with access tokens (typically JWTs) issued by a trusted IdP.
- [PY-SEC-010] **Service-to-service APIs**: AWS IAM (SigV4) or OIDC-based workload identity. Avoid static shared secrets.
- [PY-SEC-011] **Browser-based session APIs** (only when required): secure, server-managed sessions with cookies.

Rules for bearer tokens (OAuth/OIDC/JWT):

- [PY-SEC-012] Validate **every request**:
  - [PY-SEC-012a] signature (using issuer JWKS)
  - [PY-SEC-012b] `iss` (issuer) matches exactly
  - [PY-SEC-012c] `aud` (audience) matches this API
  - [PY-SEC-012d] `exp` and `nbf` (expiry and not-before)
  - [PY-SEC-012e] algorithm allow-list (do not accept `none`)
  - [PY-SEC-012f] clock skew is bounded and consistent
- [PY-SEC-013] Fetch keys from JWKS securely and **cache** them; support key rotation.
- [PY-SEC-014] Treat tokens as **opaque secrets**:
  - [PY-SEC-014a] never log full tokens
  - [PY-SEC-014b] never store tokens in URLs or query strings
  - [PY-SEC-014c] avoid reflecting tokens back to clients
- [PY-SEC-015] Reject invalid/missing tokens with:
  - [PY-SEC-015a] `401` and an appropriate `WWW-Authenticate` header when using Bearer tokens.

Rules for sessions (cookies):

- [PY-SEC-016] Cookies must be:
  - [PY-SEC-016a] `HttpOnly`
  - [PY-SEC-016b] `Secure`
  - [PY-SEC-016c] `SameSite` set appropriately (`Lax` or `Strict` by default; `None` only when required)
- [PY-SEC-017] Browser flows must use **CSRF protection** for state-changing requests.
- [PY-SEC-018] Session fixation prevention is mandatory (rotate session identifiers on login/privilege changes).
- [PY-SEC-019] Avoid mixed models (both cookies and bearer tokens) unless explicitly specified.

API keys (clarity):

- [PY-SEC-020] An API key is **not** authentication of a person or service by itself.
- [PY-SEC-021] API keys may be used as:
  - [PY-SEC-021a] a client identifier
  - [PY-SEC-021b] a throttling key
  - [PY-SEC-021c] a coarse access gate
- [PY-SEC-022] If API keys are used, they must be paired with explicit authorisation, and rotated regularly.

#### Authorisation (AuthZ)

Authorisation must be explicit, testable, and enforced consistently.

- [PY-SEC-023] **Policy first**:
  - [PY-SEC-023a] Define permissions in a small, explicit policy model (RBAC and/or ABAC).
  - [PY-SEC-023b] Prefer _capabilities_ (what you can do) over _job titles_ (who you are).
- [PY-SEC-024] **No "role checks" scattered everywhere**:
  - [PY-SEC-024a] Centralise checks in a policy layer (decorators/middleware/service layer), not inside random handlers.
- [PY-SEC-025] **Least privilege by default**:
  - [PY-SEC-025a] New endpoints default to "no access" until a policy is declared.
- [PY-SEC-026] **Authorisation decisions must be auditable**:
  - [PY-SEC-026a] log `403` denials with an audit event (without PII).
- [PY-SEC-027] **Return codes**:
  - [PY-SEC-027a] `401` = not authenticated (no/invalid credentials)
  - [PY-SEC-027b] `403` = authenticated but not permitted
  - [PY-SEC-027c] Do not leak whether a resource exists when doing so would reveal sensitive information (consider returning `404` for unauthorised access to certain resources if specified).

RBAC guidance (roles):

- [PY-SEC-028] Keep roles few and stable (for example `reader`, `writer`, `admin`), and define what each can do.
- [PY-SEC-029] Use scopes/permissions to drive behaviour (for example `orders:read`, `orders:write`).

ABAC guidance (attributes):

- [PY-SEC-030] Use claims and request context (for example `tenant_id`, `organisation_id`, `subject_type`, `scopes`, `environment`) to make fine-grained decisions.
- [PY-SEC-031] Avoid using user-provided attributes unless they are validated claims.

Resource-level authorisation:

- [PY-SEC-032] Enforce "can access this resource instance" checks for any resource keyed by an identifier.
- [PY-SEC-033] Do not rely on "filtering in the database" alone; ensure access control is checked before returning data.

Multi-tenant rules (if applicable):

- [PY-SEC-034] Every request must resolve a single authoritative `tenant_id` (from validated claims or explicit, validated routing).
- [PY-SEC-035] Enforce tenant isolation at every boundary:
  - [PY-SEC-035a] queries include tenant scoping
  - [PY-SEC-035b] writes include tenant scoping
  - [PY-SEC-035c] background tasks/events preserve tenant context
- [PY-SEC-036] Never accept tenant identity from an untrusted header.

#### Service-to-service identity (AWS and distributed systems)

When services call services:

- [PY-SEC-037] Prefer **AWS IAM** with SigV4 where the caller runs on AWS:
  - [PY-SEC-037a] use IAM roles (STS) rather than static credentials
  - [PY-SEC-037b] restrict permissions to the target API/route (least privilege)
- [PY-SEC-038] If using OIDC workload identity:
  - [PY-SEC-038a] validate tokens as in Authentication rules
  - [PY-SEC-038b] use short-lived tokens
- [PY-SEC-039] Consider **mTLS** for high-trust internal networks only when it materially improves security and is supportable operationally.

Never:

- [PY-SEC-040] share long-lived "integration secrets" between services without rotation
- [PY-SEC-041] put credentials in code, config files, or container images

#### Secrets and configuration

- [PY-SEC-042] Secrets must be stored in a proper secret manager (AWS Secrets Manager / Parameter Store) and injected at runtime.
- [PY-SEC-043] Secrets must be:
  - [PY-SEC-043a] rotated regularly (define an owner and schedule)
  - [PY-SEC-043b] scoped minimally (one secret per purpose, not "one secret for everything")
  - [PY-SEC-043c] never logged
- [PY-SEC-044] Configuration must distinguish:
  - [PY-SEC-044a] environment (dev/test/stage/prod)
  - [PY-SEC-044b] identity providers and audiences
  - [PY-SEC-044c] allowed origins (CORS) and redirect URIs (if applicable)

#### Security headers and transport

- [PY-SEC-045] Enforce HTTPS everywhere; never accept credentials over plaintext.
- [PY-SEC-046] CORS must be explicit and restrictive:
  - [PY-SEC-046a] allow-list origins, methods, and headers
  - [PY-SEC-046b] do not use `*` for authenticated endpoints
- [PY-SEC-047] Avoid leaking security-relevant details:
  - [PY-SEC-047a] do not echo back auth headers
  - [PY-SEC-047b] do not include internal ids in error messages unless required
- [PY-SEC-048] Rate limiting / throttling must be configured for public APIs, and should consider:
  - [PY-SEC-048a] per-client limits
  - [PY-SEC-048b] per-endpoint hot spots
  - [PY-SEC-048c] burst vs sustained behaviour

#### Security logging and auditability

Security events must be explicit and structured:

- [PY-SEC-049] Log authentication outcomes:
  - [PY-SEC-049a] success/failure
  - [PY-SEC-049b] reason category (expired token, invalid signature, missing credentials, etc.)
  - [PY-SEC-049c] actor type (user/service)
  - [PY-SEC-049d] request_id / trace_id
- [PY-SEC-050] Log authorisation denials:
  - [PY-SEC-050a] `event: security.audit`
  - [PY-SEC-050b] decision (deny)
  - [PY-SEC-050c] required permission/scope and presented scopes (names only)
- [PY-SEC-051] Do not log:
  - [PY-SEC-051a] raw tokens
  - [PY-SEC-051b] secrets
  - [PY-SEC-051c] personal data
- [PY-SEC-052] Where appropriate, include a `runbook` reference in `ERROR`/`CRITICAL` security logs.

#### Testing security controls

Security is behaviour and must be tested.

- [PY-SEC-053] Unit tests:
  - [PY-SEC-053a] policy rules (RBAC/ABAC)
  - [PY-SEC-053b] "allow/deny" for each protected route category
  - [PY-SEC-053c] resource-level access control checks
- [PY-SEC-054] Integration tests (minimal, high-value):
  - [PY-SEC-054a] token validation against a real or stubbed JWKS
  - [PY-SEC-054b] API Gateway / authoriser wiring (when applicable)
- [PY-SEC-055] Negative tests are mandatory:
  - [PY-SEC-055a] missing credentials -> `401`
  - [PY-SEC-055b] invalid credentials -> `401`
  - [PY-SEC-055c] insufficient permissions -> `403`
  - [PY-SEC-055d] cross-tenant access attempt -> `403` (or `404` if specified)

---

## 12. File, I/O, and boundary behaviour 🧱

### 12.1 File and I/O behaviour (CLI focus; applies generally)

- [PY-IO-001] Use atomic writes for output files:
  - [PY-IO-001a] write to a temp file and rename on success
- [PY-IO-002] Never corrupt existing outputs on partial failure.
- [PY-IO-003] Support `--output -` (stdout) where it improves composability.
- [PY-IO-004] When reading files/directories:
  - [PY-IO-004a] define traversal rules
  - [PY-IO-004b] define ordering rules (deterministic)
  - [PY-IO-004c] define error strategy (fail-fast vs continue-with-report) explicitly

### 12.2 Persistence and I/O boundaries (API focus; applies generally)

- [PY-IO-005] Treat external dependencies as boundaries:
  - [PY-IO-005a] databases
  - [PY-IO-005b] AWS SDK calls
  - [PY-IO-005c] HTTP clients
  - [PY-IO-005d] queues and event buses
- [PY-IO-006] Encapsulate boundary logic behind adapters/repositories so business logic remains testable.
- [PY-IO-007] Make transaction boundaries explicit:
  - [PY-IO-007a] avoid implicit global transactions
  - [PY-IO-007b] ensure consistency rules are specified and tested
- [PY-IO-008] Do not let business logic depend on framework request objects.

---

## 13. TUI and interactive behaviour 🖥️

### 13.1 Non-interactive compatibility

- [PY-TUI-001] Every interactive flow must have a non-interactive alternative:
  - [PY-TUI-001a] flags/args to provide required inputs
  - [PY-TUI-001b] `--yes` / `--no-input` / `--non-interactive` conventions
- [PY-TUI-002] Detect non-interactive environments and degrade gracefully.

### 13.2 Accessibility and terminal compatibility ♿️

- [PY-TUI-003] Do not rely on colour alone to convey meaning.
- [PY-TUI-004] Ensure output works in:
  - [PY-TUI-004a] basic terminals
  - [PY-TUI-004b] low-width terminals
  - [PY-TUI-004c] CI logs (no TUI assumptions)
- [PY-TUI-005] Provide a "plain output" mode to disable rich formatting when needed.

### 13.3 Prompts and safety rails

- [PY-TUI-006] Destructive actions must:
  - [PY-TUI-006a] default to safe behaviour
  - [PY-TUI-006b] require explicit confirmation unless `--yes` is provided
- [PY-TUI-007] `--dry-run` must show what would change without changing it.

---

## 14. Testing approach (TDD, unit-test first) 🧪

Per [constitution.md §3.6](../../.specify/memory/constitution.md#36-design-for-testability-tdd), follow a test-first flow for behaviour changes:

1. Write/update a unit test **from the specification**.
2. Confirm it fails for the right reason.
3. Implement the minimal change to pass.
4. Refactor after green, preserving behaviour.

Additional Python-specific testing guidance:

- [PY-TST-001] Prefer the test pyramid:
  - [PY-TST-001a] **most tests**: unit (fast, deterministic, behaviour-focused)
  - [PY-TST-001b] **some tests**: integration (filesystem, subprocess boundaries, emulator-backed boundaries) / integration/contract (critical boundaries)
  - [PY-TST-001c] **few tests**: end-to-end (CLI invocation tests for critical commands / critical journeys only)
- [PY-TST-002] Tests must be deterministic:
  - [PY-TST-002a] control time and randomness
  - [PY-TST-002b] use temp directories/fixtures
  - [PY-TST-002c] avoid real network by default (use stubs/mocks/emulators)
  - [PY-TST-002d] do not depend on external services unless explicitly treated as an integration test
- [PY-TST-003] Prefer behaviour-focused tests over implementation-coupled tests.
- [PY-TST-004] Cover edge cases explicitly (empty inputs, invalid data types, large datasets, boundary values) and document the expected outcome for each.
- [PY-TST-005] Add concise docstrings or comments to test cases that explain what scenario is being validated and why it matters.
- [PY-TST-006] When tests rely on fixtures or external dependencies, note those dependencies in comments so reviewers understand the setup constraints.

### 14.1 Golden tests (snapshot) 📸

- [PY-TST-007] Snapshot/golden tests are allowed for CLI output when:
  - [PY-TST-007a] output is deterministic
  - [PY-TST-007b] snapshots are small and readable
  - [PY-TST-007c] differences are meaningful
- [PY-TST-008] Prefer structured output snapshots (JSON) over free-form text.

---

## 15. Code organisation and maintainability ✍️

Per [constitution.md §7](../../.specify/memory/constitution.md#7-code-quality-guardrails):

- [PY-CODE-001] Keep business logic independent of the CLI framework.
- [PY-CODE-002] Separate:
  - [PY-CODE-002a] argument parsing
  - [PY-CODE-002b] orchestration/use-cases
  - [PY-CODE-002c] domain logic
  - [PY-CODE-002d] I/O boundaries
- [PY-CODE-003] Prefer intention-revealing names aligned to the domain language.
- [PY-CODE-004] Keep functions small and single-purpose.
- [PY-CODE-005] Keep boundary code separate from domain logic.
- [PY-CODE-006] Keep modules single-responsibility (avoid "god modules").
- [PY-CODE-007] Order code to aid navigation:
  - [PY-CODE-007a] entrypoints and public APIs first
  - [PY-CODE-007b] key behaviour next
  - [PY-CODE-007c] helpers near the behaviour they support
  - [PY-CODE-007d] shared utilities clearly grouped
- [PY-CODE-008] Add type hints at module and boundary surfaces (public functions, use-case interfaces, adapters). Use a pragmatic level of typing that improves change safety without slowing iteration.
- [PY-CODE-009] Keep framework objects at the edges: do not let request/response objects leak into domain or use-case logic ([PY-IO-008], [PY-CODE-001]).
- [PY-CODE-010] Break complex functions into smaller, intention-revealing helpers so each unit has a single responsibility and remains easy to test.

---

## 16. Build, packaging, and release 📦

### 16.1 CLI packaging and versioning

- [PY-PKG-001] Define a single canonical entrypoint:
  - [PY-PKG-001a] console script / `python -m package` / equivalent
- [PY-PKG-002] Provide `--version` and include:
  - [PY-PKG-002a] semantic version
  - [PY-PKG-002b] build metadata when available (git SHA)
- [PY-PKG-003] Use semantic versioning for the CLI contract.
- [PY-PKG-004] Ensure reproducible builds where feasible.

### 16.2 API versioning reminders

- [PY-PKG-005] Prefer **non-breaking evolution**.
- [PY-PKG-006] If API versioning is required, use a consistent scheme (for example `/v1/` path prefix or content negotiation).

---

## 17. Performance and resilience 🚀

### 17.1 Performance and resilience (API focus; applies generally)

- [PY-PERF-001] Avoid premature optimisation, but do not allow unbounded inefficiency.
- [PY-PERF-002] Make performance characteristics explicit and testable where relevant.
- [PY-PERF-003] Be explicit about:
  - [PY-PERF-003a] timeouts
  - [PY-PERF-003b] retries and backoff
  - [PY-PERF-003c] circuit-breaking patterns where appropriate
- [PY-PERF-004] Prefer streaming/pagination for large datasets.

### 17.2 AWS Lambda and serverless-specific rules (applies to Lambda-hosted systems)

These apply when the API is deployed on AWS Lambda (even when using a framework adapter).

- [PY-PERF-005] Keep cold starts low:
  - [PY-PERF-005a] minimise dependencies
  - [PY-PERF-005b] avoid heavyweight work at import time
- [PY-PERF-006] Reuse clients/resources across invocations:
  - [PY-PERF-006a] create SDK clients outside the handler where appropriate
- [PY-PERF-007] Be explicit about limits:
  - [PY-PERF-007a] memory, timeout, payload size
  - [PY-PERF-007b] concurrency and downstream limits
- [PY-PERF-008] Design for retries:
  - [PY-PERF-008a] idempotency where applicable
  - [PY-PERF-008b] safe reprocessing for event-driven flows
- [PY-PERF-009] Treat "integration glue" as real code:
  - [PY-PERF-009a] event mapping, request context, authorisers, and middleware must be tested.

---

## 18. AI-assisted change expectations 🤖

Per [constitution.md §3.5](../../.specify/memory/constitution.md#35-ai-assisted-development-discipline--change-governance), when you create or modify code:

- [PY-AI-001] Do not invent requirements or expand scope.
- [PY-AI-002] Ensure behaviour matches the specification and is deterministic and testable.
- [PY-AI-003] Keep changes minimal and aligned with the existing architecture.
- [PY-AI-004] Update documentation/contracts only when required by the specification.
- [PY-AI-005] Run the quality gates and keep iterating until clean.
- [PY-AI-006] If you must deviate from these instructions, propose an ADR/decision record (rationale + expiry).

---

## 19. Documentation, readability, and style ✏️

- [PY-DOC-001] Provide PEP 257-compliant docstrings for modules, public classes, and functions; include parameters, return values, and behavioural notes where ambiguity exists.
- [PY-DOC-002] Write clear comments that explain the _why_ behind design decisions, algorithm choices, and non-obvious trade-offs rather than restating code.
- [PY-DOC-003] Reference any external libraries or services used in a module/function, noting their role and reasoning if it is not obvious from the code.
- [PY-DOC-004] For algorithm-heavy code paths, include a short explanation of the approach, complexity considerations, and any constraints being enforced.
- [PY-DOC-005] Prioritise readability and maintainability over cleverness; when in doubt, choose the clearer construct even if it is slightly longer.
- [PY-DOC-006] Use descriptive function, method, and variable names. Where the domain language is known, mirror it consistently.
- [PY-DOC-007] Apply type hints from the `typing` module (for example `List[str]`, `Dict[str, int]`, `tuple[str, ...]`) across public interfaces and complex internal helpers to make contracts explicit.
- [PY-DOC-008] Mention notable edge cases or behavioural quirks directly above the code that enforces them so future readers understand the rationale.
- [PY-STYLE-001] Follow PEP 8 for formatting, spacing, and naming; keep indentation at four spaces and avoid tabs.
- [PY-STYLE-002] Keep lines within 79 characters where practical; when longer lines are unavoidable (for example long URLs), document the exception with a lint pragma if required.
- [PY-STYLE-003] Place docstrings immediately after the `def` or `class` statement, using triple double-quotes.
- [PY-STYLE-004] Separate top-level classes and functions with two blank lines, and use blank lines inside functions to group related logic for readability.
- [PY-STYLE-005] When a function/class grows beyond what fits comfortably on screen, refactor or split it before adding more behaviour.

---

> **Version**: 1.3.2
> **Last Amended**: 2026-01-10
