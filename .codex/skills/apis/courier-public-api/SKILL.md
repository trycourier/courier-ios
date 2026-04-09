# Courier Public API — Reference Skill

Summary

- This skill gives AI coding agents a concise, copy-pastable reference to the Courier Public API that is useful across repositories. It includes authentication, common headers, representative endpoints with curl examples, typical response shapes, errors, and rate limiting behavior.
- The canonical, exhaustive API documentation remains on the Courier developer docs. This skill is intentionally focused on the 80/20 tasks agents most often perform in code: sending, inspecting messages, managing brands/templates, and reading resources.

Scope and usage

- Audience: AI code assistants (Claude Code, Codex, etc.) working in Courier repositories.
- Repos: Duplicated across backend and SDKs so assistants can find API context in-repo without leaving the project.
- Source of truth: Prefer live docs for edge cases, new features, and full parameter coverage.

Base URL and auth

- Base URL: https://api.courier.com
- Auth: Bearer token in the Authorization header.
- Required headers:
  - Authorization: Bearer <COURIER_AUTH_TOKEN>
  - Content-Type: application/json

Example: Send a message

```bash
curl -X POST "https://api.courier.com/send" \
  -H "Authorization: Bearer $COURIER_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "to": { "email": "user@example.com" },
      "content": { "title": "Hello", "body": "World" },
      "routing": { "method": "single", "channels": ["email"] }
    }
  }'
```

Typical 202 response

```json
{
  "requestId": "req_1234567890",
  "messageId": "msg_1234567890"
}
```

Example: Get a message by ID

```bash
curl -X GET "https://api.courier.com/messages/msg_1234567890" \
  -H "Authorization: Bearer $COURIER_AUTH_TOKEN" \
  -H "Content-Type: application/json"
```

Example: List brands

```bash
curl -X GET "https://api.courier.com/brands" \
  -H "Authorization: Bearer $COURIER_AUTH_TOKEN" \
  -H "Content-Type: application/json"
```

Example: Create or update a profile

```bash
curl -X PUT "https://api.courier.com/profiles/user_123" \
  -H "Authorization: Bearer $COURIER_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "phone_number": "+15555550123",
    "tokens": { "fcm": "FCM_DEVICE_TOKEN" }
  }'
```

Errors and rate limiting

- 400: Validation error — check required fields and types
- 401: Invalid or missing token — refresh credentials
- 403: Insufficient scope/permissions
- 404: Resource not found
- 409: Conflict (e.g., duplicate resource)
- 429: Too many requests — implement exponential backoff and retry after the Retry-After header
- 5xx: Transient server errors — safe to retry with jitter

Conventions and shapes

- JSON request/response
- Stable identifiers: prefixes like msg_, req_, brd_ are common
- Timestamps: ISO 8601 strings
- Pagination: cursor or page/limit depending on endpoint — prefer server-provided cursors when available

References

- Public API reference: https://www.courier.com/docs/reference/
- Send API: https://www.courier.com/docs/reference/send
- Brands API: https://www.courier.com/docs/reference/brands
- Messages API: https://www.courier.com/docs/reference/messages

Maintenance

- This file is intentionally duplicated in multiple repos to improve agent discoverability.
- Keep examples minimal, correct, and runnable. Prefer links over duplicating exhaustive parameter lists.
- If conventions change, update the .claude/rules/api-conventions.md file in each repo and refresh links here.

