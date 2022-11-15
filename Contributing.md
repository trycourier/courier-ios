# Welcome to Courier iOS Contribution Guide

## Getting Started

1. Clone the repo
2. Run `sh env-setup.sh` from the root directory

From here, you are all set to start working on the package! 🙌

## Developing

To make changes to the SDK:
1. Edit code inside of `Sources`

To test the changes in an example:
1. Commit and push your changes to a branch
  - This is the flow needed to test the Swift Package Manager package
2. Open an example project found inside `Examples`
3. In the example project, make sure your Package Dependency is using the branch you are developing on

<img width="868" alt="Screen Shot 2022-11-14 at 12 58 24 PM" src="https://user-images.githubusercontent.com/6370613/201732644-d334f38b-1fa4-4bd7-a26c-5932ee6689cb.png">

4. To pull the latest changes from your branch, go to File > Packages > Update to Latest Package Versions

When you need to make a change, you will need to make the change in the `Sources` file, commit and push the change, the Update to Latest Package Verisons.

This is the recommended apple development flow 🤷‍♂️

## Testing 

To test pushes, you will need a physical iOS device

To run automated tests, checkout `Tests/CourierTests/CourierTests.swift`

## Releasing

To push a release to Swift Package Manager and Cocoapods
1. Change the `version` to the version you need in `Sources/Courier.swift`
2. From the root directory, run `sh release.sh`
