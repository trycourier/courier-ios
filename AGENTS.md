# Agent instructions (courier-ios)

**This repository is public.** Everything committed here — code, comments, docs, skills,
commit messages — is world-readable. Keep internal-only material (credentials, workspace
object IDs, dashboards, ticket numbers, customer names, other Courier repos' layout) out
of it. `Env.swift` is gitignored for exactly this reason; never commit real credentials.

## Layout

| Path | What |
| --- | --- |
| `Sources/Courier_iOS/` | The SDK. `Modules/` (stateful facades), `Client/` (REST), `UI/` (UIKit components), `Actor/` (the `@CourierActor` global actor) |
| `Tests/CourierTests/Unit/` | Deterministic unit tests — what CI requires |
| `Tests/CourierTests/` | Live integration tests against the real Courier API |
| `Example/` | Demo app; resolves `Courier_iOS` from the **remote** repo, not this checkout |
| `Scripts/` | Version bump, manual pod release, demo archive |
| `.agents/skills/` | Task-specific instructions (`.claude/skills` is a symlink to it) |

The package is iOS-only, so `swift build` cannot work — it resolves for macOS and fails
on UIKit. Everything builds and tests through `xcodebuild` against a simulator.

## Versioning

`Sources/Courier_iOS/Courier_iOS.swift` and `Courier_iOS.podspec` both carry the version
and **must agree**. CocoaPods trunk versions are immutable: shipping source changes
without a bump makes Deploy skip publishing *successfully*, so the changes never reach
CocoaPods or the wrappers. CI's `Version guard` job blocks that — see the `release` skill.

## Swift 6

The package builds in the Swift 6 language mode and requires Xcode 16 or newer; CocoaPods
consumers can still build the sources in Swift 5 mode (`swift_versions` in the podspec).
Internal state is isolated
to `@CourierActor`; public callbacks are `@MainActor` so consumers can touch UIKit
directly. Keep that split — putting `@CourierActor` on public API would force consumer
code onto the SDK's private executor.

## Commands

```bash
sh env_setup.sh                          # generate the gitignored Env.swift files
./Scripts/update_package_version.sh      # bump the version in both files (needs `gum`)

# unit tests (what CI requires)
xcodebuild -scheme Courier_iOS \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5" \
  -only-testing:CourierTests/InboxModuleUnitTests \
  -only-testing:CourierTests/TokenModuleUnitTests test
```

## Skills

Read the matching skill in `.agents/skills/` before starting; each one documents the
places a change of that kind has to touch.

| Skill | Use for |
| --- | --- |
| `run-tests` | Running either suite, or a live test failing on workspace fixtures |
| `release` | Version bumps, `Version guard` failures, a merge that published nothing |

## Conventions

- Match the surrounding code's style, naming, and comment density. Comments explain
  *why*, not *what*.
- Public API changes ripple into **courier-flutter** and **courier-react-native**, which
  pin `Courier_iOS` exactly. Making a class `final` or changing actor isolation on public
  API is a minor bump, not a patch.
