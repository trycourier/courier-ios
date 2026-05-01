# Courier iOS Contribution Guide

## Getting Started

1. Clone the repo
2. Open the entire project file (`courier-ios`) in Xcode
3. Run `sh env_setup` from root
4. Update the `Env.swift` files located in `Example/Example/Env.swift` and `Tests/CourierTests/Env.swift` to match the Courier credentials you'd like to test with

From here, you are all set to start working on the package! 🙌

## Developing

1. Make your changes to the `Sources/Courier_iOS` directory
2. When changes are ready, commit them to a branch in Github
  - Yes, this is weird, but it's what Apple recommends I guess 🤷‍♂️
3. Open the `Example/Example.xcodeproj`
4. Change your package dependencies to point to the new branch you are developing on
<img width="971" alt="Screen Shot 2022-11-17 at 11 35 43 AM" src="https://user-images.githubusercontent.com/6370613/202503978-f56cfcb1-220c-42be-ab77-1e00ec290677.png">
5. Pull the latest package to ensure your changes are in the Example project (File > Packages > Update to Latest Package Versions)

All set! This is the development flow

## CI secrets (GitHub Actions)

CI generates `Tests/CourierTests/Env.swift` at runtime. Configure these repository secrets:

| Secret | Purpose |
|--------|---------|
| `COURIER_ACCESS_TOKEN` | JWT / access token for API tests |
| `COURIER_USER_ID` | Test user id |
| `COURIER_MESSAGE_TEMPLATE_ID` | Template id used by inbox / preference tests |
| `COURIER_PREFERENCE_TOPIC_ID` | Preference topic id used by preference tests |

Publishable keys (`COURIER_AUTH_KEY`, `COURIER_CLIENT_KEY`, `COURIER_BRAND_ID`) are inlined in `.github/workflows/ci.yml` and do not need to be secrets.

## Testing 

1. Always test the Example project on a physical device
  - Push notifications are hard to test and require a human to ensure quality. You are the person for that job, not a computer
2. To run automated tests (which ensure the user defaults and api requests are working properly) go to `Tests/CourierTests/CourierTests.swift`

## Releasing

Courier supports 2 package managers:
1. Swift Package Manager (Which is the style the project is based on)
2. CocoaPods (Used for traditional iOS apps, Flutter and React Native)

Releases are automated via CI. To release a new version:
1. Run `sh Scripts/update_package_version.sh` to bump the version (requires `brew install gum`)
2. Commit the version changes and open a PR to `main`
3. Once tests pass and the PR is merged, CI will automatically:
   - Create a git tag and GitHub release
   - Publish to CocoaPods
   - Open dependency bump PRs in `courier-flutter` and `courier-react-native`

To manually release a pod (if CI fails): `sh Scripts/manually_release_pod.sh`
