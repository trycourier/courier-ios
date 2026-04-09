# Courier Public API — Known Deviations (iOS SDK)

Scope

- Track any intentional, repository-specific deviations from the canonical API assistant rules.
- If empty, no repo-specific deviations are known.

Current deviations

- None. This repository is an SDK and does not define or override server response shapes. It follows the canonical rules documented in the backend repository:
  - https://github.com/trycourier/backend/blob/master/.claude/rules/api-conventions.md

Maintenance

- If a deviation is required (e.g., platform-specific retry budgets, timeout tuning), add a concise entry with rationale and affected components.

