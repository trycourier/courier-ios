# Courier Public API — Assistant Conventions

Purpose

- Provide stable, high-signal conventions for AI coding assistants interacting with Courier’s Public API from this repository.
- Avoid drift by deferring to the canonical rules maintained in the backend repository.

Source of truth

- Canonical rules live in the backend repo:
  - https://github.com/trycourier/backend/blob/master/.claude/rules/api-conventions.md
  - https://github.com/trycourier/backend/blob/master/.claude/rules/api-deviations.md
- If any statements here disagree with the backend, treat the backend as authoritative.

General guidance

- Always use HTTPS and JSON.
- Authenticate with a Bearer token via the Authorization header.
- Treat 429 and 5xx as retryable with exponential backoff and jitter; respect Retry-After when present.
- Prefer idempotent operations when available; avoid blind retries on non-idempotent writes.
- Log requestId and messageId fields when available to aid support and debugging.
- Use ISO 8601 timestamps and UTC when constructing or parsing date-time values.

SDK alignment

- This repository is an SDK; it does not define server endpoints. When in doubt about response envelopes or pagination fields, consult the backend canonical rules or the live API reference:
  - https://www.courier.com/docs/reference/

Review checklist for API usage in this repo

- [ ] Authorization header present on all API requests
- [ ] Content-Type: application/json set on requests with bodies
- [ ] 4xx/5xx/429 errors handled with clear messages; retries only when safe
- [ ] Timeouts and network errors surface actionable context (no silent failures)
- [ ] Pagination follows server-provided cursors when available
- [ ] Identifiers (msg_, req_, brd_, etc.) treated as opaque strings (no client-side parsing)

