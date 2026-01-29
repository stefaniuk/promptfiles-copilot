---
description: Evaluate and enforce specific CLI argument parsing discipline across the codebase
---

**Input argument:** `Language` (for example `Python` or `TypeScript`).

## Goal 🎯

Audit every CLI entrypoint and argument parser in this repository against the CLI Contract Baseline and the argument parsing standards defined below. For each entrypoint, report compliance or non-compliance per category, citing concrete evidence (function names, line numbers, code snippets). Where gaps exist, implement fixes immediately using the sensible defaults described in this prompt and the baseline.

## Steps 👣

### Step 1: Discover CLI entrypoints

1. Detect the `Language` (Python or TypeScript) before running any file discovery.
2. Run `git ls-files '*.<ext>'` to enumerate tracked files for the detected language (for example `.py`, `.ts`, `.tsx`).
3. Locate CLI entrypoints in each language and runtime, including:
   - Conventional entry files (for example `__main__`, `main`, `cli`, `bin/`, `scripts/`).
   - Package metadata that registers commands (for example `pyproject.toml`, `setup.cfg`, `setup.py`, `package.json`, `Cargo.toml`).
4. Record the entrypoint function or module for each CLI.

### Step 2: Identify argument parsing logic

1. For each CLI, find the argument parsing library (for example argparse, click, typer, clap, cobra, commander, yargs).
2. Flag manual parsing (`sys.argv`, `os.Args`, `process.argv`) or ad-hoc split logic that bypasses a parser.
3. Record where validation and default handling occur.

### Step 3: Assess compliance

Evaluate each CLI against the CLI Contract Baseline at:

- `.github/instructions/includes/cli-contract-baseline.include.md`

Report compliance for:

- Exit codes
- Stdout vs stderr
- Documentation and testing expectations
- Developer ergonomics
- Wrappers and shared libraries
- Cloud and serverless workloads (where relevant)
- Argument parsing and flags

### Step 4: Remediate

1. Apply fixes immediately using the defaults in this prompt and the baseline.
2. Keep changes small and consistent with existing patterns.
3. Where behaviour changes are introduced, add tests using a strict Red → Green → Refactor flow.

## Implementation requirements 🛠️

### Anti-patterns (flag and fix immediately) 🚫

- Manual `argv` parsing that bypasses a dedicated parser.
- Abbreviated long flags or prefix matching that can become ambiguous.
- More than two positional arguments without clear documentation and validation.
- Boolean values represented as positional arguments.
- Unknown flags or surplus positional arguments ignored or silently dropped.
- Flag names that are inconsistent across commands for the same concept.
- Help output that omits defaults, environment variable sources, or usage examples.
- Hidden side effects on flag parsing or validation that make flags non-idempotent.
- Interactive prompts triggered by default without a non-interactive equivalent.
- Diagnostics printed to `stdout` or mixed into machine-readable outputs.
- Wrapper CLIs that re-implement business logic instead of delegating to shared libraries.

### Principles 🧭

- Keep parsing predictable, explicit, and stable for both humans and automation.
- Prefer clarity over brevity; avoid clever parsing tricks.
- Keep behaviour deterministic for the same inputs and environment.
- Use clear, consistent naming: kebab-case for flags and nouns for commands.
- Prefer long flags and add short aliases only when they are common and unambiguous.
- Keep interfaces stable; avoid breaking changes or add deprecation periods.
- Ensure flags are idempotent and avoid hidden side effects.
- Accept arguments in predictable order and prefer explicit named flags over positional ambiguity.
- Make configuration precedence explicit: CLI > env vars > config file > defaults.
- Keep CLI entrypoints thin: parse/validate, call shared logic, and forward exit codes.

### Argument parsing and flag rules 🧩

- Use a dedicated argument parser with validation, defaults, and help output.
- Use kebab-case for long flags and single-letter short flags only for common actions.
- Require exact long-flag matches; do not allow abbreviations.
- Support `--` to stop option parsing and treat the remainder as positional input.
- Use explicit boolean switches (`--feature` and `--no-feature`) or a single clear switch.
- Validate required inputs, mutual exclusions, and ranges at parse time and exit with code `2` plus a `--help` hint.
- Support repeatable flags for multiple values and document ordering, de-duplication, and limits.
- Reject unknown flags and surplus positional arguments with exit code `2`.
- Follow standard conventions for `-h/--help`, `-v/--version`, `--verbose`, and `--quiet`. These are must-have arguments for every CLI.
- Provide `--yes` or `--no-input` for non-interactive operation and make prompts opt-in.

### Modern parser defaults 🧱

