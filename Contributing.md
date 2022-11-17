# Welcome to Courier android contributing guide

## Getting Started

1. Clone the repo
2. Open the entire project file (`courier-ios`) in Xcode
3. Run `sh env-setup` from root
4. Update the `Env.swift` files located in `Example/Example/Env.swift` and `Tests/CourierTests/Env.swift` to match the Courier credentials you'd like to test with

From here, you are all set to start working on the package! 🙌

## Developing

1. Make your changes to the `Sources/Courier` directory
2. When changes are ready, commit them to a branch in Github
  - Yes, this is weird, but it's what Apple recommends I guess 🤷‍♂️
3. Open the `Example/Example.xcodeproj`
4. Change your package dependencies to point to the new branch you are developing on
<img width="971" alt="Screen Shot 2022-11-17 at 11 35 43 AM" src="https://user-images.githubusercontent.com/6370613/202503978-f56cfcb1-220c-42be-ab77-1e00ec290677.png">
5. Pull the latest package to ensure your changes are in the Example project (File > Packages > Update to Latest Package Versions)

All set! This is the development flow

## Testing 

1. Always test the Example project on a physical device
  - Push notifications are hard to test and require a human to ensure quality. You are the person for that job, not a computer
2. To run automated tests (which ensure the user defaults and api requests are working properly) go to `Tests/CourierTests/CourierTests.swift`

## Releasing

Courier supports 2 packages managers:
1. Swift Package Manager (Which is the style the project is based on)
2. Cocoapods (Used for traditional iOS apps, Flutter and React Native)

To release the app:
1. Update the `version` in `Sources/Courier/Courier.swift` to be the version you would like to release
2. Run `sh release.sh` from root

This will create a new release in github and cocoapods that anyone can install. Requires special Github permissions.
