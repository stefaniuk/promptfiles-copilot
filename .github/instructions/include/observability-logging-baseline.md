# Observability Logging Baseline 🔭

Use this shared checklist for any runtime that produces structured logs (services, CLIs, workers, UI backends). Instruction sets must link here so log expectations change in **one** place.

## 1. Required fields (services, APIs, async workers)

Every structured log emitted around a request/task boundary must include:

- `timestamp` (UTC, ISO 8601)
- `level`
- `service` / `component`
- `environment` (dev/stage/prod)
- `version` / `build_sha`
- `request_id` / `correlation_id` (when available)
- `trace_id` / `span_id` (when tracing is enabled)
- `operation` / `route` / `use_case`
- `status` / `outcome`
- `duration_ms`
- `error_code` (for failures)
- `exception.type` and `exception.stack` (servers only, never in user-facing output)

## 2. Required fields (CLIs)

For CLI invocations (especially long-running ones):

- `timestamp`, `level`
- `command` / `subcommand`
- `args` (sanitised)
- `cwd`
- `request_id` / `invocation_id` (generate if not provided)
- `duration_ms`
- `exit_code`
- `mode` / `target_env` when applicable

## 3. Sensitive data & secrecy rules

- Never log secrets, API tokens, passwords, raw personal data, or full payloads unless the specification explicitly calls for it **and** data is masked/anonymised.
- When capturing identifiers, prefer hashed/truncated forms unless the value is already public.
- Classify and scrub structured fields before logging (for example `user_email` → masked).
- Treat log files as production data: enforce retention, access control, and scrubbing policies consistently.

## 4. Event naming & taxonomy

- Use stable, lower-kebab or dot-delimited event names (for example `request.start`, `request.end`, `dependency.call`, `dependency.error`).
- Emit both `*.start` and `*.end` (or success/failure) events around expensive boundaries to aid tracing without full distributed tracing support.
- Capture dependency metadata: host, target, attempt, timeout, retry count.
- Include `severity_reason` / `alert_hint` in error events that should page SRE/on-call teams.

## 5. Diagnostics & sampling

- Default logging level for services is `info`; enable `debug` only when explicitly requested (flag/env var) and clearly documented.
- When verbose or debug logging is enabled, emit a single function/method entry log for **every** call path, capturing the operation name and a sanitised summary of arguments (masking or omitting anything covered by §3). This keeps diagnostic runs self-explanatory without leaking secrets.
- For noisy components, support sampling (for example only log 1/N successes but 100% of errors).
- When sampling, log the sampling rate so downstream systems can extrapolate.
- Keep log size bounded: truncate oversized payloads with a clear `truncated=true` flag.
- Every exception, whether the software can recover or not, must trigger exactly one `ERROR`-level log entry that includes the `error_code`, correlation identifiers, and (server-side only) the stack trace; never downgrade exception logs just because the failure was handled.

## 6. Testing & validation

- Add regression tests (unit/integration) that assert the presence of key fields for representative success and failure cases.
- Lint or schema-validate structured logs where tooling exists (for example JSON schema, OpenTelemetry log schemas).
- Document log schemas/runbooks alongside the service so operators know how to search and interpret events.

---

> **Version**: 1.1.0
> **Last Amended**: 2026-01-10
