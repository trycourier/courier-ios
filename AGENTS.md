# AI Agent Files (iOS SDK)

Overview

This repository includes metadata for AI coding assistants (e.g., Claude Code, Codex) to provide better autocomplete, context, and safe-by-default API usage. These files are intentionally lightweight and link to authoritative sources.

Contents

- Skills
  - `.claude/skills/apis/courier-public-api/SKILL.md`
  - `.codex/skills/apis/courier-public-api/SKILL.md`
  - Purpose: quick, copy-pastable Public API reference with auth, common headers, representative endpoints, example requests, and links to docs.

- Rules
  - `.claude/rules/api-conventions.md` — assistant-facing conventions for interacting with Courier’s Public API from this repo.
  - `.claude/rules/api-deviations.md` — repository-specific deviations (empty if none).

Conventions

- Canonical rules and any comprehensive API references are maintained in the backend repository and on the public docs:
  - https://github.com/trycourier/backend
  - https://www.courier.com/docs/reference/
- Keep examples in this repo minimal and correct; prefer linking to live docs over duplicating exhaustive parameter tables.

Discovery

- Claude Code: skills under `.claude/skills/**/SKILL.md` and rules under `.claude/rules/*.md` are auto-indexed.
- Codex: skills under `.codex/skills/**/SKILL.md` are used for auto-discovery in API-related contexts.

Maintenance

- If the backend rules change, mirror any necessary updates here.
- If this SDK gains new capabilities that change API usage patterns (e.g., new endpoints surfaced), update skills/rules accordingly.

