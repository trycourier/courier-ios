---
name: run-tests
description: Run the Courier_iOS test suites locally — the deterministic unit tests and the live Courier integration tests. Use when asked to run tests, verify a change, or reproduce a CI failure. Covers generating the gitignored Env.swift, why `swift build` cannot work here, and the Courier workspace fixtures the live suite silently depends on.
---

# Run the tests

## `swift build` does not work — use a simulator

The package imports UIKit, so a bare `swift build` resolves for macOS and fails with
`unable to resolve module dependency: 'UIKit'`. That is expected, not a broken checkout.
Everything goes through `xcodebuild` against an iOS simulator.

## Credentials: `Env.swift`

Both suites reference an `Env` class that is **gitignored** and absent from a fresh
checkout. Generate the placeholder version:

```bash
sh env_setup.sh     # copies EnvSample.swift to Tests/CourierTests/Env.swift and Example/Example/Env.swift
```

Placeholders (`XXXXX`) are enough to **compile**, and the unit tests pass with them. The
live suite needs real values; CI injects them from secrets. Never commit real
credentials — `Env.swift` is gitignored precisely so they stay out of this public repo.

## Unit tests (what CI requires)

Deterministic, no network, seconds to run. This is the required `Test` job:

```bash
xcodebuild -scheme Courier_iOS \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5" \
  -test-timeouts-enabled YES \
  -default-test-execution-time-allowance 10 \
  -only-testing:CourierTests/InboxModuleUnitTests \
  -only-testing:CourierTests/TokenModuleUnitTests \
  test
```

## Live integration tests

Drop the `-only-testing` flags to run everything. These hit the real Courier API — they
send messages, mutate user preferences, and depend on shared workspace state, which is
why the `Live integration tests` job is `continue-on-error: true`.

Raise the time allowance; several live tests legitimately take ~30s:

```bash
xcodebuild -scheme Courier_iOS \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5" \
  -test-timeouts-enabled YES -default-test-execution-time-allowance 120 \
  test
```

## Workspace fixtures the live suite depends on

These are **not** checked by anything and produce confusing failures when they drift.
The env values are IDs in the Courier workspace behind `COURIER_AUTH_KEY`.

**`COURIER_MESSAGE_TEMPLATE_ID` and `COURIER_PREFERENCE_TOPIC_ID` are coupled.** Two
tests impose opposite requirements on the same template, and both must hold at once:

| Test | Requires |
| --- | --- |
| `PreferenceClientTests.testInboxMessageOptedOut` | the template **is linked to** the preference topic (`subscription.topic_id`), so opting out suppresses it |
| `InboxClientTests.testTemplateMessage` | the topic's `default_status` is **`OPTED_IN`** — this test sends to a freshly generated UUID user, which inherits the default |

The template must reach the inbox channel. Note that a template fanning out to push as
well will read `UNDELIVERABLE` at the top level whenever the recipient carries a stale
APNs token (the token tests leave real-looking fakes behind) — but the inbox leg still
delivers. Don't read that aggregate status as the reason a test saw no message; check the
per-provider legs, where `courier` is the one that matters.

**`InboxTests.testTenantMessage`** hardcodes user `t1-user` and tenant `t1`. It sends to
`to: { tenant_id }`, a broadcast — so `t1-user` must actually be **a member of** `t1`, or
it fans out to zero recipients. Note `GET /tenants/<id>/users` lags; check
`GET /users/<id>/tenants` instead when verifying membership.

## Two failure modes that lie to you

- **`403 "Courier Inbox is not initialized"`** is usually *not* a server response. It is
  the 30-second failsafe in `Tests/CourierTests/Utils.swift` throwing
  `CourierError.inboxNotInitialized` because the expected message never arrived. Read it
  as "timed out waiting for delivery" and check the fixtures above.
- **`testTemplateMessage` hangs rather than fails.** It awaits a continuation with no
  timeout, so an undelivered message stalls until xcodebuild's execution-time allowance
  kills it. A hang here means the message never arrived, not that the test is slow.