- Use type hints or explicit parameter types for all options and arguments.
- Prefer specialised parameter types (choice/enum, path/file, range, UUID, datetime) instead of raw strings.
- Validate file and path parameters for existence and permissions at parse time.
- Use explicit prompts only when configured; never prompt for required values by default.
- For sensitive inputs, require confirmation prompts and avoid echoing input back to the terminal.
- Use subcommands for distinct actions instead of large flag sets on a single command.
- Use a shared context object to pass parsed configuration to subcommands; avoid global mutable state.
- Use parser callbacks for validation and normalisation rather than manual checks after parsing.
- Keep `--help` and `--version` eager so they work even when other inputs are invalid.
- Provide shell completion support when the parser supports it and document how to enable it.
- Use the parser's output helpers for consistent encoding and `stdout`/`stderr` handling.

### Help and documentation 📋

- Keep `--help` short, structured, grouped, and example-driven.
- Make defaults sensible and document them clearly in `--help`.
- Include a piping or `--json` example when machine-readable output exists.
- Document exit codes and diagnostic behaviour in README and help output.
- Describe mutually exclusive options, default value sources, and configuration precedence.

### Validation and errors 🚦

- Validate inputs early and return clear, actionable errors.
- Use exit code `2` for parsing and validation errors.
- Ensure errors are actionable and include a `--help` hint.
- Do not emit diagnostics on `stdout`.
- Use exit code `0` for success and `1` for operational failures when no specific code applies.
- Exit with the first failure cause; do not mask distinct failures behind the same code unless documented.

### Stdout and stderr semantics 📤

- Keep `stdout` for primary result payloads and `stderr` for diagnostics.
- Ensure `stdout` stays clean for piping or redirection.
- Emit progress to `stderr` for long-running commands.
- Provide an explicit `--json` mode when machine-readable output is supported.
- Flush and close streams explicitly before exiting short-lived handlers.

### Developer ergonomics 🧑‍💻

- Provide `--help`, `--version`, and `--verbose` or `--quiet` consistently.
- Offer `--dry-run` when the command mutates resources.
- Keep interactive prompts opt-in and always provide a non-interactive equivalent.

### Logging verbosity controls 🔊

- `--verbose` raises verbosity one step; allow `-v`, `-vv`, `-vvv` to increment levels (for example INFO → DEBUG → TRACE).
- `--quiet` lowers verbosity one step; allow `-q`, `-qq` similarly.
- Document the exact mapping from flags to log levels in `--help`.
- Provide `--log-level <level>` for explicit control; flags are convenience.
- Support an environment variable for verbosity (for example `LOG_LEVEL` or `VERBOSITY`), with precedence: CLI flags > env vars > config file > defaults.
- Keep diagnostics on `stderr` and keep outputs deterministic.

### Wrappers and shared libraries 📦

- Keep CLI entrypoints thin and delegate domain logic to shared libraries.
- Align wrapper validation rules and defaults with the underlying library API.
- Centralise shared parsing or logging helpers across related CLIs.
- Expose a `main(args: list[str]) -> int` or equivalent entrypoint where possible.

### Cloud and serverless workloads ☁️

- Avoid reliance on background daemons or writable current directories unless explicitly provisioned.
- Provide `--timeout` flags where platform limits apply and emit periodic progress to `stderr`.
- Emit structured logs compatible with shared observability standards.
- Avoid interactive authentication flows; support token injection or credentials for automation.

### Testing expectations 🧪

- Add integration tests for each CLI covering a success case and each reserved non-zero exit code.
- Add unit tests for parsing edge cases (unknown flag, missing required input, mutual exclusions).
- Keep tests deterministic and assert exact exit codes.
- Test the CLI contract explicitly (help text, parsing, errors, exit codes).
- Include smoke tests for wrapper CLIs to ensure deterministic exit codes and diagnostics.
- Use the parser's built-in test runner where available instead of spawning subprocesses.

## Output requirements 📋

1. **Findings per file**: for each category above and each of its bullet point, state one of the following statuses with a brief explanation and the emoji shown: ✅ Fully compliant, ⚠️ Partially compliant, ❌ Not compliant.
2. **Evidence links**: reference specific lines using workspace-relative Markdown links (e.g., `[src/app.py](src/app.py#L10-L40)`).
3. **Immediate fixes**: apply sensible defaults inline where possible; do not defer trivial remediations.
4. **Unknowns**: when information is missing, record **Unknown from code – {suggested action}** rather than guessing.
5. **Summary checklist**: after processing all CLIs, confirm overall compliance with:
   - [ ] Principles
   - [ ] Argument parsing and flag rules
   - [ ] Modern parser defaults
   - [ ] Help and documentation
   - [ ] Validation and errors
   - [ ] Stdout and stderr semantics
   - [ ] Developer ergonomics
   - [ ] Logging verbosity controls
   - [ ] Wrappers and shared libraries
   - [ ] Cloud and serverless workloads
   - [ ] Testing expectations

---

> **Version**: 1.0.1
> **Last Amended**: 2026-01-29
