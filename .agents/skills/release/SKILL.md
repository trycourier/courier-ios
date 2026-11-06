---
name: release
description: Bump the Courier_iOS version and get it released. Use when cutting a release, deciding whether a change is a patch/minor/major bump, when CI's "Version guard" job fails, when a merge to main didn't release anything, or when the Flutter/React Native wrappers need to pick up a new Courier_iOS. Covers the reused-version trap that makes a missed bump fail silently, and why releases no longer go to CocoaPods trunk.
---

# Release a version

Two files carry the version and **must always agree** — CI and Deploy both hard-fail on a mismatch:

| File | Line |
| --- | --- |
| `Sources/Courier_iOS/Courier_iOS.swift` | `internal static let version = "x.y.z"` |
| `Courier_iOS.podspec` | `s.version = 'x.y.z'` |

## Bump the version

Use the script — it edits both files together and bumps the Example app's build number:

```bash
./Scripts/update_package_version.sh     # interactive; requires `brew install gum`
```

It reads the current version from `Courier_iOS.swift`, offers patch/minor/major/custom,
and applies the change to both files plus `agvtool` in `Example/`. Editing the files by
hand is fine too, but then remember there are **two** of them.

## Choosing patch vs minor

CocoaPods' `~> 5.8.6` and SPM's `.upToNextMinor` both stop at the minor boundary. A
**patch** bump is therefore picked up automatically by the most conservative integrators
— the ones who deliberately pinned to patch-level updates. Anything they would want to
read about first belongs in a **minor**.

Minor (or higher), not patch, when the change:

- makes a public class `final`, or otherwise breaks source for subclassers
- changes actor isolation on public API — especially adding `@MainActor` to a callback
  type, which moves consumer code onto the main thread and can introduce UI jank in
  code that was previously off-main
- raises the minimum Swift tools version or the deployment target
- adds a capability worth announcing (e.g. Swift 6 language mode support)

Patch is for fixes and internal changes that no integrator needs to know about.

## A released version can't be reused

**A release is the version's git tag, and a tag is never moved.** This is the trap worth
internalizing: if you merge source changes without bumping, Deploy finds the tag already
there, sets `deployed=false`, and **the run still succeeds** — having released nothing.
The changes sit on `main` and never reach Swift Package Manager or the wrappers.

Two things guard this:

- **CI `Version guard`** (`.github/workflows/ci.yml`) fails a PR whose changes under
  `Sources/` or the podspec are not paired with a version that has no tag yet *and* is
  ahead of the latest released tag. PRs that touch only docs or workflows are exempt.
- **Deploy** emits a `::warning::` on its skip path so a bypassed guard is still visible
  in the run summary.

If `Version guard` fails, the fix is always to bump — never to work around it.

## What happens on merge

`.github/workflows/deploy.yml` runs on every push to `main`:

1. Reads both versions, fails on mismatch.
2. Checks for the version's tag. Already there → warn and skip (see above). Otherwise:
3. Tags the commit and creates a GitHub release with generated notes. Swift Package
   Manager picks the version up from the tag.
4. `bump-downstream` opens PRs against **courier-flutter** and **courier-react-native**
   rewriting their Courier_iOS pins (podspec, and Swift Package Manager where the
   wrapper has one) to the new version.

Those two PRs are the moment the wrappers first compile against the new code. They pin
`Courier_iOS` **exactly**, so they never float — give each one a real CI run rather than
a rubber stamp, particularly for a release that changes concurrency or public API.

## CocoaPods trunk

6.0.5 is the last version on CocoaPods trunk, which goes read-only on December 2, 2026,
so Deploy no longer pushes there. Keep `Courier_iOS.podspec` in step anyway: CocoaPods
users install later versions by tag (`pod 'Courier_iOS', :git => …, :tag => 'x.y.z'`),
which reads the podspec at that tag.

`./Scripts/manually_release_pod.sh` still runs `pod trunk push`, which only works until
trunk goes read-only and needs trunk auth.
