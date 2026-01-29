---
description: Evaluate and enforce specific logging discipline across the codebase
---

**Input argument:** `Language` (for example `Python` or `TypeScript`).

## Goal 🎯

Audit every Python file in this repository against the logging standards defined below. For each file, report compliance or non-compliance per category, citing concrete evidence (function names, line numbers, code snippets). Where gaps exist, implement fixes immediately using the sensible defaults described in this prompt.

## Steps 👣

### Step 1: Discover language-specific files

1. Detect the `Language` (Python or TypeScript) before running any file discovery.
2. Run `git ls-files '*.<ext>'` to enumerate tracked files for the detected language (for example `.py`, `.ts`, `.tsx`).
3. For each file, search for **any** diagnostic output pattern:
   - Logging imports: language-standard logger, structured logger, or project logger
   - Direct stderr writes or console error output
   - Print/console output used for diagnostics
   - Logger references: `logger`, `log`, `_log`
4. Flag files with diagnostic output that do **not** import the central logger.

### Step 2: Assess logging practices

For every file that uses logging (or should but does not), evaluate compliance against the categories below. Report each finding and remediate inline where feasible.

## Implementation requirements 🛠️

### Anti-patterns (flag and fix immediately) 🚫

- **Bypassing central logger**: `sys.stderr.write()`, `print(file=sys.stderr)`, or raw `print()` for diagnostic output — route through central logger instead.
- **Direct logging import**: language-standard logger import instead of project factory — use the central logger factory.
- **Inline helper functions**: local `_log_*()` wrappers that write directly to stderr rather than delegating to the central service.
- **Silent failures**: bare `except:` or `except Exception:` without logging.
- **Mixed output channels**: some modules using central logger while others bypass it.

### Principles 🧭

- **Signal over noise**: logs must capture intent, boundaries, decisions, and failures—not routine execution. Flag verbose or redundant log statements.
- **Structured format**: prefer key=value pairs or JSON; avoid unstructured prose that is hard to parse.
- **Consistency**: log fields, levels, and phrasing should be uniform across all classes and modules. Flag deviations.

### Project-level logger configuration 🏗️

- **Single configuration point**: one central factory or module must define logger setup; all other modules import from it.
- **Environment-driven settings**: log level, sinks, and format must be configurable via environment variables or a config file, not hard-coded.
- **Dual sinks**: support both human-friendly console output and machine-readable file output (NDJSON with a stable schema).
- **File output schema**: include UTC timestamp (ISO 8601), level, message, logger name, and correlation/request ID.
- **Console readability**: align fields, keep messages concise, and allow optional expanded context on separate lines.
- **No accidental duplication**: require explicit configuration to enable multiple sinks; guard against double logging.
- **Redaction before output**: sensitive fields must be scrubbed before any sink receives the log entry.

### Class-level logging 🧩

- **Bound logger pattern (mandatory)**: use the factory function `get_logger(component="ClassName")` which returns a bound logger pre-bound to the component name. Call log methods directly on the bound logger (`self._logger.debug(...)`) rather than defining per-class wrapper methods (`_log_debug`, `_log_info`, etc.). This eliminates boilerplate and ensures a single point of change.
- **One logger per class/module**: instantiate a logger with the class or module name so context is always present.
- **Constructor logging**: log significant configuration or injected dependencies once at INFO when the object is created.
- **Lifecycle events**: log state transitions (started, stopped, reloaded) at INFO or WARN as appropriate.
- **Dependency failures**: include identifiers, error details, and retry information when logging external dependency issues.

### Method-level logging 🧪

- **Entry and exit traces**: every non-trivial method should log entry and exit at DEBUG or TRACE—unless it is a hot path.
- **Safe input logging**: log inputs only after sanitisation; never log secrets, tokens, or PII.
- **Decision points**: log key branch outcomes with relevant identifiers (e.g., user ID, order ID).
- **Exception handling**: log exceptions once at the boundary, include context and correlation ID, and always capture the stack trace.
- **Timing information**: log duration for slow or critical operations (or emit metrics instead).
- **Avoid noise**: do not add "started/finished" logs to trivial or idempotent methods.

### Log levels 🎚️

| Level | Purpose                                   |
| ----- | ----------------------------------------- |
| TRACE | Per-call granular detail (rarely enabled) |
| DEBUG | Inputs, decisions, diagnostic data        |
| INFO  | Business events, lifecycle milestones     |
| WARN  | Recoverable issues, degraded operation    |
| ERROR | Failures requiring attention              |

Flag any misuse (e.g., logging an error condition at INFO).

### Content 🧾

- **Contextual identifiers**: include correlation/request ID, user/session ID (where safe), and operation name.
- **No secrets**: never log passwords, tokens, API keys, or full request/response bodies.
- **Redaction and truncation**: mask sensitive fields and truncate large payloads to a reasonable length.

### Console visualisation 🖥️

- **Colour as enhancement**: use colour to reinforce meaning, but always pair with text labels, symbols, or icons for accessibility.
- **Contrast and colour-blindness**: ensure sufficient contrast; avoid red/green-only distinctions.
- **Visual hierarchy**: follow timestamp → level → logger → message → context fields.
- **Stable layout**: use fixed-width alignment and consistent field ordering.
- **Subtle accents**: avoid excessive rainbow colouring; keep output scannable.
- **No-colour mode**: auto-disable colour when stdout is not a TTY; honour `NO_COLOR` or similar environment variables.
- **Level tags and icons**: use short, consistent tags (INFO, WARN, ERROR) with an optional single icon per level.
- **Bounded output**: truncate or wrap large fields; never allow unbounded blobs to break layout.

### Performance ⚡

- **Guard expensive construction**: wrap costly string formatting or object serialisation in a level check (e.g., `if logger.isEnabledFor(DEBUG)`).
- **Avoid tight-loop logging**: do not log inside hot loops unless sampled or rate-limited.
- **Metrics vs logs**: use metrics for counts and latency; reserve logs for discrete events.

## Output requirements 📋

1. **Findings per file**: for each category above and each of its bullet point, state one of the following statuses with a brief explanation and the emoji shown: ✅ Fully compliant, ⚠️ Partially compliant, ❌ Not compliant.
2. **Evidence links**: reference specific lines using workspace-relative Markdown links (e.g., `[src/app.py](src/app.py#L10-L40)`).
3. **Immediate fixes**: apply sensible defaults inline where possible; do not defer trivial remediations.
4. **Unknowns**: when information is missing, record **Unknown from code – {suggested action}** rather than guessing.
5. **Summary checklist**: after processing all files, confirm overall compliance with:
   - [ ] Principles
   - [ ] Project-level logger configuration
   - [ ] Class-level logging
   - [ ] Method-level logging
   - [ ] Log levels
   - [ ] Content
   - [ ] Console visualisation
   - [ ] Performance

---

> **Version**: 1.1.3
> **Last Amended**: 2026-01-29
